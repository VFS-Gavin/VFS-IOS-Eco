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
