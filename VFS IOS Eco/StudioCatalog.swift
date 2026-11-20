import Foundation

struct StudioProject: Identifiable, Hashable {
    var id: String
    var title: String
    var client: String
    var program: String
    var year: String
    var description: String
    var synopsis: String?
    var support: String?
    var quotes: [StudioQuote]
    var team: [StudioCredit]
    var links: [StudioLink]
}

struct StudioQuote: Identifiable, Hashable {
    var id: String { author + role }
    var text: String
    var author: String
    var role: String
}

struct StudioCredit: Identifiable, Hashable {
    var id: String { name + role }
    var name: String
    var role: String
}

struct StudioLink: Identifiable, Hashable {
    var id: String { url }
    var label: String
    var url: String
}

enum StudioCatalog {
    static let projects: [StudioProject] = [
        StudioProject(
            id: "sickkids-maximum-effort",
            title: "SickKids × Maximum Effort",
            client: "SickKids Foundation",
            program: "Film Production",
            year: "2024",
            description: "VFS Film Production students worked with Ryan Reynolds' Maximum Effort agency to produce a national commercial for SickKids Hospital — filmed entirely in-studio at VFS.",
            synopsis: nil,
            support: nil,
            quotes: [
                StudioQuote(
                    text: "Film production is the art of risk management. Our experience filming with a crew made up of VFS students proved itself to be anything but risky. I owe this to the incredibly hands-on nature of the VFS curriculum. This practical approach is preparing the next generation of film crews the right way. The VFS staff, students, and facilities were best in class. I would not hesitate to partner with the school again in the future.",
                    author: "Jason Curtis",
                    role: "Producer, Maximum Effort"
                ),
            ],
            team: [],
            links: []
        ),
        StudioProject(
            id: "bloodline",
            title: "Bloodline",
            client: "VFS Game Design",
            program: "Programming",
            year: "2026",
            description: "VFS alumni are bringing their student final project to the retail market with game publisher R-Next and Unity3D. Play Bloodline on itch.io now. A new demo arrives in December on Steam and the PlayStation Store.",
            synopsis: "Bloodline is a 3D, over-the-shoulder, precision melee combat game. You play a talented swordmaster who, after a terrible entity curses the masquerade they were attending, must cross a transfigured gothic mansion and destroy the source of its corruption. Stab through the insectlike party-goers with aim-based rapier combat. Steal blood and use it to draw sigils that enhance your swordplay. Seek out and destroy the Heart of Corruption before it spreads to the rest of the land.",
            support: "The team is spending a further two months developing Bloodline at VFS, with campus space, hardware, and software provided for the work. R-Next is helping bring the demo to the PlayStation Store. Available for Windows.",
            quotes: [],
            team: [
                StudioCredit(name: "Alfonso Marcel Gomez De Haro", role: "PM and Programmer"),
                StudioCredit(name: "Bea Ponce Leal", role: "3D / 2D Character and Texture Artist, Cinematics"),
                StudioCredit(name: "Joao Vitor Sonoda Rezende", role: "Programmer and Build Master"),
                StudioCredit(name: "Kain Bohn", role: "Level Designer and VFX Artist"),
                StudioCredit(name: "Isabel Gallagher", role: "3D / 2D Character, Environment, and UI Artist"),
            ],
            links: [
                StudioLink(label: "Play on itch.io", url: "https://vfs-gdpg.itch.io/bloodline"),
                StudioLink(label: "R-Next", url: "https://r-next.com.co/"),
            ]
        ),
        StudioProject(
            id: "bbno",
            title: "BBNO$ Music Video",
            client: "BBNO$",
            program: "Film Production",
            year: "2024",
            description: "VFS students produced a full music video for Canadian artist BBNO$, handling all aspects of production from pre-production through final delivery.",
            synopsis: nil,
            support: nil,
            quotes: [],
            team: [],
            links: [StudioLink(label: "Official Music Video", url: "https://www.youtube.com/watch?v=x9VLSIwoTJk")]
        ),
        StudioProject(
            id: "invictus",
            title: "Invictus Games — Behind the Scenes",
            client: "Invictus Games",
            program: "Film Production",
            year: "2025",
            description: "VFS students captured behind-the-scenes footage and documentary content for the Invictus Games, showcasing the stories of athletes and the spirit of the event.",
            synopsis: nil,
            support: nil,
            quotes: [],
            team: [],
            links: []
        ),
        StudioProject(
            id: "gm",
            title: "General Motors Campaign",
            client: "General Motors",
            program: "Film Production",
            year: "2024",
            description: "A VFS student crew partnered with General Motors to produce branded content for a national campaign — a testament to the professional-level output our students deliver.",
            synopsis: nil,
            support: nil,
            quotes: [],
            team: [],
            links: []
        ),
    ]
}
