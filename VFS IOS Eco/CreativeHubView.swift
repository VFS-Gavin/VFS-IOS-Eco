import SwiftUI
import UIKit

struct CreativeHubCard: Identifiable {
    var kind: CreativeHubKind
    var label: String
    var plain: String
    var italic: String
    var accent: Color
    var image: String
    var detail: String = ""

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
        CreativeHubCard(kind: .portfolio, label: "Portfolios", plain: "Get Your Work", italic: "Seen", accent: .ecoOrange, image: "portfolio-cover"),
        CreativeHubCard(kind: .jobs, label: "Industry Opportunities", plain: "Find Current", italic: "Industry Opportunities", accent: .jobGold, image: "industry-ca"),
        CreativeHubCard(kind: .collabs, label: "Student & Alumni Projects", plain: "Crew Up,", italic: "Collaborate", accent: .collabPurple, image: "student-alumni-cover"),
        CreativeHubCard(kind: .workshops, label: "Classes, Workshops and On Campus", plain: "Level up your skills", italic: "and connections", accent: .pagePink, image: "classes-mkd"),
        CreativeHubCard(kind: .funding, label: "Funding", plain: "Fund Your", italic: "Creative Vision", accent: .pageEmerald, image: "funding-ac"),
        CreativeHubCard(kind: .facilities, label: "Resources", plain: "Access Professional", italic: "Resources", accent: Color(red: 8 / 255, green: 145 / 255, blue: 178 / 255), image: "resources-cover"),
        CreativeHubCard(kind: .studios, label: "VFS Studios Projects", plain: "Student Crews,", italic: "Real Clients", accent: brand, image: "workshops-cover"),
        CreativeHubCard(kind: .discovery, label: "Creative Engine", plain: "Discover, Connect, Create on", italic: "Films, Games, and New Ideas", accent: Color(red: 14 / 255, green: 165 / 255, blue: 233 / 255), image: "discovery-cover"),
    ]

    static let industry: [CreativeHubCard] = [
        CreativeHubCard(kind: .portfolio, label: "Portfolio", plain: "Browse talent by person", italic: "", accent: .ecoOrange, image: "portfolio-cover", detail: "Public student and alumni profiles with professional work marked for industry review."),
        CreativeHubCard(kind: .collabs, label: "Student & Alumni Projects", plain: "Open project calls", italic: "", accent: .collabPurple, image: "collabs-cover", detail: "See what crews are building and which roles still need filling."),
        CreativeHubCard(kind: .jobs, label: "Jobs", plain: "Browse openings", italic: "", accent: .jobGold, image: "jobs-cover", detail: "The same industry partner roles and production board students use."),
    ]

    static func cover(_ name: String) -> UIImage? {
        if let image = UIImage(named: name) { return image }
        for ext in ["jpg", "png"] {
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "CreativeCovers"),
               let image = UIImage(contentsOfFile: url.path) {
                return image
            }
            if let url = Bundle.main.url(forResource: name, withExtension: ext),
               let image = UIImage(contentsOfFile: url.path) {
                return image
            }
        }
        return nil
    }

    static func isOpen(_ kind: CreativeHubKind, account: Account?) -> Bool {
        guard let account else { return false }
        if account.user.role == "admin" { return true }
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

private struct CreativeRouteKey: EnvironmentKey {
    static let defaultValue: (CreativeRoute) -> Void = { _ in }
}

extension EnvironmentValues {
    var openCreativeRoute: (CreativeRoute) -> Void {
        get { self[CreativeRouteKey.self] }
        set { self[CreativeRouteKey.self] = newValue }
    }
}

struct CreativeLink<Label: View>: View {
    var route: CreativeRoute
    @ViewBuilder var label: () -> Label
    @Environment(\.openCreativeRoute) private var open

    var body: some View {
        Button(action: { open(route) }, label: label)
            .buttonStyle(.plain)
    }
}

struct CreativeHubScreen: View {
    var session: AppSession
    var industry: Bool
    var openWelcome: (() -> Void)?
    @State private var path: [CreativeRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            CreativeHubHome(session: session, industry: industry, openWelcome: openWelcome, path: $path)
                .navigationDestination(for: CreativeRoute.self) { route in
                    CreativeDestination(session: session, route: route)
                        .oneStepBack {
                            if !path.isEmpty { path.removeLast() }
                        }
                }
                .environment(\.openCreativeRoute) { route in
                    path.append(route)
                }
        }
    }
}

struct CreativeHubHome: View {
    @Bindable var session: AppSession
    var industry: Bool
    var openWelcome: (() -> Void)?
    @Binding var path: [CreativeRoute]
    @Environment(\.colorScheme) private var colorScheme

    private var cards: [CreativeHubCard] {
        let source = industry ? CreativeHubCatalog.industry : CreativeHubCatalog.student
        if industry {
            return source.filter { CreativeHubCatalog.isOpen($0.kind, account: session.account) }
        }
        return source
    }

