import PhotosUI
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
        .onAppear {
            guard board != nil else { return }
            Task { await load() }
        }
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
        CreativeLink(route: CreativeRoute.createProject) {
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
                    CreativeLink(route: CreativeRoute.project(project.id)) {
                        projectCard(project)
                    }
                    .buttonStyle(.plain)
                    HStack(spacing: 8) {
                        CreativeLink(route: CreativeRoute.editProject(project.id)) {
                            Text("Edit")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.ecoOrange)
                        }
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
                    CreativeLink(route: CreativeRoute.project(project.id)) {
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
                    CreativeLink(route: CreativeRoute.project(project.id)) {
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
                CreativeLink(route: CreativeRoute.profile(slug)) { row }
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
    var projectID: Int? = nil
    var onSaved: () async -> Void
    var client: APIClient = APIClient()
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var details = ""
    @State private var category = "film_production"
    @State private var published = true
    @State private var professional = false
    @State private var tags: [String] = []
    @State private var tagDraft = ""
    @State private var tools: [String] = []
    @State private var toolDraft = ""
    @State private var people: [ProjectCredit] = []
    @State private var creditName = ""
    @State private var creditRole = ""
    @State private var links: [ProjectLinkDraft] = []
    @State private var linkLabel = ""
    @State private var linkURL = ""
    @State private var coverItem: PhotosPickerItem?
    @State private var coverData: Data?
    @State private var mediaItems: [PhotosPickerItem] = []
    @State private var mediaData: [Data] = []
    @State private var embeds: [String] = []
    @State private var savedEmbeds: [String] = []
    @State private var embedDraft = ""
    @State private var gameLinks: [String] = []
    @State private var savedGames: [String] = []
    @State private var gameDraft = ""
    @State private var models: [String] = []
    @State private var savedModels: [String] = []
    @State private var modelDraft = ""
    @State private var existingMedia: [EditorMedia] = []
    @State private var removedMedia: [Int] = []
    @State private var existingCover: String?
    @State private var message: String?
    @State private var saving = false

    private let tagPresets = ["Short Film", "Student Film", "Thesis Project", "Demo Reel", "Concept Art", "Character Design", "Storyboard", "Animatic", "Group Project", "Solo Project"]
    private let toolPresets = ["C#", "C++", "JavaScript", "TypeScript", "Python", "Lua", "HLSL", "GLSL", "PHP", "SQL", "HTML", "CSS"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(projectID == nil ? "Create New Project" : "Edit Project")
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
                coverPicker
                if !keptMedia.isEmpty {
                    Text("Current media")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.stoneMuted)
                    ForEach(keptMedia) { item in
                        HStack {
                            Text(item.type ?? "Media")
                                .font(.caption)
                                .foregroundStyle(Color.stoneInk)
                            Spacer()
                            Button("Remove") { removedMedia.append(item.id) }
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255))
                        }
                    }
                }
                galleryPicker
                urlList("YouTube / Vimeo", placeholder: "YouTube or Vimeo URL...", saved: savedEmbeds, items: embeds, draft: $embedDraft, add: addEmbed)
                urlList("Game Link", placeholder: "https://yourgame.itch.io/... or Steam / Epic Games Store link", saved: savedGames, items: gameLinks, draft: $gameDraft, add: addGame)
                urlList("3D Viewer", placeholder: "Sketchfab model page or skfb.ly link", saved: savedModels, items: models, draft: $modelDraft, add: addModel)
                chips("Tags", help: "Freeform topic, skill, or genre tags to help people find this project. Not for term or program affiliation.", presets: tagPresets, selected: tags, draft: $tagDraft) { toggleTag($0) }
                chips("Tools Used", help: "Programming languages", presets: toolPresets, selected: tools, draft: $toolDraft) { toggleTool($0) }
                collaborators
                projectLinks
                Toggle("Published", isOn: $published)
                Toggle("Professional Portfolio", isOn: $professional)
                Text("Mark this project for industry review. Industry accounts with portfolio access can see it on their board. Other students still see your work the same way.")
                    .font(.caption)
                    .foregroundStyle(Color.stoneMuted)
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                Button(saving ? "Saving…" : (projectID == nil ? (published ? "Publish Project" : "Save Draft") : "Save Project")) {
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
        .navigationTitle(projectID == nil ? "New Project" : "Edit Project")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadEditor() }
    }

    private var keptMedia: [EditorMedia] {
        existingMedia.filter { !removedMedia.contains($0.id) }
    }

    private func loadEditor() async {
        guard let projectID else { return }
        do {
            let editor = try await client.projectEditor(id: projectID)
            title = editor.title
            details = editor.description ?? ""
            if let category = editor.category, !category.isEmpty { self.category = category }
            published = editor.isPublished
            professional = editor.isProfessional
            tags = editor.tags
            tools = editor.toolsUsed
            people = editor.collaborators.map { ProjectCredit(name: $0.name, role: $0.role ?? "") }
            links = editor.externalLinks.map { ProjectLinkDraft(label: $0.label ?? "", url: $0.url) }
            savedEmbeds = editor.videoEmbeds
            savedGames = editor.gameLinks
            savedModels = editor.modelEmbeds
            existingCover = editor.coverURL
            existingMedia = editor.media
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This project can't be edited from the app yet."
        }
    }

    private var coverPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cover")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.stoneMuted)
            if coverData == nil, let existingCover, let url = AccountMedia.url(existingCover) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.stoneLine
                }
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .clipped()
            }
            if let coverData, let image = UIImage(data: coverData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
            PhotosPicker(selection: $coverItem, matching: .images) {
                Text(coverData == nil ? "Choose Cover" : "Replace Cover")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.ecoOrange)
            }
            .onChange(of: coverItem) { _, item in
                Task { coverData = await Self.jpeg(item) }
            }
        }
    }

    private var galleryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Media")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.stoneMuted)
            if !mediaData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(mediaData.enumerated()), id: \.offset) { _, data in
                            if let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .clipped()
                            }
                        }
                    }
                }
            }
            PhotosPicker(selection: $mediaItems, maxSelectionCount: 12, matching: .images) {
                Text(mediaData.isEmpty ? "Add Images" : "Replace Images")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.ecoOrange)
            }
            .onChange(of: mediaItems) { _, items in
                Task {
                    var files: [Data] = []
                    for item in items {
                        if let jpeg = await Self.jpeg(item) { files.append(jpeg) }
                    }
                    mediaData = files
                }
            }
        }
    }

    private func urlList(_ title: String, placeholder: String, saved: [String] = [], items: [String], draft: Binding<String>, add: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(Color.stoneMuted)
            HStack {
                TextField(placeholder, text: draft)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Button("Add", action: add)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.ecoOrange)
            }
            ForEach(saved, id: \.self) { item in
                Text(item).font(.caption).foregroundStyle(Color.stoneMuted).lineLimit(1)
            }
            ForEach(items, id: \.self) { item in
                Text(item).font(.caption).foregroundStyle(Color.stoneInk).lineLimit(1)
            }
        }
    }

    private func addEmbed() { push(&embeds, embedDraft, saved: savedEmbeds) { embedDraft = "" } }
    private func addGame() { push(&gameLinks, gameDraft, saved: savedGames) { gameDraft = "" } }
    private func addModel() { push(&models, modelDraft, saved: savedModels) { modelDraft = "" } }

    private func push(_ list: inout [String], _ raw: String, saved: [String] = [], clear: () -> Void) {
        guard let url = https(raw), list.count + saved.count < 10, !list.contains(url), !saved.contains(url) else { return }
        list.append(url)
        clear()
    }

    private static func jpeg(_ item: PhotosPickerItem?) async -> Data? {
        guard let data = try? await item?.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return nil }
        return image.jpegData(compressionQuality: 0.85)
    }

    private func chips(_ title: String, help: String, presets: [String], selected: [String], draft: Binding<String>, toggleItem: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(Color.stoneMuted)
            Text(help).font(.caption).foregroundStyle(Color.stoneMuted)
            FlowTags(items: presets, selected: selected, toggle: toggleItem)
            HStack {
                TextField("Add a tag...", text: draft)
                    .textFieldStyle(.roundedBorder)
                Button("Add") { toggleItem(draft.wrappedValue); draft.wrappedValue = "" }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.ecoOrange)
            }
        }
    }

    private var collaborators: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Collaborators").font(.caption.weight(.semibold)).foregroundStyle(Color.stoneMuted)
            field("Name", text: $creditName)
            field("Role (e.g. Animator)", text: $creditRole)
            Button("Add collaborator") {
                let name = creditName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { return }
                people.append(ProjectCredit(name: name, role: creditRole.trimmingCharacters(in: .whitespacesAndNewlines)))
                creditName = ""
                creditRole = ""
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.ecoOrange)
            ForEach(people) { person in
                HStack {
                    Text(person.role.isEmpty ? person.name : "\(person.name) · \(person.role)")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneInk)
                    Spacer()
                    Button("Remove") { people.removeAll { $0.id == person.id } }
                        .font(.caption)
                        .foregroundStyle(Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255))
                }
            }
        }
    }

    private var projectLinks: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Project Links").font(.caption.weight(.semibold)).foregroundStyle(Color.stoneMuted)
            field("Label", text: $linkLabel)
            field("https://", text: $linkURL)
            Button("Add link") {
                let url = https(linkURL)
                guard let url else { return }
                links.append(ProjectLinkDraft(label: linkLabel.trimmingCharacters(in: .whitespacesAndNewlines), url: url))
                linkLabel = ""
                linkURL = ""
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.ecoOrange)
            ForEach(links) { link in
                HStack {
                    Text(link.label.isEmpty ? link.url : "\(link.label) · \(link.url)")
                        .font(.caption)
                        .foregroundStyle(Color.stoneInk)
                    Spacer()
                    Button("Remove") { links.removeAll { $0.id == link.id } }
                        .font(.caption)
                        .foregroundStyle(Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255))
                }
            }
        }
    }

    private func field(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption.weight(.semibold)).foregroundStyle(Color.stoneMuted)
            TextField(label, text: text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func toggleTag(_ raw: String) { toggle(&tags, raw) }
    private func toggleTool(_ raw: String) { toggle(&tools, raw) }

    private func toggle(_ list: inout [String], _ raw: String) {
        let item = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !item.isEmpty else { return }
        if let index = list.firstIndex(where: { $0.caseInsensitiveCompare(item) == .orderedSame }) {
            list.remove(at: index)
        } else if list.count < 20 {
            list.append(item)
        }
    }

    private func https(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if trimmed.lowercased().hasPrefix("https://") { return trimmed }
        if trimmed.lowercased().hasPrefix("http://") { return "https://" + trimmed.dropFirst(7) }
        return "https://\(trimmed)"
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
        if !tags.isEmpty { body["tags"] = tags }
        if !tools.isEmpty { body["tools_used"] = tools }
        let credits = people.map { person -> [String: String] in
            person.role.isEmpty ? ["name": person.name] : ["name": person.name, "role": person.role]
        }
        if !credits.isEmpty { body["collaborators"] = credits }
        let urls = links.map { link -> [String: String] in
            link.label.isEmpty ? ["url": link.url] : ["url": link.url, "label": link.label]
        }
        if !urls.isEmpty { body["external_links"] = urls }
        do {
            if !embeds.isEmpty { body["new_video_embeds"] = embeds }
            if !gameLinks.isEmpty { body["new_game_links"] = gameLinks }
            if !models.isEmpty { body["new_3d_embeds"] = models }
            if !removedMedia.isEmpty { body["remove_media_ids"] = removedMedia }
            if let projectID {
                _ = try await client.updateProject(id: projectID, body: body, cover: coverData, media: mediaData)
            } else {
                _ = try await client.createProject(body, cover: coverData, coverName: "cover.jpg", media: mediaData)
            }
            await onSaved()
            dismiss()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = projectID == nil ? "The project could not be created." : "The project could not be saved."
        }
    }
}

private struct ProjectCredit: Identifiable {
    let id = UUID()
    var name: String
    var role: String
}

private struct ProjectLinkDraft: Identifiable {
    let id = UUID()
    var label: String
    var url: String
}

private struct FlowTags: View {
    var items: [String]
    var selected: [String]
    var toggle: (String) -> Void

    var body: some View {
        FlexibleTagWrap(items: items, selected: selected, toggle: toggle)
    }
}

private struct FlexibleTagWrap: View {
    var items: [String]
    var selected: [String]
    var toggle: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { item in
                        let on = selected.contains { $0.caseInsensitiveCompare(item) == .orderedSame }
                        Button(item) { toggle(item) }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(on ? Color.ecoOrange : Color.stoneInk)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(on ? Color.ecoOrange.opacity(0.1) : Color.card)
                            .overlay(Capsule().stroke(on ? Color.ecoOrange : Color.stoneLine, lineWidth: 1))
                    }
                }
            }
        }
    }

    private var rows: [[String]] {
        stride(from: 0, to: items.count, by: 3).map { start in
            Array(items[start..<min(start + 3, items.count)])
        }
    }
}
