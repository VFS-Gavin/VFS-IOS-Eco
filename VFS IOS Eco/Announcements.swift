import Foundation

nonisolated struct SiteNotificationItem: Decodable, Equatable, Identifiable {
    var id: Int
    var title: String
    var body: String?
    var type: String?
    var link: String?
    var linkLabel: String?
    var imageURL: String?
    var publishedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, body, type, link
        case linkLabel = "link_label"
        case imageURL = "image_url"
        case publishedAt = "published_at"
    }

    var label: String {
        switch type {
        case "success":
            return "Update"
        case "warning":
            return "Heads up"
        case "urgent":
            return "Important"
        default:
            return "Announcement"
        }
    }
}

nonisolated struct StudentEventItem: Decodable, Equatable, Identifiable {
    var title: String
    var date: String?
    var eventDate: String?
    var time: String?
    var type: String?
    var summary: String?
    var location: String?

    var id: String { "\(title)|\(eventDate ?? date ?? "")" }

    enum CodingKeys: String, CodingKey {
        case title, date, time, type, summary, location
        case eventDate = "event_date"
    }
}

nonisolated struct WelcomeAnnouncements: Decodable, Equatable {
    var studentAnnouncements: [StudentEventItem]
    var notifications: [SiteNotificationItem]

    enum CodingKeys: String, CodingKey {
        case studentAnnouncements = "student_announcements"
        case notifications
    }
}

nonisolated struct CreativeAnnouncements: Decodable, Equatable {
    var notifications: [SiteNotificationItem]
}

enum AchievementCatalog {
    static let blog = "https://vfs.edu/the-blog"
    static let items: [(title: String, date: String, category: String, summary: String)] = [
        (
            "VFS Writing alumni selected for Pacific Screenwriting Program's 2026 Scripted Series Lab",
            "January 14, 2026",
            "Writing",
            "2 VFS alumni have been selected for this prestigious writing lab, showcasing the strength of our Writing for Film, Television & Games program."
        ),
        (
            "257 VFS alumni credited at The Game Awards 2025",
            "December 19, 2025",
            "Game Design",
            "Celebrating alumni contributions on top 2025 titles. VFS graduates continue to make their mark on the biggest games in the industry."
        ),
        (
            "DigiBC & Netflix partner to offer 3 VFS animation scholarships",
            "December 11, 2025",
            "Animation",
            "An exciting partnership bringing new opportunities for aspiring animators to train at VFS with industry support."
        ),
        (
            "Q&A: Two VFS 3D Animation grads on landing internships at Sony Pictures Imageworks",
            "December 3, 2025",
            "3D Animation",
            "Alumni share their experience at Sony Pictures Imageworks and how VFS prepared them for major studio work."
        ),
        (
            "VFS Film Production alumni join Vancouver Canucks on set of \"Mission Home\"",
            "November 26, 2025",
            "Film Production",
            "VFS onset with the Canucks! Our Film Production alumni contributed to this exciting sports documentary project."
        ),
        (
            "VFS alum Rui (Mary) Zhang creates The Loglines – an online promotional platform for filmmakers",
            "November 19, 2025",
            "Film Production",
            "A VFS graduate launches an innovative platform helping filmmakers worldwide share their work and connect with industry professionals."
        ),
        (
            "VFS makes Unity Awards history with three student game nominations",
            "November 12, 2025",
            "Game Design",
            "3 VFS nominations at The Unity Awards - the only school with multiple entries! Our Game Design students continue to push boundaries."
        ),
        (
            "Vancouver Film School's Game Design program turns 20!",
            "November 5, 2025",
            "Game Design",
            "2 decades of VFS Game Design excellence. Celebrating 20 years of training the next generation of game developers."
        ),
    ]
}
