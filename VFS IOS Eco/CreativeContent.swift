import Foundation

nonisolated struct PageList<Item: Decodable & Equatable>: Decodable, Equatable {
    var currentPage: Int
    var data: [Item]
    var lastPage: Int
    var total: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case lastPage = "last_page"
        case total
    }

    var hasMore: Bool { currentPage < lastPage }
}

nonisolated struct ProjectDetailResponse: Decodable, Equatable {
    var project: ProjectDetail
}

nonisolated struct ProjectMediaItem: Decodable, Equatable, Identifiable {
    var id: Int
    var type: String?
    var url: String?
}

nonisolated struct ProjectDetail: Decodable, Equatable, Identifiable {
    var id: Int
    var title: String
    var slug: String
    var category: String?
    var description: String?
    var coverURL: String?
    var media: [ProjectMediaItem]
    var tools: [String]
    var ownerName: String?
    var profileSlug: String?
    var programLabel: String
    var likesCount: Int
    var liked: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, slug, category, description, media, tools, liked
        case coverURL = "cover_url"
        case ownerName = "owner_name"
        case profileSlug = "profile_slug"
        case programLabel = "program_label"
        case likesCount = "likes_count"
    }
}

nonisolated struct ProfileResponse: Decodable, Equatable {
    var profile: CreativeProfileDetail
}

nonisolated struct ProfileProject: Decodable, Equatable, Identifiable {
    var id: Int
    var title: String
    var slug: String
    var category: String?
    var coverURL: String?
    var likesCount: Int

    enum CodingKeys: String, CodingKey {
        case id, title, slug, category
        case coverURL = "cover_url"
        case likesCount = "likes_count"
    }
}

nonisolated struct CreativeProfileDetail: Decodable, Equatable {
    var name: String?
    var headline: String?
    var programLabel: String?
    var location: String?
    var skills: [String]
    var openToWork: Bool
    var openToCollab: Bool
    var projects: [ProfileProject]

    enum CodingKeys: String, CodingKey {
        case name, headline, location, skills, projects
        case programLabel = "program_label"
        case openToWork = "open_to_work"
        case openToCollab = "open_to_collab"
    }
}

nonisolated struct CollabBoard: Decodable, Equatable {
    var industryView: Bool
    var collabs: PageList<CollabCard>

    enum CodingKeys: String, CodingKey {
        case industryView = "industry_view"
        case collabs
    }
}

nonisolated struct CollabDetailResponse: Decodable, Equatable {
    var collab: CollabCard
}

nonisolated struct CollabCard: Decodable, Equatable, Identifiable {
    var id: Int
    var title: String
    var status: String?
    var type: String?
    var role: String?
    var deadline: String?
    var coverURL: String?
    var ownerName: String?
    var description: String?
    var location: String?
    var remote: Bool?
    var paid: Bool?

    enum CodingKeys: String, CodingKey {
        case id, title, status, type, role, deadline, description, location, remote, paid
        case coverURL = "cover_url"
        case ownerName = "owner_name"
    }
}

nonisolated struct JobsBoard: Decodable, Equatable {
    var jobs: PageList<JobCard>
    var partnerJobs: PageList<JobCard>
    var productions: [ProductionCard]

    enum CodingKeys: String, CodingKey {
        case jobs, productions
        case partnerJobs = "partner_jobs"
    }
}

nonisolated struct JobDetailResponse: Decodable, Equatable {
    var job: JobCard
}

nonisolated struct JobCard: Decodable, Equatable, Identifiable {
    var id: Int
    var title: String
    var company: String?
    var location: String?
    var type: String?
    var level: String?
    var remote: Bool
    var postedAt: String?
    var applicationURL: String?

    enum CodingKeys: String, CodingKey {
        case id, title, company, location, type, level, remote
        case postedAt = "posted_at"
        case applicationURL = "application_url"
    }
}

nonisolated struct ProductionCard: Decodable, Equatable, Identifiable {
    var id: Int
    var title: String
    var region: String?
    var category: String?
    var productionCompany: String?
    var producer: String?
    var director: String?
    var schedule: String?
    var startDate: String?
    var endDate: String?
    var productionAddress: String?
    var productionManager: String?
    var productionCoordinator: String?
    var locationManager: String?
    var bgCasting: String?
    var castingDirector: String?
    var stuntCoordinator: String?
    var email: String?
    var phone: String?
    var sourceURL: String?

    enum CodingKeys: String, CodingKey {
        case id, title, region, category, producer, director, schedule, email, phone
        case productionCompany = "production_company"
        case startDate = "start_date"
        case endDate = "end_date"
        case productionAddress = "production_address"
        case productionManager = "production_manager"
        case productionCoordinator = "production_coordinator"
        case locationManager = "location_manager"
        case bgCasting = "bg_casting"
        case castingDirector = "casting_director"
        case stuntCoordinator = "stunt_coordinator"
        case sourceURL = "source_url"
    }
}

