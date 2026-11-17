import Foundation

nonisolated struct CoordinatorContact: Identifiable, Equatable {
    var name: String
    var title: String
    var phone: String
    var mobile: String? = nil
    var tollFree: String? = nil
    var email: String
    var calendly: URL? = nil
    var calendlyLabel: String? = nil

    var id: String { email }

    var phoneURL: URL? { Self.dial(phone) }
    var mobileURL: URL? { mobile.flatMap(Self.dial) }
    var mailURL: URL? { URL(string: "mailto:\(email)") }

    private static func dial(_ raw: String) -> URL? {
        let head = raw.split(separator: " ").first.map(String.init) ?? raw
        let digits = head.filter(\.isNumber)
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel:\(digits)")
    }
}

nonisolated enum CoordinatorCatalog {
    /// Copied from Welcome/Coordinator.vue. Titles default to Admissions Coordinator.
    static let people: [CoordinatorContact] = [
        CoordinatorContact(
            name: "Kiha Lee",
            title: "Admissions Coordinator",
            phone: "604.631.3065",
            tollFree: "1.800.661.4101 ext. 3065",
            email: "kihal@vfs.com"
        ),
        CoordinatorContact(
            name: "Zameer Lakhani",
            title: "Admissions Coordinator",
            phone: "604.631.3019",
            tollFree: "1.800.661.4101 ext. 3019",
            email: "zlakhani@vfs.com",
            calendly: URL(string: "https://calendly.com/zlakhani-vfs/intro-call"),
            calendlyLabel: "Book Intro Call"
        ),
        CoordinatorContact(
            name: "Cici Mao",
            title: "Admissions Coordinator",
            phone: "604.631.3579",
            tollFree: "1.800.661.4101 ext. 3579",
            email: "cmao@vfs.com"
        ),
        CoordinatorContact(
            name: "Wynnie Lo",
            title: "Admissions Coordinator",
            phone: "778.400.8272",
            email: "wlo@vfs.com",
            calendly: URL(string: "https://calendly.com/wlo-vfs/phone-appointment"),
            calendlyLabel: "Book Phone Appointment"
        ),
        CoordinatorContact(
            name: "Thomas De Azevedo",
            title: "Manager, International Recruitment & Strategic Partnerships – Latin America & Caribbean",
            phone: "604.685.5808 ext. 3025",
            mobile: "778.788.4928",
            email: "tdeazevedo@vfs.com"
        ),
    ]
}
