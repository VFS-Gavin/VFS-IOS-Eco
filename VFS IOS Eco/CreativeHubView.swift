import SwiftUI

struct CreativeHubCard: Identifiable {
    var kind: CreativeHubKind
    var label: String
    var plain: String
    var italic: String
    var accent: Color

    var id: CreativeHubKind { kind }

    var route: CreativeRoute {
        switch kind {
        case .portfolio: .portfolio
        case .jobs: .jobs
        case .collabs: .collabs
        default: .area(kind)
        }
    }
}

enum CreativeHubCatalog {
    static let brand = Color(red: 164 / 255, green: 16 / 255, blue: 52 / 255)

    static let student: [CreativeHubCard] = [
        CreativeHubCard(kind: .portfolio, label: "Portfolios", plain: "Get Your Work", italic: "Seen", accent: .ecoOrange),
        CreativeHubCard(kind: .jobs, label: "Industry Opportunities", plain: "Find Current", italic: "Industry Opportunities", accent: .jobGold),
        CreativeHubCard(kind: .collabs, label: "Student & Alumni Projects", plain: "Crew Up,", italic: "Collaborate", accent: .collabPurple),
        CreativeHubCard(kind: .workshops, label: "Classes, Workshops and On Campus", plain: "Level up your skills", italic: "and connections", accent: .pagePink),
        CreativeHubCard(kind: .funding, label: "Funding", plain: "Fund Your", italic: "Creative Vision", accent: .pageEmerald),
        CreativeHubCard(kind: .facilities, label: "Resources", plain: "Access Professional", italic: "Resources", accent: Color(red: 8 / 255, green: 145 / 255, blue: 178 / 255)),
        CreativeHubCard(kind: .studios, label: "VFS Studios Projects", plain: "Student Crews,", italic: "Real Clients", accent: brand),
        CreativeHubCard(kind: .discovery, label: "Creative Engine", plain: "Discover, Connect, Create on", italic: "Films, Games, and New Ideas", accent: Color(red: 14 / 255, green: 165 / 255, blue: 233 / 255)),
    ]

    static let industry: [CreativeHubCard] = [
        CreativeHubCard(kind: .portfolio, label: "Portfolio", plain: "Browse talent", italic: "by person", accent: .ecoOrange),
        CreativeHubCard(kind: .collabs, label: "Student & Alumni Projects", plain: "Open", italic: "project calls", accent: .collabPurple),
        CreativeHubCard(kind: .jobs, label: "Jobs", plain: "Browse", italic: "openings", accent: .jobGold),
    ]

    static func isOpen(_ kind: CreativeHubKind, account: Account?) -> Bool {
        guard let account else { return false }
        if let sections = account.sections {
            return sections.isOpen(kind)
        }
        switch kind {
        case .portfolio: return account.creativeSections.contains(.portfolio)
        case .collabs: return account.creativeSections.contains(.collabs)
        case .jobs, .studios: return account.creativeSections.contains(.jobs)
        default: return false
        }
    }
}

struct CreativeHubScreen: View {
    @Bindable var session: AppSession
    var industry: Bool