nonisolated struct CalendarFeed: Decodable {
    var calendar: [CalendarItem]
}

nonisolated struct CalendarItem: Decodable, Identifiable, Equatable {
    var id: Int
    var title: String
    var description: String?
    var location: String?
    var when: String?
    var dateLabel: String?
    var imageURL: String?
    var color: String?
    var badges: [String]?

    enum CodingKeys: String, CodingKey {
        case id, title, description, location, when, color, badges
        case dateLabel = "date_label"
        case imageURL = "image_url"
    }
}

nonisolated struct FundingBoard: Decodable {
    var grants: [FundingGrant]
    var challengeGrantID: Int?

    enum CodingKeys: String, CodingKey {
        case grants
        case challengeGrantID = "challenge_grant_id"
    }
}

nonisolated struct FundingGrant: Decodable, Identifiable, Equatable {
    var id: Int
    var name: String
    var amount: String?
    var section: String?
    var deadline: String?
    var status: String?
    var description: String?
    var longDescription: String?
    var externalURL: String?
    var isFeatured: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, amount, section, deadline, status, description
        case longDescription = "long_description"
        case externalURL = "external_url"
        case isFeatured = "is_featured"
    }
}

nonisolated struct WorkshopCategoryPage: Decodable {
    var label: String
    var courses: [WorkshopCourse]
    var events: [WorkshopEvent]

    enum CodingKeys: String, CodingKey {
        case label, courses, events
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
        courses = try container.decodeIfPresent([WorkshopCourse].self, forKey: .courses) ?? []
        events = try container.decodeIfPresent([WorkshopEvent].self, forKey: .events) ?? []
    }
}

nonisolated struct WorkshopCourse: Decodable, Identifiable, Equatable {
    var slug: String
    var name: String
    var dates: String?
    var summary: String?
    var badge: String?
    var url: String?
    var signupURL: String?

    var id: String { slug }

    enum CodingKeys: String, CodingKey {
        case slug, name, dates, summary, badge, url
        case signupURL = "signup_url"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Workshop"
        let rawSlug = try container.decodeIfPresent(String.self, forKey: .slug)
        slug = (rawSlug?.isEmpty == false) ? rawSlug! : name
        dates = try container.decodeIfPresent(String.self, forKey: .dates)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        badge = try container.decodeIfPresent(String.self, forKey: .badge)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        signupURL = try container.decodeIfPresent(String.self, forKey: .signupURL)
    }
}

nonisolated struct WorkshopEvent: Decodable, Identifiable, Equatable {
    var title: String
    var dates: String?
    var location: String?
    var description: String?
    var url: String?

    var id: String { title }
}

