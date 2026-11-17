import SwiftUI

struct PortfolioScreen: View {
    @Bindable var session: AppSession
    var navigationTitle: String
    var industryLine: Bool
    @State private var section: CreativeSection = .portfolio

    private var sections: [CreativeSection] {
        session.account?.creativeSections ?? [.portfolio]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if sections.count > 1 {
                    HStack(spacing: 0) {
                        ForEach(sections) { item in
                            Button {
                                section = item
                            } label: {
                                Text(item.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(section == item ? Color.stoneInk : Color.stoneMuted)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .overlay(alignment: .bottom) {
                                        Rectangle()
                                            .fill(section == item ? Color.ecoOrange : Color.clear)
                                            .frame(height: 2)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .background(Color.stone)
                    .overlay(alignment: .bottom) { Rectangle().fill(Color.stoneLine).frame(height: 1) }
                    .accessibilityIdentifier("creative-sections")
                }
                switch section {
                case .portfolio:
                    PortfolioView(session: session, industryLine: industryLine)
                case .collabs:
                    CollabsView(session: session)
                case .jobs:
                    JobsView(session: session)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.stone)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: CreativeRoute.self) { route in
                switch route {
                case .project(let id):
                    ProjectDetailView(session: session, id: id)
                case .profile(let slug):
                    ProfileDetailView(session: session, slug: slug)
                case .collab(let id):
                    CollabDetailView(session: session, id: id)
                case .job(let id):
                    JobDetailView(session: session, id: id)
                }
            }
            .toolbar {
                ThemeToggle()
                Button("Sign out") { session.signOut() }
            }
            .onAppear {
                if !sections.contains(section), let first = sections.first {
                    section = first
                }
            }
        }
    }
}

struct PortfolioView: View {
    @Bindable var session: AppSession
    var industryLine: Bool
    var client: APIClient = APIClient()

    @State private var feed: PortfolioFeed?
    @State private var projects: [PortfolioProject] = []
    @State private var search = ""
    @State private var professional = false
    @State private var phase: LoadPhase = .loading
    @State private var loadingMore = false

    private enum LoadPhase {
        case loading
        case ready
        case failed(String)
    }

    private var showProfessionalToggle: Bool {
        session.account?.creative != "reduced" && feed?.industryView != true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if industryLine {
                Text("Portfolio, collabs, and jobs")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneLabel)
                    .accessibilityIdentifier("industry-creative-line")
            }
            projectList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.stone)
    }

    private var projectList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CreativeAlerts(session: session)

                HStack(spacing: 8) {
                    Rectangle().fill(Color.ecoOrange).frame(width: 12, height: 3)
                    Text("PORTFOLIO PLATFORM")
                        .font(.system(size: 11, weight: .medium))
                        .tracking(1.6)
                        .foregroundStyle(Color.stoneMuted)
                }
                CreativeHeadline(
                    lead: "Portfolio ",
                    accent: "Platform",
                    accentColor: .ecoOrange,
                    detail: "Work from across VFS, students and alumni alike."
                )

                CreativeSearchField(placeholder: "Search projects or creators…", text: $search, identifier: "portfolio-search") {
                    Task { await reload() }
                }

                if showProfessionalToggle {
                    Button {
                        professional.toggle()
                        Task { await reload() }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: professional ? "checkmark.square.fill" : "square")
                            Text("Professional Portfolio")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(professional ? Color.ecoOrange : Color.stoneMuted)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(professional ? Color.ecoOrange.opacity(0.08) : Color.card)
                        .overlay(Rectangle().stroke(professional ? Color.ecoOrange : Color.stoneLine, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("portfolio-professional")
                }

                switch phase {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    Text(message)
                        .foregroundStyle(Color.stoneInk)
                case .ready:
                    Text("\(feed?.projects.total ?? projects.count) projects")
                        .font(.caption)
                        .foregroundStyle(Color.stoneLabel)
                    if projects.isEmpty {
                        Text("No projects found.")
                            .font(.body)
                            .foregroundStyle(Color.stoneLabel)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(projects) { project in
                                NavigationLink(value: CreativeRoute.project(project.id)) {
                                    card(project)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        if feed?.projects.hasMore == true {
                            Button(loadingMore ? "Loading" : "Load more") {
                                Task { await loadMore() }
                            }
                            .buttonStyle(.bordered)
                            .tint(Color.ecoOrange)
                            .disabled(loadingMore)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .task { await reload() }
    }

    private func card(_ project: PortfolioProject) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            cover(project.cover)
            VStack(alignment: .leading, spacing: 4) {
                Text(project.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.stoneInk)
                    .lineLimit(1)
                if let name = project.user.name, !name.isEmpty {
                    Text(name)
                        .font(.caption)
                        .foregroundStyle(Color.stoneMuted)
                        .lineLimit(1)
                }
                if !project.profile.programLabel.isEmpty {
                    Text(project.profile.programLabel)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.ecoOrange)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card)
        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
    }

    @ViewBuilder
    private func cover(_ raw: String?) -> some View {
        let url = PortfolioProject.coverURL(raw)
        Color(red: 231 / 255, green: 229 / 255, blue: 228 / 255)
            .aspectRatio(4 / 3, contentMode: .fit)
            .overlay {
                if let url {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color(red: 231 / 255, green: 229 / 255, blue: 228 / 255)
                    }
                }
            }
            .clipped()
    }

    private func reload() async {
        phase = .loading
        do {
            let page = try await client.portfolio(search: search, professional: professional, page: 1)
            feed = page
            projects = page.projects.data
            phase = .ready
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            phase = .failed(error.message)
        } catch {
            phase = .failed("Projects could not be loaded.")
        }
    }

    private func loadMore() async {
        guard let feed, feed.projects.hasMore, !loadingMore else { return }
        loadingMore = true
        do {
            let page = try await client.portfolio(search: search, professional: professional, page: feed.projects.currentPage + 1)
            self.feed = page
            let existing = Set(projects.map(\.id))
            projects.append(contentsOf: page.projects.data.filter { !existing.contains($0.id) })
        } catch APIError.unauthorized {
            session.signOut()
        } catch {
            // Keep the projects already on screen.
        }
        loadingMore = false
    }
}

private extension APIError {
    var message: String {
        switch self {
        case .message(let text):
            return text
        case .unauthorized:
            return "Sign in again."
        }
    }
}
