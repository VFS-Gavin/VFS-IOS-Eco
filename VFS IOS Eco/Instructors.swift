import Foundation

nonisolated struct Instructor: Codable, Equatable, Identifiable {
    var id: Int
    var name: String
    var title: String?
    var bio: String?
    var photoURL: String?
    var imdbURL: String?
    var linkedinURL: String?
    var websiteURL: String?
    var program: String?
    var programSlug: String?
    var sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, title, bio, program
        case photoURL = "photo_url"
        case imdbURL = "imdb_url"
        case linkedinURL = "linkedin_url"
        case websiteURL = "website_url"
        case programSlug = "program_slug"
        case sortOrder = "sort_order"
    }
}

nonisolated struct InstructorProgram: Codable, Equatable, Identifiable {
    var program: String
    var programSlug: String

    var id: String { programSlug }

    enum CodingKeys: String, CodingKey {
        case program
        case programSlug = "program_slug"
    }
}

nonisolated struct InstructorDirectory: Decodable, Equatable {
    var faculty: [String: [Instructor]]
    var programs: [InstructorProgram]

    enum CodingKeys: String, CodingKey {
        case faculty, programs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        programs = try container.decodeIfPresent([InstructorProgram].self, forKey: .programs) ?? []
        do {
            faculty = try container.decode([String: [Instructor]].self, forKey: .faculty)
        } catch {
            let list = try container.decode([Instructor].self, forKey: .faculty)
            guard list.isEmpty else { throw error }
            faculty = [:]
        }
    }

    var everyone: [Instructor] {
        faculty.keys.sorted().flatMap { faculty[$0] ?? [] }
    }

    var roles: [String] {
        Array(Set(everyone.compactMap(\.title).filter { !$0.isEmpty })).sorted()
    }

    func members(program slug: String, role: String, search: String) -> [Instructor] {
        var members = slug == "all" ? everyone : (faculty[slug] ?? [])
        if !role.isEmpty {
            members = members.filter { $0.title == role }
        }
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return members }
        return members.filter { person in
            person.name.lowercased().contains(query)
                || person.title?.lowercased().contains(query) == true
                || person.bio?.lowercased().contains(query) == true
                || person.program?.lowercased().contains(query) == true
        }
    }
}
