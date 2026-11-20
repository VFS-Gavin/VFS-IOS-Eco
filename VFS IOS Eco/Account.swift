import Foundation

nonisolated struct Account: Codable, Equatable {
    var home: String
    var welcomeHub: Bool
    var creative: String
    var setUpPortfolio: Bool
    var user: AccountUser
    var industry: IndustryFlags?
    var sections: CreativeFlags?
    var profile: OwnProfile?
    var terms: TermsStatus?

    enum CodingKeys: String, CodingKey {
        case home
        case welcomeHub = "welcome_hub"
        case creative
        case setUpPortfolio = "set_up_portfolio"
        case user
        case industry
        case sections
        case profile
        case terms
    }

    /// Welcome Hub is the pending and admin door. Current students and alumni stay in Creative ECOsystem.
    var showsWelcomeHub: Bool {
        switch user.role {
        case "admin", "pending": true
        case "student", "alumni", "industry", "prospect": false
        default: welcomeHub
        }
    }

    /// Pending accounts stay on Welcome Hub until an admin grants Creative ECOsystem access.
    var showsCreative: Bool {
        switch user.role {
        case "prospect": false
        case "pending": user.canAccessCreative == true && user.blockedFromCreativeWrites != true
        case "industry": creative != "none"
        case "admin", "student", "alumni": true
        default: creative == "full" || creative == "reduced"
        }
    }

    var creativeIsIndustry: Bool {
        user.role == "industry" || creative == "reduced"
    }

    var canCreateProfile: Bool {
        showsCreative && creative == "full" && profile == nil && user.blockedFromCreativeWrites != true
    }

    var needsTerms: Bool {
        guard user.role != "prospect", let terms else { return false }
        return terms.needsAcceptance
    }

    var creativeSections: [CreativeSection] {
        guard creative != "none" else { return [] }
        if let sections {
            return CreativeSection.allCases.filter { sections.allows($0) }
        }
        let reduced = creative == "reduced"
        var listed: [CreativeSection] = []
        if !reduced || industry?.canSeePortfolio != false {
            listed.append(.portfolio)
        }
        if !reduced || industry?.canSeeCollabs == true {
            listed.append(.collabs)
        }
        if !reduced || industry?.canSeeJobs == true {
            listed.append(.jobs)
        }
        return listed
    }
}

