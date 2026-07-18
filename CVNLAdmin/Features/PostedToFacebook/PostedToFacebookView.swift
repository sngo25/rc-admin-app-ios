import SwiftUI

/// Lists Facebook page posts backed by GET /api/facebook/getPageFeed.
struct PostedToFacebookView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AdminToast.self) private var toast
    @Environment(\.openURL) private var openURL

    let user: AdminUser
    let onMenuTap: () -> Void

    @State private var posts: [PageFeedItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            AdminTopBar(
                title: "Posted to Facebook",
                userInitial: userInitial,
                onMenuTap: onMenuTap
            )

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AdminTheme.screenBackground)
        .task {
            await loadPosts()
        }
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage {
            ErrorStateView(title: "Could not load posts", message: errorMessage) {
                Task {
                    await loadPosts()
                }
            }
        } else if posts.isEmpty {
            emptyState
        } else {
            postList
        }
    }

    private var userInitial: String {
        let trimmed = user.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else {
            return "?"
        }

        return String(first).uppercased()
    }

    private var postList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(posts) { post in
                    PostedToFacebookCardView(item: post, onViewOnPage: {
                        openPost(post)
                    })
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .refreshable {
            await loadPosts(showLoading: false)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 4) {
            Text("No posts yet")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AdminTheme.emptyTitle)

            Text("Facebook page posts will appear here.")
                .font(.system(size: 13))
                .foregroundStyle(AdminTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 48)
    }

    private func loadPosts(showLoading: Bool = true) async {
        if showLoading {
            isLoading = true
        }
        errorMessage = nil

        do {
            posts = try await authManager.facebookAPI.getPageFeed()
            // Reuse this feed to bump "Confessions posted so far" without a second request.
            PostingSettingsStore.shared.refreshPostedCount(from: posts)
            isLoading = false
        } catch {
            isLoading = false
            // Soft refresh: keep stale list and toast. Cold load / empty: full-screen error.
            if !showLoading && !posts.isEmpty {
                toast.show(error.userFacingMessage)
            } else {
                errorMessage = error.userFacingMessage
            }
        }
    }

    private func openPost(_ post: PageFeedItem) {
        guard let urlString = post.permalinkUrl,
              let url = URL(string: urlString)
        else {
            return
        }

        openURL(url)
    }
}
