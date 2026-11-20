import SwiftUI

enum ManageTab: String, CaseIterable {
    case projects = "My Projects"
    case liked = "Liked"
    case collaborated = "Collaborated On"
}

struct ManagePortfolioView: View {
    @Bindable var session: AppSession
    var start: ManageTab
    var client: APIClient = APIClient()
    @State private var tab: ManageTab
    @State private var board: ManageBoard?
    @State private var message: String?
    @State private var loading = false

    init(session: AppSession, start: ManageTab, client: APIClient = APIClient()) {
        self.session = session
        self.start = start
        self.client = client
        _tab = State(initialValue: start)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Manage Portfolio")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                HStack(spacing: 8) {
                    ForEach(ManageTab.allCases, id: \.self) { item in
                        Button(item.rawValue) { tab = item }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(tab == item ? Color.white : Color.stoneInk)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(tab == item ? Color.ecoOrange : Color.card)
                            .overlay(Rectangle().stroke(tab == item ? Color.ecoOrange : Color.stoneLine, lineWidth: 1))
                    }
                }
                if loading { ProgressView() }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                if let board {
                    switch tab {
                    case .projects:
                        projects(board.projects)
                    case .liked:
                        liked(board)
                    case .collaborated:
                        collaborated(board.collaborated)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.stone)
        .navigationTitle("Manage Portfolio")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    @ViewBuilder
    private func projects(_ rows: [ManagedProject]) -> some View {
        if rows.isEmpty {
            Text("No Projects Yet")
                .font(.headline)
                .foregroundStyle(Color.stoneInk)
            Text("Upload your first project to start building your creative portfolio.")
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
        } else {
            Text("\(rows.count) total")
                .font(.caption)
                .foregroundStyle(Color.stoneMuted)
            ForEach(rows) { project in
                NavigationLink(value: CreativeRoute.project(project.id)) {
                    projectCard(project)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func liked(_ board: ManageBoard) -> some View {
        if board.liked.isEmpty && board.ideas.isEmpty {
            Text("You haven't liked anything yet.")
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
        } else {
            if !board.ideas.isEmpty {
                Text("ELEVATOR PITCHES")
                    .font(.caption.weight(.semibold))
                    .tracking(1.1)
                    .foregroundStyle(Color.stoneMuted)
                ForEach(board.ideas) { idea in
                    ideaRow(idea)
                }
            }
            if !board.liked.isEmpty {
                Text("PROJECTS")
                    .font(.caption.weight(.semibold))
                    .tracking(1.1)
                    .foregroundStyle(Color.stoneMuted)
                ForEach(board.liked) { project in
                    NavigationLink(value: CreativeRoute.project(project.id)) {
                        projectCard(project)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func collaborated(_ rows: [ManagedProject]) -> some View {
        if rows.isEmpty {
            Text("No credits yet")
                .font(.headline)
                .foregroundStyle(Color.stoneInk)
            Text("When another creator adds you as a collaborator on their project, it'll appear here.")
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
        } else {
            Text("Projects I've Contributed To")
                .font(.headline)
                .foregroundStyle(Color.stoneInk)
            Text("\(rows.count) total")
                .font(.caption)
                .foregroundStyle(Color.stoneMuted)
            ForEach(rows) { project in
                NavigationLink(value: CreativeRoute.project(project.id)) {
                    projectCard(project)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func ideaRow(_ idea: LikedIdea) -> some View {
        let row = VStack(alignment: .leading, spacing: 4) {
            Text(idea.text)
                .font(.subheadline)
                .foregroundStyle(Color.stoneInk)
            Text(idea.creatorName)
                .font(.caption)
                .foregroundStyle(Color.stoneMuted)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card)
        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))

        return Group {
            if let slug = idea.profileSlug, !slug.isEmpty {
                NavigationLink(value: CreativeRoute.profile(slug)) { row }
                    .buttonStyle(.plain)
            } else {
                row
            }
        }
    }

    private func projectCard(_ project: ManagedProject) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle().fill(Color.ecoOrange).frame(height: 3)
            if let url = AccountMedia.url(project.coverURL) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.stoneLine
                }
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .clipped()
            }
            Text(project.title)
                .font(.headline)
                .foregroundStyle(Color.stoneInk)
            HStack(spacing: 8) {
                if !project.categoryLabel.isEmpty {
                    Text(project.categoryLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.ecoOrange)
                }
                Text(project.isDraft ? "Draft" : "Published")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.stoneMuted)
                if let role = project.collabRole, !role.isEmpty {
                    Text(role)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.ecoOrange)
                }
            }
            if project.collabHidden == true {
                Text("Hidden from profile")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.stoneMuted)
            }
            Text("\(project.views) views · \(project.likesCount) likes · \(project.commentsCount) comments")
                .font(.caption)
                .foregroundStyle(Color.stoneMuted)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card)
        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
        .opacity(project.collabHidden == true ? 0.6 : 1)
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            board = try await client.managePortfolio()
            message = nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "Manage Portfolio isn't available from the app yet."
        }
    }
}

struct OwnProfileView: View {
    @Bindable var session: AppSession
    var showcase: Bool
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL
    @State private var settings: OwnSettings?
    @State private var message: String?
    @State private var loading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(showcase ? "My Showcase" : "Profile Settings")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                if loading { ProgressView() }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                if let settings {
                    if showcase {
                        showcaseBody(settings)
                    } else {
                        settingsBody(settings)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.stone)
        .navigationTitle(showcase ? "My Showcase" : "Profile Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    @ViewBuilder
    private func settingsBody(_ settings: OwnSettings) -> some View {
        block("About You") {
            line("Display Name", settings.displayName)
            line("Headline", settings.headline)
            line("Pronouns", settings.pronouns)
            line("Role", settings.role)
            line("Location", settings.location)
            paragraph("Bio", settings.bio)
            linkLine("Website", settings.website)
            linkLine("Showreel", settings.showreel)
            ForEach(settings.socialLinks.keys.sorted(), id: \.self) { key in
                linkLine(key.prefix(1).uppercased() + key.dropFirst(), settings.socialLinks[key])
            }
        }
        block("VFS Info") {
            line("Program", settings.program.map(CreativeLabels.program).joined(separator: ", "))
            line("Term", settings.term)
            line("Graduation Year", settings.graduationYear)
        }
        block("Skills & Tools") {
            line("Skills", settings.skills.joined(separator: ", "))
            line("Software", settings.software.joined(separator: ", "))
        }
        block("Availability") {
            line("Open to work", settings.openToWork ? "Yes" : "No")
            line("Open to collab", settings.openToCollab ? "Yes" : "No")
        }
        block("Privacy & URL") {
            line("Visibility", settings.visibility.prefix(1).uppercased() + settings.visibility.dropFirst())
        }
    }

    @ViewBuilder
    private func showcaseBody(_ settings: OwnSettings) -> some View {
        Text(settings.mediaTastePublic ? "Your showcase is visible on your public profile." : "Your showcase is hidden from your public profile.")
            .font(.subheadline)
            .foregroundStyle(Color.stoneMuted)
        block("Showcase Titles") {
            if settings.showcaseTitles.isEmpty {
                Text("No showcase titles yet.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
            } else {
                ForEach(settings.showcaseTitles, id: \.self) { title in
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.stoneInk)
                }
            }
        }
        block("Pitches") {
            if settings.pitches.isEmpty {
                Text("No pitches yet.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
            } else {
                ForEach(settings.pitches) { pitch in
                    VStack(alignment: .leading, spacing: 4) {
                        if let category = pitch.category, !category.isEmpty {
                            Text(CreativeLabels.category(category))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.ecoOrange)
                        }
                        Text(pitch.pitch)
                            .font(.subheadline)
                            .foregroundStyle(Color.stoneInk)
                        if let description = pitch.description, !description.isEmpty {
                            Text(description)
                                .font(.caption)
                                .foregroundStyle(Color.stoneMuted)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    private func block(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.stoneInk)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card)
        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
    }

    @ViewBuilder
    private func line(_ label: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.stoneMuted)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneInk)
            }
        }
    }

    @ViewBuilder
    private func paragraph(_ label: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.stoneMuted)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneInk)
            }
        }
    }

    @ViewBuilder
    private func linkLine(_ label: String, _ value: String?) -> some View {
        if let value, value.hasPrefix("http"), let url = URL(string: value) {
            Button {
                openURL(url)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.stoneMuted)
                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(Color.ecoOrange)
                        .multilineTextAlignment(.leading)
                }
            }
            .buttonStyle(.plain)
        } else {
            line(label, value)
        }
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            settings = try await client.ownProfile()
            message = nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "Profile Settings isn't available from the app yet."
        }
    }
}

enum AccountMedia {
    static func url(_ raw: String?) -> URL? {
        guard let raw, !raw.isEmpty else { return nil }
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            return URL(string: raw)
        }
        if raw.hasPrefix("/") {
            return URL(string: raw, relativeTo: APIConfiguration.baseURL)?.absoluteURL
        }
        return URL(string: raw)
    }
}