nonisolated struct CreativeFlags: Codable, Equatable {
    var portfolio: Bool
    var collabs: Bool
    var jobs: Bool
    var facilities: Bool
    var funding: Bool
    var discovery: Bool
    var workshops: Bool

    enum CodingKeys: String, CodingKey {
        case portfolio, collabs, jobs, facilities, funding, discovery, workshops
    }

    func allows(_ section: CreativeSection) -> Bool {
        switch section {
        case .portfolio: portfolio
        case .collabs: collabs
        case .jobs: jobs
        }
    }

    func isOpen(_ card: CreativeHubKind) -> Bool {
        switch card {
        case .portfolio: portfolio
        case .collabs: collabs
        case .jobs, .studios: jobs
        case .facilities: facilities
        case .funding: funding
        case .discovery: discovery
        case .workshops: workshops
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(portfolio, forKey: .portfolio)
        try container.encode(collabs, forKey: .collabs)
        try container.encode(jobs, forKey: .jobs)
        try container.encode(facilities, forKey: .facilities)
        try container.encode(funding, forKey: .funding)
        try container.encode(discovery, forKey: .discovery)
        try container.encode(workshops, forKey: .workshops)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        portfolio = try container.decodeIfPresent(Bool.self, forKey: .portfolio) ?? true
        collabs = try container.decodeIfPresent(Bool.self, forKey: .collabs) ?? true
        jobs = try container.decodeIfPresent(Bool.self, forKey: .jobs) ?? true
        facilities = try container.decodeIfPresent(Bool.self, forKey: .facilities) ?? true
        funding = try container.decodeIfPresent(Bool.self, forKey: .funding) ?? false
        discovery = try container.decodeIfPresent(Bool.self, forKey: .discovery) ?? true
        workshops = try container.decodeIfPresent(Bool.self, forKey: .workshops) ?? true
    }
}

nonisolated struct IndustryFlags: Codable, Equatable {
    var pending: Bool
    var canSeePortfolio: Bool
    var canSeeCollabs: Bool
    var canSeeJobs: Bool

    enum CodingKeys: String, CodingKey {
        case pending
        case canSeePortfolio = "can_see_portfolio"
        case canSeeCollabs = "can_see_collabs"
        case canSeeJobs = "can_see_jobs"
    }
}

enum CreativeSection: String, CaseIterable, Identifiable {
    case portfolio = "Portfolio"
    case collabs = "Collabs"
    case jobs = "Jobs"

    var id: String { rawValue }
}

enum CreativeRoute: Hashable {
    case project(Int)
    case profile(String)
    case collab(Int)
    case job(Int)
    case setupProfile
    case portfolio
    case collabs
    case jobs
    case area(CreativeHubKind)
    case account(AccountArea)
    case workshopCategory(String)
    case discoveryList(DiscoveryListKind)
    case createProject
    case editProject(Int)
    case studio(String)
}

enum AccountArea: String, Hashable {
    case managePortfolio
    case liked
    case profileSettings
    case showcase
    case documentRequests
    case transcriptRequest
    case t2202Request
    case terms

    var title: String {
        switch self {
        case .managePortfolio: "Manage Portfolio"
        case .liked: "My Liked"
        case .profileSettings: "Profile Settings"
        case .showcase: "My Showcase"
        case .documentRequests: "Document Requests"
        case .transcriptRequest: "Transcript & Diploma Request"
        case .t2202Request: "T2202 Tax Receipt"
        case .terms: "Terms & Privacy"
        }
    }
}

enum CreativeHubKind: String, Hashable, CaseIterable {
    case portfolio
    case jobs
    case collabs
    case workshops
    case funding
    case facilities
    case studios
    case discovery
}

nonisolated struct OwnProfile: Codable, Equatable {
    var slug: String
}

nonisolated struct TermsStatus: Codable, Equatable {
    var acceptedAt: String?
    var versionAccepted: Int
    var currentVersion: Int
    var dismissCount: Int
    var hardBlocked: Bool

    enum CodingKeys: String, CodingKey {
        case acceptedAt = "accepted_at"
        case versionAccepted = "version_accepted"
        case currentVersion = "current_version"
        case dismissCount = "dismiss_count"
        case hardBlocked = "hard_blocked"
    }

    var needsAcceptance: Bool {
        guard let acceptedAt, !acceptedAt.isEmpty else { return true }
        return versionAccepted < currentVersion
    }

    var dismissesLeft: Int {
        max(0, 3 - dismissCount)
    }
}

nonisolated struct TermsDismissResult: Codable, Equatable {
    var loggedOut: Bool
    var dismissesLeft: Int?
    var message: String?
    var account: Account?

    enum CodingKeys: String, CodingKey {
        case loggedOut = "logged_out"
        case dismissesLeft = "dismisses_left"
        case message
        case account
    }
}

nonisolated struct AccountUser: Codable, Equatable {
    var id: Int
    var name: String
    var email: String
    var role: String
    var blockedFromCreativeWrites: Bool?
    var canAccessCreative: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, email, role
        case blockedFromCreativeWrites = "blocked_from_creative_writes"
        case canAccessCreative = "can_access_creative"
    }
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

extension WelcomeHome {
    func includingLocalTiles() -> WelcomeHome {
        var next = groups
        func contains(_ path: String) -> Bool {
            next.contains { $0.cards.contains { $0.path == path } }
        }
        func append(_ id: String, _ title: String, _ card: WelcomeCard) {
            guard !contains(card.path) else { return }
            if let index = next.firstIndex(where: { $0.id == id }) {
                next[index].cards.append(card)
            } else {
                next.append(WelcomeGroup(id: id, title: title, cards: [card]))
            }
        }
        append("experience", "Student Experience", WelcomeCard(title: "Social Media", description: "Follow VFS on social platforms", path: "/welcome/social-media"))
        append("welcome", "Welcome Hub", WelcomeCard(title: "Connect with Industry", description: "Questions about your program, tuition, or student life", path: "/welcome/connect"))
        append("welcome", "Welcome Hub", WelcomeCard(title: "Download Documents", description: "Access all essential forms and enrollment documents in one place.", path: "/welcome/documents"))
        append("housing", "Housing Portal", WelcomeCard(title: "Housing Portal", description: "Find safe accommodation near campus", path: "/welcome/housing"))
        return WelcomeHome(accent: accent, setUpPortfolio: setUpPortfolio, groups: next)
    }
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
    case paymentMethods
    case campusTour
    case settingUpAccounts
    case financialPlanning
    case announcements
    case socialMedia
    case connect
    case documents
    case housing
    case housingListings
    case housingStudents
    case housingLandlord
    case housingSeeking
    case housingProperty(Int)
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
        case "/welcome/payment-methods":
            self = .paymentMethods
        case "/welcome/campus-tour":
            self = .campusTour
        case "/welcome/setting-up-accounts":
            self = .settingUpAccounts
        case "/welcome/financial-planning":
            self = .financialPlanning
        case "/welcome/student-announcements":
            self = .announcements
        case "/welcome/social-media":
            self = .socialMedia
        case "/welcome/connect":
            self = .connect
        case "/welcome/documents":
            self = .documents
        case "/welcome/housing":
            self = .housing
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
