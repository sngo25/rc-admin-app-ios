import SwiftUI

/// Confession list: filter, pagination, approve/reject, number edit, post to Facebook.
struct ConfessionsView: View {
    @Environment(AuthManager.self) private var authManager

    let user: AdminUser
    let onMenuTap: () -> Void

    @State private var items: [ConfessionItem] = []
    @State private var total = 0
    /// 1-based current page.
    @State private var currentPage = 1
    @State private var pageInput = "1"
    @State private var filter: ConfessionFilter = .all
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var postDraft: String?
    @State private var actionError: String?

    private var totalPages: Int {
        max(1, Int(ceil(Double(total) / Double(ConfessionAPI.pageSize))))
    }

    private var emptyMessage: String {
        switch filter {
        case .status(.pending):
            return "No confessions waiting for review."
        case .status(.approved):
            return "No approved confessions yet."
        case .status(.rejected):
            return "No rejected confessions."
        case .all:
            return "No confessions found."
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            AdminTopBar(
                title: "Confessions",
                userInitial: userInitial,
                onMenuTap: onMenuTap
            )

            filterAndPager
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AdminTheme.background)
                .overlay(alignment: .bottom) {
                    Divider().overlay(AdminTheme.divider)
                }

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AdminTheme.screenBackground)
        .task(id: loadKey) {
            await loadPage(page: currentPage)
        }
        .fullScreenCover(isPresented: Binding(
            get: { postDraft != nil },
            set: { if !$0 { postDraft = nil } }
        )) {
            PostToFanPageSheet(
                facebookAPI: authManager.facebookAPI,
                store: PostingSettingsStore.shared,
                initialMessage: postDraft ?? ""
            ) {
                postDraft = nil
            }
            .presentationBackground(.clear)
        }
        .alert("Could not update", isPresented: Binding(
            get: { actionError != nil },
            set: { if !$0 { actionError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(actionError ?? "")
        }
    }

    /// Reloads when page or filter changes.
    private var loadKey: String {
        "\(filter.label)-\(currentPage)"
    }

    private var filterAndPager: some View {
        VStack(spacing: 10) {
            // Reset to page 1 in the same update as the filter change (avoids a double fetch).
            ConfessionFilterBar(
                filter: Binding(
                    get: { filter },
                    set: { newValue in
                        filter = newValue
                        currentPage = 1
                        pageInput = "1"
                    }
                )
            ) {
                Task {
                    await loadPage(page: currentPage, showLoading: false)
                }
            }

            ConfessionPaginationBar(
                pageInput: $pageInput,
                currentPage: currentPage,
                totalPages: totalPages,
                onBack: {
                    guard currentPage > 1 else { return }
                    goToPage(currentPage - 1)
                },
                onNext: {
                    guard currentPage < totalPages else { return }
                    goToPage(currentPage + 1)
                },
                onGo: {
                    let parsed = Int(pageInput.trimmingCharacters(in: .whitespacesAndNewlines)) ?? currentPage
                    let clamped = min(max(parsed, 1), totalPages)
                    goToPage(clamped)
                }
            )
        }
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage {
            errorState(message: errorMessage)
        } else if items.isEmpty {
            emptyState
        } else {
            confessionList
        }
    }

    private var confessionList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(items) { item in
                    ConfessionCardView(
                        item: item,
                        onApprove: {
                            Task { await approve(item) }
                        },
                        onReject: {
                            Task { await reject(item) }
                        },
                        onSaveNumber: { number in
                            Task { await saveNumber(item, number: number) }
                        },
                        onPostToFacebook: {
                            postDraft = buildPost(confession: item)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .refreshable {
            await loadPage(page: currentPage, showLoading: false)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 4) {
            Text("All caught up")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AdminTheme.emptyTitle)

            Text(emptyMessage)
                .font(.system(size: 13))
                .foregroundStyle(AdminTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 48)
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: 12) {
            Text("Could not load confessions")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AdminTheme.emptyTitle)

            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(AdminTheme.textTertiary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                Task {
                    await loadPage(page: currentPage)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 48)
    }

    private var userInitial: String {
        let trimmed = user.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else {
            return "?"
        }

        return String(first).uppercased()
    }

    private func goToPage(_ page: Int) {
        currentPage = page
        pageInput = String(page)
    }

    private func loadPage(page: Int, showLoading: Bool = true) async {
        if showLoading {
            isLoading = true
        }
        errorMessage = nil

        let offset = (page - 1) * ConfessionAPI.pageSize

        do {
            let response = try await authManager.confessionAPI.list(
                limit: ConfessionAPI.pageSize,
                offset: offset,
                status: filter.apiStatus
            )
            items = response.items
            total = response.total
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    /// Approve pending confession; assign next number when unset (web lastNumber + 1).
    private func approve(_ item: ConfessionItem) async {
        let store = PostingSettingsStore.shared

        // When local count is missing, resolve from recent Facebook posts before assigning.
        if item.number == 0 && store.postedCount == 0 {
            do {
                _ = try await store.ensurePostedCount(using: authManager.facebookAPI)
            } catch {
                actionError = error.localizedDescription
                return
            }
        }

        let assignedNumber = item.number > 0 ? item.number : store.postedCount + 1

        do {
            try await authManager.confessionAPI.update(
                id: item.id,
                status: .approved,
                number: assignedNumber
            )
            // Keep card in place (mock visibleIds) until reload/filter change.
            updateItem(id: item.id) { confession in
                confession.status = .approved
                confession.number = assignedNumber
            }
            store.noteAssignedNumber(assignedNumber)
        } catch {
            actionError = error.localizedDescription
        }
    }

    private func reject(_ item: ConfessionItem) async {
        do {
            try await authManager.confessionAPI.update(
                id: item.id,
                status: .rejected,
                number: nil
            )
            updateItem(id: item.id) { confession in
                confession.status = .rejected
            }
        } catch {
            actionError = error.localizedDescription
        }
    }

    private func saveNumber(_ item: ConfessionItem, number: Int) async {
        do {
            try await authManager.confessionAPI.update(
                id: item.id,
                status: item.status,
                number: number
            )
            updateItem(id: item.id) { confession in
                confession.number = number
            }
            PostingSettingsStore.shared.noteAssignedNumber(number)
        } catch {
            actionError = error.localizedDescription
        }
    }

    private func updateItem(id: String, mutate: (inout ConfessionItem) -> Void) {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            return
        }

        var copy = items[index]
        mutate(&copy)
        items[index] = copy
    }
}
