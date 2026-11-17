import Foundation

nonisolated struct PortfolioFeed: Decodable, Equatable {
    var professionalLayout: Bool
    var industryView: Bool
    var projects: PortfolioPage

    enum CodingKeys: String, CodingKey {
        case professionalLayout = "professional_layout"
        case industryView = "industry_view"
        case projects
    }
}

nonisolated struct PortfolioPage: Decodable, Equatable {
    var currentPage: Int
    var data: [PortfolioProject]
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

nonisolated struct PortfolioProject: Decodable, Equatable, Identifiable {
    var id: Int
    var title: String
    var slug: String
    var isProfessional: Bool
    var isFeatured: Bool
    var category: String?
    var cover: String?
    var profile: PortfolioProfile
    var user: PortfolioUser

    enum CodingKeys: String, CodingKey {
        case id, title, slug, category, cover, profile, user
        case isProfessional = "is_professional"
        case isFeatured = "is_featured"
    }
}

nonisolated struct PortfolioProfile: Decodable, Equatable {
    var slug: String?
    var role: String?
    var program: [String]
    var programLabel: String
    var location: String?
    var skills: [String]
    var openToWork: Bool
    var openToCollab: Bool
    var projectsCount: Int

    enum CodingKeys: String, CodingKey {
        case slug, role, program, location, skills
        case programLabel = "program_label"
        case openToWork = "open_to_work"
        case openToCollab = "open_to_collab"
        case projectsCount = "projects_count"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        slug = try container.decodeIfPresent(String.self, forKey: .slug)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        program = Self.programs(from: container)
        programLabel = try container.decodeIfPresent(String.self, forKey: .programLabel) ?? ""
        location = try container.decodeIfPresent(String.self, forKey: .location)
        skills = try container.decodeIfPresent([String].self, forKey: .skills) ?? []
        openToWork = try container.decodeIfPresent(Bool.self, forKey: .openToWork) ?? false
        openToCollab = try container.decodeIfPresent(Bool.self, forKey: .openToCollab) ?? false
        projectsCount = try container.decodeIfPresent(Int.self, forKey: .projectsCount) ?? 0
    }

    private static func programs(from container: KeyedDecodingContainer<CodingKeys>) -> [String] {
        if let list = try? container.decode([String].self, forKey: .program) {
            return list
        }
        if let one = try? container.decode(String.self, forKey: .program) {
            return [one]
        }
        return []
    }
}

nonisolated struct PortfolioUser: Decodable, Equatable {
    var id: Int?
    var name: String?
    var profilePhotoURL: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case profilePhotoURL = "profile_photo_url"
    }
}
