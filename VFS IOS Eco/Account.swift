import Foundation

nonisolated struct Account: Codable, Equatable {
    var home: String
    var welcomeHub: Bool
    var creative: String
    var setUpPortfolio: Bool
    var user: AccountUser

    enum CodingKeys: String, CodingKey {
        case home
        case welcomeHub = "welcome_hub"
        case creative
        case setUpPortfolio = "set_up_portfolio"
        case user
    }
}

nonisolated struct AccountUser: Codable, Equatable {
    var id: Int
    var name: String
    var email: String
    var role: String
}

nonisolated struct WelcomeHome: Codable, Equatable {
    var accent: String
    var setUpPortfolio: Bool
    var groups: [WelcomeGroup]

    enum CodingKeys: String, CodingKey {
        case accent
        case setUpPortfolio = "set_up_portfolio"
        case groups
    }
}

nonisolated struct WelcomeGroup: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var cards: [WelcomeCard]
}

nonisolated struct WelcomeCard: Codable, Equatable, Identifiable {
    var title: String
    var description: String
    var path: String

    var id: String { path }
}

nonisolated enum SignInLink {
    static func token(from url: URL) -> String? {
        let parts = url.path.split(separator: "/").map(String.init)
        guard let marker = parts.lastIndex(of: "magic-link"),
              parts.indices.contains(marker + 1)
        else {
            return nil
        }
        let token = parts[marker + 1]
        return token.count >= 32 ? token : nil
    }
}
