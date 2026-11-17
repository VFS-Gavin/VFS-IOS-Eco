import SwiftUI

struct PortfolioScreen: View {
    @Bindable var session: AppSession
    var navigationTitle: String
    var industryLine: Bool

    var body: some View {
        NavigationStack {
            PortfolioView(session: session, industryLine: industryLine)
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button("Sign out") { session.signOut() }
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
                Text("Creative ECOsystem")
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundStyle(Color.stoneInk)

                TextField("Search projects or people", text: $search)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityIdentifier("portfolio-search")
                    .onSubmit { Task { await reload() } }

                if showProfessionalToggle {
                    Button {
                        professional.toggle()
                        Task { await reload() }
                    } label: {
                        Text(professional ? "Professional Portfolio on" : "Professional Portfolio")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.ecoOrange)
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
                                card(project)
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
        VStack(alignment: .leading, spacing: 8) {
            cover(project.cover)
            Text(project.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.stoneInk)
                .lineLimit(2)
            if let name = project.user.name, !name.isEmpty {
                Text(name)
                    .font(.caption)
                    .foregroundStyle(Color.stoneLabel)
            }
            if !project.profile.programLabel.isEmpty {
                Text(project.profile.programLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.ecoOrange)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func cover(_ raw: String?) -> some View {
        let url = raw.flatMap { URL(string: $0) }
        Color.stone
            .aspectRatio(4 / 3, contentMode: .fit)
            .overlay {
                if let url {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.stone
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
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