nonisolated struct DiscoveryListItem: Decodable, Identifiable, Equatable {
    var id: String
    var title: String
    var subtitle: String?
    var body: String?
    var poster: String?

    enum CodingKeys: String, CodingKey {
        case id, title, text, name, body, review, description, category, likes, rating, year
        case externalID = "external_id"
        case highlightCount = "highlight_count"
        case viewerCount = "viewer_count"
        case favoriteCount = "fav_count"
        case posterURL = "poster_url"
        case creator, user
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let text = try? container.decode(String.self, forKey: .id) {
            id = text
        } else if let number = try? container.decode(Int.self, forKey: .id) {
            id = String(number)
        } else if let text = try? container.decode(String.self, forKey: .externalID) {
            id = text
        } else if let number = try? container.decode(Int.self, forKey: .externalID) {
            id = String(number)
        } else {
            id = UUID().uuidString
        }
        let text = try container.decodeIfPresent(String.self, forKey: .text)
        let named = try container.decodeIfPresent(String.self, forKey: .name)
        let essay = try container.decodeIfPresent(String.self, forKey: .body)
        let headline = try container.decodeIfPresent(String.self, forKey: .title) ?? text ?? named ?? essay
        title = headline ?? "Untitled"
        let review = try container.decodeIfPresent(String.self, forKey: .review)
        let description = try container.decodeIfPresent(String.self, forKey: .description)
        if let review {
            body = review
        } else if let description {
            body = description
        } else if let essay, essay != title {
            body = essay
        } else {
            body = nil
        }
        let creator = try container.decodeIfPresent(DiscoveryPerson.self, forKey: .creator)
        let user = try container.decodeIfPresent(DiscoveryPerson.self, forKey: .user)
        poster = try container.decodeIfPresent(String.self, forKey: .posterURL) ?? creator?.avatar ?? user?.avatar
        let category = try container.decodeIfPresent(String.self, forKey: .category)
        var bits: [String] = []
        if let name = creator?.name ?? user?.name, !name.isEmpty { bits.append(name) }
        if let category, !category.isEmpty { bits.append(category) }
        if let year = Self.numberText(container, .year) { bits.append(year) }
        if let likes = Self.wholeNumber(container, .likes) { bits.append("\(likes) likes") }
        if let rating = Self.numberText(container, .rating) { bits.append("\(rating) / 5") }
        if let count = Self.wholeNumber(container, .highlightCount) { bits.append("\(count) highlights") }
        if let count = Self.wholeNumber(container, .viewerCount) { bits.append("\(count) seen") }
        if let count = Self.wholeNumber(container, .favoriteCount) { bits.append("\(count) saved") }
        subtitle = bits.isEmpty ? nil : bits.joined(separator: " · ")
    }

    private static func wholeNumber(_ container: KeyedDecodingContainer<CodingKeys>, _ key: CodingKeys) -> Int? {
        if let number = try? container.decode(Int.self, forKey: key) { return number }
        if let number = try? container.decode(Double.self, forKey: key) { return Int(number) }
        return nil
    }

    private static func numberText(_ container: KeyedDecodingContainer<CodingKeys>, _ key: CodingKeys) -> String? {
        if let text = try? container.decode(String.self, forKey: key), !text.isEmpty { return text }
        if let number = try? container.decode(Int.self, forKey: key) { return String(number) }
        if let number = try? container.decode(Double.self, forKey: key) {
            return number.rounded() == number ? String(Int(number)) : String(format: "%.1f", number)
        }
        return nil
    }
}

nonisolated struct DiscoveryPerson: Decodable, Equatable {
    var name: String?
    var avatar: String?
}

nonisolated struct DiscoveryListResponse: Decodable {
    var items: [DiscoveryListItem]
    var seen: [DiscoveryListItem]
    var saved: [DiscoveryListItem]

    enum CodingKeys: String, CodingKey {
        case pitches, reviews, items, challenges, rankings, taste
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        seen = []
        saved = []
        if let pitches = try container.decodeIfPresent([DiscoveryListItem].self, forKey: .pitches) {
            items = pitches
        } else if let reviews = try container.decodeIfPresent([DiscoveryListItem].self, forKey: .reviews) {
            items = reviews
        } else if let challenges = try container.decodeIfPresent([DiscoveryListItem].self, forKey: .challenges) {
            items = challenges
        } else if let rankings = try container.decodeIfPresent([DiscoveryListItem].self, forKey: .rankings) {
            items = rankings
        } else if let taste = try container.decodeIfPresent(TasteBoard.self, forKey: .taste) {
            items = []
            seen = taste.mostSeen
            saved = taste.mostFavorited
        } else {
            items = try container.decodeIfPresent([DiscoveryListItem].self, forKey: .items) ?? []
        }
    }
}

nonisolated struct TasteBoard: Decodable {
    var mostSeen: [DiscoveryListItem]
    var mostFavorited: [DiscoveryListItem]

    enum CodingKeys: String, CodingKey {
        case mostSeen = "most_seen"
        case mostFavorited = "most_favorited"
    }
}

nonisolated struct ManageBoard: Decodable {
    var projects: [ManagedProject]
    var collaborated: [ManagedProject]
    var liked: [ManagedProject]
    var ideas: [LikedIdea]

    enum CodingKeys: String, CodingKey {
        case projects
        case collaborated = "collaborated_projects"
        case liked = "liked_projects"
        case ideas = "liked_ideas"
    }
}

nonisolated struct ManagedProject: Decodable, Identifiable, Equatable {
    var id: Int
    var title: String
    var category: String?
    var status: String
    var views: Int
    var likesCount: Int
    var commentsCount: Int
    var coverURL: String?
    var collabRole: String?
    var collabHidden: Bool?

    enum CodingKeys: String, CodingKey {
        case id, title, category, status, views
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case coverURL = "cover_url"
        case collabRole = "collab_role"
        case collabHidden = "collab_hidden"
    }

    var isDraft: Bool { status == "draft" }

    var categoryLabel: String {
        CreativeLabels.category(category)
    }
}

nonisolated struct LikedIdea: Decodable, Identifiable, Equatable {
    var pitchID: Int
    var text: String
    var profileSlug: String?
    var creatorName: String

    var id: Int { pitchID }

    enum CodingKeys: String, CodingKey {
        case pitchID = "pitch_id"
        case text
        case profileSlug = "profile_slug"
        case creatorName = "creator_name"
    }
}

