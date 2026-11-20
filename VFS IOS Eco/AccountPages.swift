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
    @State private var notice: String?
    @State private var loading = false
    @State private var pendingDelete: ManagedProject?

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
                if let notice {
                    Text(notice).font(.subheadline).foregroundStyle(Color.ecoOrange)
                }
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
        .confirmationDialog("Delete this project?", isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }), titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let project = pendingDelete { Task { await remove(project) } }
            }
            Button("Cancel", role: .cancel) { pendingDelete = nil }
        } message: {
            Text(pendingDelete?.title ?? "")
        }
    }

    @ViewBuilder
    private func projects(_ rows: [ManagedProject]) -> some View {
        NavigationLink {
            CreateProjectView(session: session) { await load() }
        } label: {
            Text("Create New Project")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.ecoOrange)
        }
        .buttonStyle(.plain)
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
                VStack(alignment: .leading, spacing: 8) {
                    NavigationLink(value: CreativeRoute.project(project.id)) {
                        projectCard(project)
                    }
                    .buttonStyle(.plain)
                    HStack(spacing: 8) {
                        Button(project.isDraft ? "Publish" : "Unpublish") {
                            Task { await publish(project) }
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.ecoOrange)
                        Button("Delete") { pendingDelete = project }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255))
                    }
                }
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
                VStack(alignment: .leading, spacing: 8) {
                    NavigationLink(value: CreativeRoute.project(project.id)) {
                        projectCard(project)
                    }
                    .buttonStyle(.plain)
                    Button(project.collabHidden == true ? "Show on profile" : "Hide from profile") {
                        Task { await hide(project) }
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.ecoOrange)
                }
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

    private func publish(_ project: ManagedProject) async {
        notice = nil
        do {
            notice = try await client.toggleProjectPublish(id: project.id)
            await load()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The project could not be updated."
        }
    }

    private func remove(_ project: ManagedProject) async {
        pendingDelete = nil
        notice = nil
        do {
            notice = try await client.deleteProject(id: project.id)
            await load()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The project could not be deleted."
        }
    }

    private func hide(_ project: ManagedProject) async {
        notice = nil
        do {
            let hidden = try await client.toggleCollabHidden(id: project.id)
            notice = hidden ? "Hidden from profile." : "Shown on your profile."
            await load()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The collaboration could not be updated."
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
    @State private var notice: String?
    @State private var loading = false
    @State private var saving = false
    @State private var filled = false
    @State private var displayName = ""
    @State private var headline = ""
    @State private var pronouns = ""
    @State private var bio = ""
    @State private var role = ""
    @State private var location = ""
    @State private var website = ""
    @State private var showreel = ""
    @State private var social: [String: String] = [:]
    @State private var programs: [String] = []
    @State private var program = ""
    @State private var term = ""
    @State private var graduationYear = ""
    @State private var skills = ""
    @State private var software = ""
    @State private var openToWork = false
    @State private var openToCollab = false
    @State private var visibility = "public"
    @State private var mediaTastePublic = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(showcase ? "My Showcase" : "Profile Settings")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                if loading { ProgressView() }
                if let notice {
                    Text(notice).font(.subheadline).foregroundStyle(Color.ecoOrange)
                }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                if settings != nil {
                    if showcase {
                        showcaseEditor()
                    } else {
                        settingsEditor()
                    }
                    Button(saving ? "Saving…" : "Save") { Task { await save() } }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.ecoOrange)
                        .disabled(saving)
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

    private func settingsEditor() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            block("About You") {
                editorField("Display Name", text: $displayName)
                editorField("Headline", text: $headline)
                editorField("Pronouns", text: $pronouns)
                editorField("Role", text: $role)
                editorField("Location", text: $location)
                editorField("Bio", text: $bio, axis: .vertical)
                editorField("Website", text: $website)
                editorField("Showreel", text: $showreel)
                ForEach(Self.socialPlatforms, id: \.self) { key in
                    editorField(key.prefix(1).uppercased() + key.dropFirst(), text: socialBinding(key))
                }
            }
            block("VFS Info") {
                Picker("Program", selection: $program) {
                    Text("None").tag("")
                    ForEach(ProfilePrograms.options, id: \.key) { option in
                        Text(option.label).tag(option.key)
                    }
                }
                Picker("Term", selection: $term) {
                    Text("None").tag("")
                    ForEach(Self.terms, id: \.self) { Text($0).tag($0) }
                }
                editorField("Graduation Year", text: $graduationYear)
            }
            block("Skills & Tools") {
                editorField("Skills", text: $skills, prompt: "Comma separated")
                editorField("Software", text: $software, prompt: "Comma separated")
            }
            block("Availability") {
                Toggle("Open to work", isOn: $openToWork)
                Toggle("Open to collab", isOn: $openToCollab)
            }
            block("Privacy & URL") {
                Picker("Visibility", selection: $visibility) {
                    Text("Public").tag("public")
                    Text("Private").tag("private")
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private func showcaseEditor() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Show my showcase on my public profile", isOn: $mediaTastePublic)
            if let settings {
                showcaseBody(settings)
            }
        }
    }

    private func editorField(_ label: String, text: Binding<String>, prompt: String = "", axis: Axis = .horizontal) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.stoneMuted)
            TextField(prompt, text: text, axis: axis)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func socialBinding(_ key: String) -> Binding<String> {
        Binding(get: { social[key] ?? "" }, set: { social[key] = $0 })
    }

    private static let terms = ["Alumni", "Term 1", "Term 2", "Term 3", "Term 4", "Term 5", "Term 6"]
    private static let socialPlatforms = ["instagram", "facebook", "linkedin", "twitter", "tiktok", "youtube", "behance", "dribbble", "vimeo", "github", "soundcloud", "artstation", "discord", "bluesky", "steam", "itch"]

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
            let page = try await client.ownProfile()
            settings = page
            message = nil
            if !filled { fill(page) }
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "Profile Settings isn't available from the app yet."
        }
    }

    private func fill(_ page: OwnSettings) {
        displayName = page.displayName ?? ""
        headline = page.headline ?? ""
        pronouns = page.pronouns ?? ""
        bio = page.bio ?? ""
        role = page.role ?? ""
        location = page.location ?? ""
        website = page.website ?? ""
        showreel = page.showreel ?? ""
        social = page.socialLinks
        programs = page.program
        program = page.program.first ?? ""
        term = page.term ?? ""
        graduationYear = page.graduationYear ?? ""
        skills = page.skills.joined(separator: ", ")
        software = page.software.joined(separator: ", ")
        openToWork = page.openToWork
        openToCollab = page.openToCollab
        visibility = page.visibility
        mediaTastePublic = page.mediaTastePublic
        filled = true
    }

    private func save() async {
        saving = true
        notice = nil
        message = nil
        defer { saving = false }
        do {
            notice = try await client.saveProfile(payload())
            await session.refresh()
            filled = false
            await load()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The profile could not be saved."
        }
    }

    private func payload() -> [String: Any] {
        var body: [String: Any] = [
            "display_name": displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            "headline": headline.trimmingCharacters(in: .whitespacesAndNewlines),
            "pronouns": pronouns.trimmingCharacters(in: .whitespacesAndNewlines),
            "bio": bio.trimmingCharacters(in: .whitespacesAndNewlines),
            "role": role.trimmingCharacters(in: .whitespacesAndNewlines),
            "location": location.trimmingCharacters(in: .whitespacesAndNewlines),
            "skills": commaList(skills),
            "software": commaList(software),
            "open_to_work": openToWork,
            "open_to_collab": openToCollab,
            "visibility": visibility,
            "media_taste_public": mediaTastePublic,
        ]
        if !programs.isEmpty, program == programs.first {
            body["program"] = programs
        } else if !program.isEmpty {
            body["program"] = [program]
        }
        if !term.isEmpty { body["term"] = term }
        let year = graduationYear.trimmingCharacters(in: .whitespacesAndNewlines)
        if !year.isEmpty { body["graduation_year"] = year }
        if let site = https(website) { body["website_url"] = site }
        if let reel = https(showreel) { body["showreel_url"] = reel }
        var links: [String: String] = [:]
        for key in Self.socialPlatforms {
            if let url = https(social[key] ?? "") { links[key] = url }
        }
        if !links.isEmpty { body["social_links"] = links }
        return body
    }

    private func commaList(_ raw: String) -> [String] {
        raw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }

    private func https(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") { return trimmed }
        return "https://\(trimmed)"
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

struct CreateProjectView: View {
    @Bindable var session: AppSession
    var onSaved: () async -> Void
    var client: APIClient = APIClient()
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var details = ""
    @State private var category = "film_production"
    @State private var published = true
    @State private var professional = false
    @State private var message: String?
    @State private var saving = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Create New Project")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                field("Title", text: $title)
                field("Description", text: $details)
                Picker("Category", selection: $category) {
                    ForEach(ProfilePrograms.options, id: \.key) { option in
                        Text(option.label).tag(option.key)
                    }
                    Text("Other").tag("other")
                }
                Toggle("Published", isOn: $published)
                Toggle("Professional Portfolio", isOn: $professional)
                Text("Mark this project for industry review. Industry accounts with portfolio access can see it on their board. Other students still see your work the same way.")
                    .font(.caption)
                    .foregroundStyle(Color.stoneMuted)
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                Button(saving ? "Saving…" : (published ? "Publish Project" : "Save Draft")) {
                    Task { await save() }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.ecoOrange)
                .disabled(saving || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("New Project")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func field(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption.weight(.semibold)).foregroundStyle(Color.stoneMuted)
            TextField(label, text: text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func save() async {
        saving = true
        message = nil
        defer { saving = false }
        var body: [String: Any] = [
            "title": title.trimmingCharacters(in: .whitespacesAndNewlines),
            "category": category,
            "is_published": published,
            "is_professional": professional,
        ]
        let copy = details.trimmingCharacters(in: .whitespacesAndNewlines)
        if !copy.isEmpty { body["description"] = copy }
        do {
            _ = try await client.createProject(body)
            await onSaved()
            dismiss()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The project could not be created."
        }
    }
}
