import Foundation

nonisolated struct StudentDiscount: Identifiable, Equatable {
    var category: String
    var name: String
    var discount: String
    var address: String
    var price: String
    var verified: Bool
    var link: URL? = nil

    var id: String { name }
}

nonisolated struct SchoolPartner: Identifiable, Equatable {
    var name: String
    var description: String
    var link: URL

    var id: String { name }
}

nonisolated struct SchoolHoliday: Identifiable, Equatable {
    var name: String
    var date: String
    var highlight: Bool = false

    var id: String { name }
}

nonisolated struct ProgramSchedule: Identifiable, Equatable {
    var code: String
    var name: String
    var file: String
    var term: String

    var id: String { code }
}

nonisolated enum SchoolInfoCatalog {
    static let categories: [(id: String, name: String)] = [
        ("all", "All"),
        ("food", "Food & Café"),
        ("beauty", "Beauty & Wellness"),
        ("fitness", "Fitness"),
        ("tech", "Technology"),
        ("attractions", "Attractions"),
        ("other", "Other"),
    ]

    static let discounts: [StudentDiscount] = [
        StudentDiscount(category: "food", name: "Taishoken Ramen", discount: "Student pricing", address: "515 Abbott St", price: "$$", verified: false),
        StudentDiscount(category: "food", name: "Waves Coffee House", discount: "10% off", address: "492 W Hastings St", price: "$", verified: true),
        StudentDiscount(category: "food", name: "Social Crust Café & Catering", discount: "Student pricing", address: "335 W Pender St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Joyeaux Café & Restaurant", discount: "Student pricing", address: "551 Howe St", price: "$$", verified: false),
        StudentDiscount(category: "food", name: "Poke N Chat", discount: "10% off", address: "306 Water St #2", price: "$", verified: true),
        StudentDiscount(category: "food", name: "Aiyaohno Café", discount: "Student discount", address: "425 Carrall St", price: "$", verified: true),
        StudentDiscount(category: "food", name: "Nuba (Gastown)", discount: "10% off", address: "207 W Hastings St", price: "$$", verified: true),
        StudentDiscount(category: "food", name: "Cafe Duello", discount: "Student pricing", address: "426 W Hastings St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Tsuki Sushi Bar", discount: "Student pricing", address: "509 Abbott St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Pholicious Vietnamese", discount: "10% off", address: "430 W Pender St", price: "$", verified: true),
        StudentDiscount(category: "food", name: "Ignite Pizzeria Express", discount: "Student pricing", address: "508 W Cordova St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Donair Dude", discount: "10% off", address: "164 W Hastings St", price: "$", verified: true),
        StudentDiscount(category: "food", name: "Einstein Wrap House", discount: "10% off", address: "516 Abbott St", price: "$", verified: true),
        StudentDiscount(category: "food", name: "Japadog", discount: "Student pricing", address: "533 Robson St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "PiCaDo", discount: "Student pricing", address: "605 W Pender St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Kita No Donburi", discount: "Student pricing", address: "423 Seymour St", price: "$$", verified: false),
        StudentDiscount(category: "food", name: "Kokoro Tokyo Mazesoba", discount: "Student pricing", address: "551 Seymour St", price: "$$", verified: false),
        StudentDiscount(category: "food", name: "O Sushi Downtown", discount: "Student pricing", address: "742 Granville St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Viet Sub Vietnamese Cuisine", discount: "Student pricing", address: "520 Robson St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Café Salade de Fruits", discount: "Student pricing", address: "1555 W 7th Ave", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Mazahr Lebanese Kitchen", discount: "Student pricing", address: "1488 W 11th Ave", price: "$$", verified: false),
        StudentDiscount(category: "food", name: "Sushi Den", discount: "Student pricing", address: "609 Abbott St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "FRESH SUSHI", discount: "Student pricing", address: "909 Expo Blvd", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Wow Full Noodle House", discount: "Student pricing", address: "505 Dunsmuir St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Matchstick Yaletown", discount: "Student pricing", address: "1328 Richards St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Trees Organic Coffee Gastown", discount: "Student pricing", address: "321 Water St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "The Garden Strathcona", discount: "Student pricing", address: "868 E Hastings St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Purebread", discount: "Student pricing", address: "159 W Hastings St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Saunter Coffee", discount: "Student pricing", address: "321 W Pender St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Nemesis Coffee Gastown", discount: "Student pricing", address: "302 W Hastings St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Prado Café", discount: "Student pricing", address: "100 W Hastings St", price: "$", verified: false),
        StudentDiscount(category: "food", name: "Nelson the Seagull Café", discount: "Student pricing", address: "315 Carrall St", price: "$", verified: false),
        StudentDiscount(category: "beauty", name: "Salon de Lavender Hair", discount: "Student rates", address: "519 Abbott St", price: "$$", verified: false),
        StudentDiscount(category: "beauty", name: "Onyx Aesthetics Studio", discount: "Student rates", address: "419 Abbott St", price: "$$", verified: false),
        StudentDiscount(category: "beauty", name: "VCC Salon & Spa", discount: "Student rates", address: "250 W Pender St", price: "$", verified: false),
        StudentDiscount(category: "beauty", name: "Pacific Chiropractic & Massage", discount: "Student rates", address: "1065 Cambie St", price: "$$", verified: false),
        StudentDiscount(category: "beauty", name: "Harlow Gold Salon", discount: "Student rates", address: "783 Beatty St", price: "$$", verified: false),
        StudentDiscount(category: "fitness", name: "Gold's Gym", discount: "$0 enrollment + unlimited classes", address: "709 W Broadway", price: "$$", verified: true, link: URL(string: "https://www.goldsgym.com")),
        StudentDiscount(category: "fitness", name: "Club 16", discount: "Student rates", address: "1055 Canada Pl", price: "$$", verified: false, link: URL(string: "https://www.trevorlindenfitness.com/")),
        StudentDiscount(category: "fitness", name: "Fitness World", discount: "Student rates", address: "200-1185 West Georgia St", price: "$$", verified: false, link: URL(string: "https://www.fitnessworld.ca/explore-memberships/")),
        StudentDiscount(category: "fitness", name: "YWCA Health + Fitness", discount: "$61/month + $50 joiner fee", address: "535 Hornby St", price: "$$", verified: true, link: URL(string: "https://ywcavan.org/fitness/membership/plans-and-pricing")),
        StudentDiscount(category: "fitness", name: "Vancouver Park Board Facilities", discount: "Flexipass available", address: "Various locations", price: "$", verified: false, link: URL(string: "https://vancouver.ca/parks-recreation-culture/flexipasses.aspx")),
        StudentDiscount(category: "tech", name: "Apple Store", discount: "Education pricing", address: "701 W Georgia St", price: "$$$", verified: true),
        StudentDiscount(category: "tech", name: "Dell (at Best Buy)", discount: "Student discounts", address: "798 Granville St Suite 200", price: "$$$", verified: true),
        StudentDiscount(category: "tech", name: "Lenovo (at Best Buy)", discount: "Student deals", address: "798 Granville St Suite 200", price: "$$$", verified: true),
        StudentDiscount(category: "tech", name: "Samsung", discount: "Student offers", address: "Metrotown - 4700 Kingsway Unit 1132", price: "$$$", verified: true),
        StudentDiscount(category: "tech", name: "Microsoft (at Best Buy)", discount: "Student discounts", address: "798 Granville St Suite 200", price: "$$$", verified: true),
        StudentDiscount(category: "tech", name: "Razer (at Best Buy)", discount: "Education program", address: "798 Granville St Suite 200", price: "$$$", verified: true),
        StudentDiscount(category: "attractions", name: "Capilano Suspension Bridge", discount: "$64 student price", address: "3735 Capilano Road, North Vancouver", price: "$$$", verified: true),
        StudentDiscount(category: "attractions", name: "Vancouver Aquarium", discount: "$45.45 student price", address: "845 Avison Way", price: "$$", verified: true),
        StudentDiscount(category: "attractions", name: "VanDusen Botanical Garden", discount: "1-year membership: $55", address: "5151 Oak Street", price: "$$", verified: true),
        StudentDiscount(category: "attractions", name: "Vancouver Lookout", discount: "$16.93 student price", address: "555 W Hastings St", price: "$$", verified: true),
        StudentDiscount(category: "attractions", name: "Beaty Biodiversity Museum", discount: "$15 student price", address: "2212 Main Mall", price: "$", verified: true),
        StudentDiscount(category: "other", name: "Amazon Prime Student", discount: "$4.99/month", address: "Online", price: "$", verified: true),
        StudentDiscount(category: "other", name: "Landmark Cinemas", discount: "Up to 40% off on Tuesdays", address: "Various locations", price: "$", verified: true),
        StudentDiscount(category: "other", name: "Cineplex", discount: "$8.99 on Tuesdays (reg $14.50)", address: "Various locations", price: "$", verified: true),
    ]

    static let partners: [SchoolPartner] = [
        SchoolPartner(
            name: "HelloFresh",
            description: "Canada's Most Popular Meal Kit! Get exclusive VFS student coupons at the end of Term 1 or email studentservices@vfs.com",
            link: URL(string: "https://www.hellofresh.ca/?locale=en-CA")!
        ),
        SchoolPartner(
            name: "West Trek Tour",
            description: "Get 10% off affordable tours to Rocky Mountains, Whistler, Tofino, Seattle & more! Get coupons at Student Services (198 W Hastings St).",
            link: URL(string: "https://www.westtrek.com/destinations/")!
        ),
    ]

    static let holidays: [SchoolHoliday] = [
        SchoolHoliday(name: "New Year's Day", date: "Thursday, January 1"),
        SchoolHoliday(name: "Non-instructional Day", date: "Friday, January 2"),
        SchoolHoliday(name: "Family Day", date: "Monday, February 16"),
        SchoolHoliday(name: "Good Friday", date: "Friday, April 3"),
        SchoolHoliday(name: "Easter Monday", date: "Monday, April 6"),
        SchoolHoliday(name: "Spring Break", date: "April 27 - May 1", highlight: true),
        SchoolHoliday(name: "Victoria Day", date: "Monday, May 18"),
        SchoolHoliday(name: "Canada Day", date: "Wednesday, July 1"),
        SchoolHoliday(name: "BC Day", date: "Monday, August 3"),
        SchoolHoliday(name: "Break Week", date: "August 24 - 28", highlight: true),
        SchoolHoliday(name: "Labour Day", date: "Monday, September 7"),
        SchoolHoliday(name: "Truth and Reconciliation Day", date: "Wednesday, September 30"),
        SchoolHoliday(name: "Thanksgiving Day", date: "Monday, October 12"),
        SchoolHoliday(name: "Remembrance Day", date: "Wednesday, November 11"),
        SchoolHoliday(name: "Non-instructional Days", date: "December 21 - 22"),
        SchoolHoliday(name: "Winter Break", date: "December 23 - January 1", highlight: true),
    ]

    static let programs: [ProgramSchedule] = [
        ProgramSchedule(code: "3D", name: "3D Animation & VFX", file: "3D_Sample_Schedule_T1_Sep_2025.pdf", term: "September 2025"),
        ProgramSchedule(code: "ACA", name: "Animation Concept Art", file: "ACA_Sample_Schedule_T1_Sep_2025.pdf", term: "September 2025"),
        ProgramSchedule(code: "CA", name: "Classical Animation", file: "CA_Sample_Schedule_T1_Sep_2025.pdf", term: "September 2025"),
        ProgramSchedule(code: "AC", name: "Acting for Film & TV", file: "AC_Sample_Schedule_T1_Nov_2025.pdf", term: "November 2025"),
        ProgramSchedule(code: "ACE", name: "Acting Essentials", file: "ACE_Sample_Schedule_T1_Nov_2025.pdf", term: "November 2025"),
        ProgramSchedule(code: "DD", name: "Digital Design", file: "DD_Sample_Schedule_T1_Aug_2004.pdf", term: "August 2024"),
        ProgramSchedule(code: "FD", name: "Foundation Visual Art & Design", file: "FD_Sample_Schedule_T1_Sep_2025.pdf", term: "September 2025"),
        ProgramSchedule(code: "FP", name: "Film Production", file: "FP_Sample_Schedule_T1-6_May_2025.pdf", term: "May 2025"),
        ProgramSchedule(code: "GD", name: "Game Design", file: "GD_Sample_Schedule_T1_Sep_2025.pdf", term: "September 2025"),
        ProgramSchedule(code: "MKD", name: "Makeup Design for Film & TV", file: "MKD_Sample Schedule_T1_Sep_2025.pdf", term: "September 2025"),
        ProgramSchedule(code: "PG", name: "Programming for Games, Web & Mobile", file: "PG_Sample_Schedule_T1_Sep_2025.pdf", term: "September 2025"),
        ProgramSchedule(code: "SD", name: "Sound Design", file: "SD-Sample_Schedule_T1_Nov_2025.pdf", term: "November 2025"),
        ProgramSchedule(code: "WR", name: "Writing for Film, TV & Games", file: "WR_Sample _Schedule_T1_Sep_2025.pdf", term: "September 2025"),
    ]

    static let shopURL = URL(string: "https://shopvfs.com")!
    static let fullCalendarURL = URL(string: "https://vfs.edu/calendar")!
    static let startDatesURL = URL(string: "https://vfs.edu/calendar#start-dates")!

    static func discounts(in category: String) -> [StudentDiscount] {
        guard category != "all" else { return discounts }
        return discounts.filter { $0.category == category }
    }

    static func scheduleURL(file: String, base: URL) -> URL? {
        let encoded = file.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? file
        var components = URLComponents(url: base, resolvingAgainstBaseURL: false)
        components?.percentEncodedPath = "/schedules/\(encoded)"
        return components?.url
    }
}