    var body: some View {
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
                        CreativeLink(route: .setupProfile) {
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
                            CreativeLink(route: card.route) {
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
                SiteFooter(session: session) { route in
                    path.append(route)
                }
            }
            .background(Color.stone)
            .navigationTitle("Creative ECOsystem")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ThemeToggle()
                AccountMenu(session: session, openWelcome: openWelcome) { route in
                    path.append(route)
                }
            }
            .onAppear(perform: openQueuedRoute)
            .accessibilityIdentifier("creative-hub")
    }

    private func openQueuedRoute() {
        guard let route = session.queuedRoute else { return }
        session.queuedRoute = nil
        path.append(route)
    }

    private func cardFace(_ card: CreativeHubCard, open: Bool) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let image = CreativeHubCatalog.cover(card.image) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 210, maxHeight: 210)
                    .clipped()
            } else {
                Color.card.frame(height: 210)
            }
            LinearGradient(
                colors: [fadeColor, fadeColor.opacity(0.72), fadeColor.opacity(0.08), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            VStack(alignment: .leading, spacing: 6) {
                if card.detail.isEmpty {
                    Text(card.label)
                        .font(.system(size: card.kind == .discovery ? 34 : 28, weight: .bold, design: .serif))
                        .foregroundStyle(card.accent)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(card.label)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(card.accent)
                    Text(card.plain)
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(card.detail)
                        .font(.caption)
                        .foregroundStyle(Color.stoneMuted)
                        .lineLimit(3)
                }
            }
            .padding(16)
            .shadow(color: fadeColor.opacity(0.85), radius: 8, y: 2)
            if !open {
                VStack(spacing: 8) {
                    Text("Under Construction")
                        .font(.caption.weight(.bold))
                        .textCase(.uppercase)
                        .tracking(1.4)
                        .foregroundStyle(Color.stoneInk)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.card)
                        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
                    Text("Coming soon to the Creative ECOsystem")
                        .font(.caption)
                        .foregroundStyle(Color.stoneMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(fadeColor.opacity(0.82))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 210)
        .clipped()
        .overlay(alignment: .leading) { Rectangle().fill(card.accent).frame(width: 4) }
        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
    }

    private var fadeColor: Color {
        colorScheme == .dark
            ? Color(red: 17 / 255, green: 16 / 255, blue: 16 / 255)
            : Color(red: 250 / 255, green: 250 / 255, blue: 249 / 255)
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
        case .jobBoard(let board):
            JobsView(session: session, board: board)
        case .facilityBoard(let board):
            FacilitiesView(session: session, board: board)
        case .fundingBoard(let board):
            FundingView(session: session, board: board)
        case .area(let kind):
            switch kind {
            case .discovery:
                DiscoveryView(session: session)
            case .facilities:
                FacilitiesView(session: session)
            case .studios:
                StudiosView()
            case .workshops:
                WorkshopsView(session: session)
            case .funding:
                FundingView(session: session)
            default:
                CreativeAreaView(kind: kind)
            }
        case .workshopCategory(let slug):
            WorkshopCategoryView(session: session, slug: slug)
        case .discoveryList(let kind):
            DiscoveryListView(session: session, kind: kind)
        case .createProject:
            CreateProjectView(session: session) {}
        case .editProject(let id):
            CreateProjectView(session: session, projectID: id) {}
        case .studio(let id):
            if let project = StudioCatalog.projects.first(where: { $0.id == id }) {
                StudioDetailView(project: project)
            }
        case .account(let area):
            switch area {
            case .documentRequests:
                DocumentRequestsView()
            case .transcriptRequest:
                TranscriptRequestView()
            case .t2202Request:
                T2202FormView(session: session, submitPath: "/api/creative/requests/t2202", prefill: true)
            case .managePortfolio:
                ManagePortfolioView(session: session, start: .projects)
            case .liked:
                ManagePortfolioView(session: session, start: .liked)
            case .profileSettings:
                OwnProfileView(session: session, showcase: false)
            case .showcase:
                OwnProfileView(session: session, showcase: true)
            default:
                AccountAreaView(area: area)
            }
        }
    }
}

struct AccountAreaView: View {
    var area: AccountArea

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(area.title)
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                if area == .terms {
                    Text(TermsCatalog.document.intro)
                        .font(.body)
                        .foregroundStyle(Color.stoneMuted)
                    ForEach(TermsCatalog.document.sections) { section in
                        Text(section.title)
                            .font(.headline)
                            .foregroundStyle(Color.stoneInk)
                        ForEach(section.paragraphs, id: \.self) { paragraph in
                            Text(paragraph)
                                .font(.body)
                                .foregroundStyle(Color.stoneMuted)
                        }
                    }
                } else {
                    Text("This page is on the website. The app screen for it is next.")
                        .font(.body)
                        .foregroundStyle(Color.stoneMuted)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.stone)
        .navigationTitle(area.title)
        .navigationBarTitleDisplayMode(.inline)
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