    private var cards: [CreativeHubCard] {
        let source = industry ? CreativeHubCatalog.industry : CreativeHubCatalog.student
        if industry {
            return source.filter { CreativeHubCatalog.isOpen($0.kind, account: session.account) }
        }
        return source
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if industry {
                        Text("See who's ready to work")
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundStyle(Color.stoneInk)
                        Text("Creators, open project calls, and job tools available to your account.")
                            .font(.body)
                            .foregroundStyle(Color.stoneMuted)
                        Text("Portfolio, collabs, and jobs")
                            .font(.subheadline)
                            .foregroundStyle(Color.stoneLabel)
                            .accessibilityIdentifier("industry-creative-line")
                    } else {
                        Text("Where Your Career")
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundStyle(Color.stoneInk)
                        Text("Actually Begins")
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundStyle(CreativeHubCatalog.brand)
                        Text("Our Creative ECOsystem connects you directly with fellow creators, collaborators, and real opportunities within the industry.")
                            .font(.body)
                            .foregroundStyle(Color.stoneMuted)
                    }

                    if session.account?.canCreateProfile == true {
                        NavigationLink(value: CreativeRoute.setupProfile) {
                            Text("Create your profile")
                                .font(.body.weight(.bold))
                                .foregroundStyle(Color.ecoOrange)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(Color.card)
                                .overlay(alignment: .leading) { Rectangle().fill(Color.ecoOrange).frame(width: 3) }
                                .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("create-profile")
                    }

                    ForEach(cards) { card in
                        let open = CreativeHubCatalog.isOpen(card.kind, account: session.account)
                        if open {
                            NavigationLink(value: card.route) {
                                cardFace(card, open: true)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("creative-card-\(card.kind.rawValue)")
                        } else {
                            cardFace(card, open: false)
                                .accessibilityIdentifier("creative-card-\(card.kind.rawValue)")
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.stone)
            .navigationTitle("Creative ECOsystem")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: CreativeRoute.self) { route in
                CreativeDestination(session: session, route: route)
            }
            .toolbar {
                ThemeToggle()
                Button("Sign out") { session.signOut() }
            }
            .accessibilityIdentifier("creative-hub")
        }
    }

    private func cardFace(_ card: CreativeHubCard, open: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(card.label.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(card.accent)
            Text(card.plain)
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundStyle(Color.stoneInk)
            Text(card.italic)
                .font(.system(size: 26, weight: .bold, design: .serif))
                .italic()
                .foregroundStyle(card.accent)
            if !open {
                Text("Under Construction")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.stoneMuted)
                    .padding(.top, 6)
                Text("Coming soon to the Creative ECOsystem")
                    .font(.caption)
                    .foregroundStyle(Color.stoneMuted)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card.opacity(open ? 1 : 0.55))
        .overlay(alignment: .leading) { Rectangle().fill(card.accent).frame(width: 4) }
        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
        .opacity(open ? 1 : 0.7)
    }
}

struct CreativeDestination: View {
    @Bindable var session: AppSession
    var route: CreativeRoute

    var body: some View {
        switch route {
        case .project(let id):
            ProjectDetailView(session: session, id: id)
        case .profile(let slug):
            ProfileDetailView(session: session, slug: slug)
        case .collab(let id):
            CollabDetailView(session: session, id: id)
        case .job(let id):
            JobDetailView(session: session, id: id)
        case .setupProfile:
            ProfileSetupView(session: session)
        case .portfolio:
            PortfolioView(session: session, industryLine: false)
        case .collabs:
            CollabsView(session: session)
        case .jobs:
            JobsView(session: session)
        case .area(let kind):
            CreativeAreaView(kind: kind)
        }
    }
}

struct CreativeAreaView: View {
    var kind: CreativeHubKind

    var body: some View {
        let card = CreativeHubCatalog.student.first { $0.kind == kind }
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let card {
                    Text(card.plain)
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    Text(card.italic)
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .italic()
                        .foregroundStyle(card.accent)
                }
                Text(detail)
                    .font(.body)
                    .foregroundStyle(Color.stoneMuted)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.stone)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var title: String {
        switch kind {
        case .facilities: "Resources"
        case .discovery: "Creative Engine"
        case .workshops: "Workshops"
        case .studios: "VFS Studios"
        case .funding: "Funding"
        case .portfolio: "Portfolio"
        case .jobs: "Jobs"
        case .collabs: "Projects"
        }
    }

    private var detail: String {
        switch kind {
        case .facilities:
            "Reserve studios, editing suites, and production spaces for your projects."
        case .discovery:
            "Search a title to rate it or add it to your catalogue. Pitches and Top 5s have their own pages."
        case .workshops:
            "Level up your skills and connections."
        case .studios:
            "Past and ongoing VFS Studios productions. Student-led work for SickKids, BBNO$, Invictus Games, General Motors, and Bloodline."
        case .funding:
            "External grants, festivals, and VFS funding."
        case .portfolio, .jobs, .collabs:
            ""
        }
    }
}