nonisolated struct OwnSettings: Decodable {
    var headline: String?
    var pronouns: String?
    var bio: String?
    var role: String?
    var location: String?
    var website: String?
    var displayName: String?
    var showreel: String?
    var socialLinks: [String: String]
    var program: [String]
    var term: String?
    var graduationYear: String?
    var skills: [String]
    var software: [String]
    var openToWork: Bool
    var openToCollab: Bool
    var visibility: String
    var mediaTastePublic: Bool
    var pitches: [OwnPitch]
    var showcaseTitles: [String]

    enum CodingKeys: String, CodingKey {
        case headline, pronouns, bio, role, location, website, term, visibility, pitches
        case displayName = "display_name"
        case showreel
        case socialLinks = "social_links"
        case program
        case graduationYear = "graduation_year"
        case skills, software
        case openToWork = "open_to_work"
        case openToCollab = "open_to_collab"
        case mediaTastePublic = "media_taste_public"
        case showcaseTitles = "showcase_titles"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        headline = try container.decodeIfPresent(String.self, forKey: .headline)
        pronouns = try container.decodeIfPresent(String.self, forKey: .pronouns)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        showreel = try container.decodeIfPresent(String.self, forKey: .showreel)
        socialLinks = (try? container.decode([String: String].self, forKey: .socialLinks)) ?? [:]
        program = Self.strings(container, .program)
        term = try container.decodeIfPresent(String.self, forKey: .term)
        if let text = try? container.decode(String.self, forKey: .graduationYear), !text.isEmpty {
            graduationYear = text
        } else if let number = try? container.decode(Int.self, forKey: .graduationYear) {
            graduationYear = String(number)
        } else {
            graduationYear = nil
        }
        skills = Self.strings(container, .skills)
        software = Self.strings(container, .software)
        openToWork = (try? container.decode(Bool.self, forKey: .openToWork)) ?? false
        openToCollab = (try? container.decode(Bool.self, forKey: .openToCollab)) ?? false
        visibility = try container.decodeIfPresent(String.self, forKey: .visibility) ?? "public"
        mediaTastePublic = (try? container.decode(Bool.self, forKey: .mediaTastePublic)) ?? true
        pitches = (try? container.decode([OwnPitch].self, forKey: .pitches)) ?? []
        showcaseTitles = Self.strings(container, .showcaseTitles)
    }

    private static func strings(_ container: KeyedDecodingContainer<CodingKeys>, _ key: CodingKeys) -> [String] {
        if let list = try? container.decode([String].self, forKey: key) { return list }
        if let one = try? container.decode(String.self, forKey: key), !one.isEmpty { return [one] }
        return []
    }
}

nonisolated struct OwnPitch: Decodable, Identifiable, Equatable {
    var id: Int
    var pitch: String
    var category: String?
    var description: String?
}

nonisolated enum CreativeLabels {
    static func category(_ key: String?) -> String {
        guard let key, !key.isEmpty else { return "" }
        return names[key] ?? titled(key)
    }

    static func program(_ key: String) -> String {
        return names[key] ?? titled(key)
    }

    private static func titled(_ key: String) -> String {
        key.replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { word in
                guard let first = word.first else { return "" }
                return String(first).uppercased() + word.dropFirst()
            }
            .joined(separator: " ")
    }

    private static let names = [
        "3d_animation": "3D Animation & Visual Effects",
        "acting_film": "Acting for Film & Television",
        "animation_concept": "Animation Concept Art",
        "classical_animation": "Classical Animation",
        "digital_design": "Digital Design",
        "film_production": "Film Production",
        "game_design": "Game Design",
        "makeup_design": "Makeup Design for Film & Television",
        "programming_games": "Programming for Games, Web & Mobile",
        "sound_design": "Sound Design for Visual Media",
        "writing": "Writing for Film, Television & Games",
        "acting_essentials": "Acting Essentials",
        "acting_essentials_evening": "Acting Essentials - Evening & Weekend",
        "english_creative_arts": "English for Creative Arts",
        "foundation_film": "Foundation – Film",
        "foundation_animation": "Foundation – Animation",
        "foundation_design": "Foundation - Design",
        "foundation_art": "Foundation Visual Art & Design",
        "film": "Film",
        "acting": "Acting",
        "animation": "Animation",
        "vfx": "VFX",
        "game_art": "Game Art",
        "concept_art": "Concept Art",
        "sound": "Sound Design",
        "makeup": "Makeup & SFX",
        "writing_legacy": "Writing",
        "programming": "Programming",
        "other": "Other",
    ]
}
