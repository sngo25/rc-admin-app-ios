import Foundation

enum AppConfig {
    static var serverURL: URL {
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "SERVER_URL") as? String,
            let url = URL(string: urlString)
        else {
            fatalError("SERVER_URL is missing or invalid in Info.plist")
        }

        #if !targetEnvironment(simulator)
        let host = url.host?.lowercased()
        if host == "localhost" || host == "127.0.0.1" {
            fatalError(
                """
                SERVER_URL points to localhost, which does not work on a physical device.
                Copy Config/Local.xcconfig.example to Config/Local.xcconfig,
                set your Mac's LAN IP (ipconfig getifaddr en0), and rebuild.
                """
            )
        }
        #endif

        return url
    }
}
