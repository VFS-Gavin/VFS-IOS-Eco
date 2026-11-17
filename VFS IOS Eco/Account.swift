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

nonisolated enum WelcomeRoute: Hashable {
    case schoolInfo
    case oDay
    case coordinator
    case forms
    case acceptance
    case studyPermit
    case insurance
    case mentalHealth
    case studentStories
    case instructors
    case programPrep(String)
    case summary(title: String, description: String)

    init(card: WelcomeCard) {
        switch card.path {
        case "/welcome/school-info":
            self = .schoolInfo
        case "/welcome/o-day":
            self = .oDay
        case "/welcome/coordinator":
            self = .coordinator
        case "/welcome/forms":
            self = .forms
        case "/welcome/acceptance":
            self = .acceptance
        case "/welcome/study-permit":
            self = .studyPermit
        case "/welcome/insurance":
            self = .insurance
        case "/welcome/mental-health":
            self = .mentalHealth
        case "/welcome/student-stories":
            self = .studentStories
        case "/welcome/instructors":
            self = .instructors
        default:
            self = .summary(title: card.title, description: card.description)
        }
    }
}

nonisolated struct ODayFeed: Codable, Equatable {
    var schedules: [ODaySchedule]
}

nonisolated struct ODaySchedule: Codable, Equatable, Identifiable {
    var id: Int
    var orientationDate: String
    var startDate: String
    var time: String
    var location: String?
    var address: String?
    var notes: String?
    var isPast: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case orientationDate = "orientation_date"
        case startDate = "start_date"
        case time
        case location
        case address
        case notes
        case isPast = "is_past"
    }

    var upcoming: Bool { !isPast }

    var place: String {
        let name = location?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? "TBD" : name
    }
}

nonisolated enum WelcomeDates {
    static let vancouver = TimeZone(identifier: "America/Vancouver") ?? .current

    static func daysUntil(_ ymd: String, now: Date, timeZone: TimeZone = vancouver) -> Int? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        guard let target = date(from: ymd, timeZone: timeZone) else { return nil }
        let today = calendar.startOfDay(for: now)
        let targetDay = calendar.startOfDay(for: target)
        return calendar.dateComponents([.day], from: today, to: targetDay).day
    }

    static func longWeekday(_ ymd: String) -> String {
        format(ymd, "EEEE, MMMM d, yyyy")
    }

    static func monthDayYear(_ ymd: String) -> String {
        format(ymd, "MMMM d, yyyy")
    }

    static func monthDay(_ ymd: String) -> String {
        format(ymd, "MMM d")
    }

    private static func format(_ ymd: String, _ template: String) -> String {
        guard let date = date(from: ymd, timeZone: vancouver) else { return ymd }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = vancouver
        formatter.dateFormat = template
        return formatter.string(from: date)
    }

    private static func date(from ymd: String, timeZone: TimeZone) -> Date? {
        let parts = ymd.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2])
        else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))
    }
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
