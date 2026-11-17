import Foundation

nonisolated enum APIConfiguration {
    static var baseURL: URL {
        let raw = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String
        if let raw, let url = URL(string: raw), !raw.isEmpty {
            return url
        }
        return URL(string: "https://welcome.vfs.com")!
    }
}
