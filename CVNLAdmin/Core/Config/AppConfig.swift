import Foundation

enum AppConfig {
    static var serverURL: URL {
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "SERVER_URL") as? String,
            let url = URL(string: urlString)
        else {
            fatalError("SERVER_URL is missing or invalid in Info.plist")
        }

        return url
    }
}
