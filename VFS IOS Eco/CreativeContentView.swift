import SwiftUI

struct ProjectDetailView: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL
    @State private var project: ProjectDetail?
    @State private var comments: [ProjectComment] = []
    @State private var commentDraft = ""
    @State private var notice: String?
    @State private var phase: LoadPhase = .loading

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                switch phase {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    Text(message).foregroundStyle(Color.stoneInk)
                case .ready:
                    if let project {
                        cover(project.coverURL)
                        Text(project.title)
                            .font(.system(size: 40, weight: .bold, design: .serif))
                            .foregroundStyle(Color.stoneInk)
                        if !project.programLabel.isEmpty {
                            Text(project.programLabel)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.ecoOrange)
                        }
                        if let category = project.category, let label = PortfolioView.categoryLabel(category), !label.isEmpty {
                            Text(label).font(.subheadline).foregroundStyle(Color.stoneMuted)
                        }
                        if let owner = project.ownerName, !owner.isEmpty {
                            if let slug = project.profileSlug, !slug.isEmpty {
                                CreativeLink(route: CreativeRoute.profile(slug)) {
                                    Text(owner).font(.headline)
                                }
                                .tint(Color.ecoOrange)
                            } else {
                                Text(owner).font(.headline).foregroundStyle(Color.stoneInk)
                            }
                        }
                        HStack {
                            Text(project.liked ? "\(project.likesCount) likes · You liked this" : "\(project.likesCount) likes")
                                .font(.caption)
                                .foregroundStyle(Color.stoneMuted)
                            Spacer()
                            Button(project.liked ? "Liked" : "Like") { Task { await like() } }
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.ecoOrange)
                        }
                        if let notice {
                            Text(notice).font(.caption).foregroundStyle(Color.stoneMuted)
                        }
                        ForEach(comments) { comment in
                            VStack(alignment: .leading, spacing: 4) {
                                if !comment.author.isEmpty {
                                    Text(comment.author).font(.caption.weight(.semibold)).foregroundStyle(Color.stoneInk)
                                }
                                Text(comment.body).font(.subheadline).foregroundStyle(Color.stoneMuted)
                                if comment.userID == session.account?.user.id {
                                    Button("Remove") { Task { await remove(comment) } }
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255))
                                }
                            }
                        }
                        TextField("Write a comment", text: $commentDraft, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                        Button("Post comment") { Task { await postComment() } }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.ecoOrange)
                            .disabled(commentDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        if let description = project.description, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundStyle(Color.stoneMuted)
                        }
                        if !project.tools.isEmpty {
                            Text(project.tools.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundStyle(Color.stoneInk)
                        }
                        ForEach(project.media) { item in
                            if item.type == "image", let url = AccountMedia.url(item.url) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    Color.stoneLine.frame(height: 160)
                                }
                                .frame(maxWidth: .infinity)
                            } else if let address = item.url, let url = AccountMedia.url(address) ?? URL(string: address) {
                                Button(item.type?.isEmpty == false ? (item.type ?? "Open") : "Open") {
                                    openURL(url)
                                }
                                .tint(Color.ecoOrange)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Project")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        do {
            project = try await client.project(id: id)
            phase = .ready
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            phase = .failed(error.message)
        } catch {
            phase = .failed("This project could not be loaded.")
        }
    }

    private func like() async {
        do {
            let result = try await client.likeProject(id: id)
            if var current = project {
                current.liked = result.liked
                current.likesCount = result.likesCount
                project = current
            }
            notice = nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            notice = text
        } catch {
            notice = "The like could not be saved."
        }
    }

    private func postComment() async {
        let body = commentDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else { return }
        do {
            let comment = try await client.commentOnProject(id: id, body: body)
            comments.append(comment)
            commentDraft = ""
            notice = nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            notice = text
        } catch {
            notice = "The comment could not be posted."
        }
    }

    private func remove(_ comment: ProjectComment) async {
        do {
            notice = try await client.deleteComment(id: comment.id)
            comments.removeAll { $0.id == comment.id }
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            notice = text
        } catch {
            notice = "The comment could not be removed."
        }
    }
}

struct ProfileDetailView: View {
    @Bindable var session: AppSession
    var slug: String
    var client: APIClient = APIClient()
    @State private var profile: CreativeProfileDetail?
    @State private var phase: LoadPhase = .loading

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                switch phase {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    Text(message).foregroundStyle(Color.stoneInk)
                case .ready:
                    if let profile {
                        Text(profile.name ?? slug)
                            .font(.system(size: 40, weight: .bold, design: .serif))
                            .foregroundStyle(Color.stoneInk)
                        if let headline = profile.headline, !headline.isEmpty {
                            Text(headline).font(.body).foregroundStyle(Color.stoneMuted)
                        }
                        if let program = profile.programLabel, !program.isEmpty {
                            Text(program).font(.subheadline.weight(.semibold)).foregroundStyle(Color.ecoOrange)
                        }
                        if let location = profile.location, !location.isEmpty {
                            Text(location).font(.subheadline).foregroundStyle(Color.stoneMuted)
                        }
                        if profile.openToWork {
                            Text("Open to work").font(.caption.weight(.semibold)).foregroundStyle(Color.ecoOrange)
                        }
                        if profile.openToCollab {
                            Text("Open to collab").font(.caption.weight(.semibold)).foregroundStyle(Color.ecoOrange)
                        }
                        if !profile.skills.isEmpty {
                            Text(profile.skills.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundStyle(Color.stoneInk)
                        }
                        ForEach(profile.projects) { project in
                            CreativeLink(route: CreativeRoute.project(project.id)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(project.title).font(.headline).foregroundStyle(Color.stoneInk)
                                    if let category = project.category, let label = PortfolioView.categoryLabel(category) {
                                        Text(label).font(.caption).foregroundStyle(Color.ecoOrange)
                                    }
                                    Text("\(project.likesCount) likes")
                                        .font(.caption)
                                        .foregroundStyle(Color.stoneMuted)
                                }
                                .guideCard()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        do {
            profile = try await client.profile(slug: slug)
            phase = .ready
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            phase = .failed(error.message)
        } catch {
            phase = .failed("This profile could not be loaded.")
        }
    }
}

struct CollabsView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @State private var board: CollabBoard?
    @State private var collabs: [CollabCard] = []
    @State private var search = ""
    @State private var type = ""
    @State private var role = ""
    @State private var paidOnly = false
    @State private var roleType = ""
    @State private var archived = false
    @State private var phase: LoadPhase = .loading
    @State private var loadingMore = false

    private let projectTypes = ["Short Film", "Music Video", "Animation", "Game", "Web Series", "Podcast", "ADR / Redubbing", "Portfolio Piece", "Other"]
    private let commonRoles = ["Actor", "Director", "Producer", "Cinematographer", "Editor", "Sound Designer", "Composer", "VFX Artist", "Makeup Artist", "Hair Stylist", "Writer", "Animator", "Voice Actor", "Gaffer", "Set Designer", "3D Artist", "Colorist", "Storyboard Artist"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Rectangle().fill(Color.collabPurple).frame(width: 12, height: 3)
                    Text("STUDENT & ALUMNI PROJECTS")
                        .font(.system(size: 11, weight: .medium))
                        .tracking(1.4)
                        .foregroundStyle(Color.stoneMuted)
                }
                CreativeHeadline(
                    lead: "Make Something\n",
                    accent: "Together",
                    accentColor: .collabPurple,
                    detail: "Find collaborators for your next project: short films, games, music videos, and beyond."
                )
                CreativeLink(route: .createCollab) {
                    Text("Post a collaboration")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.collabPurple)
                }
                .buttonStyle(.plain)
                CreativeSearchField(placeholder: "Search by project name, description, or role…", text: $search, identifier: "collab-search") {
                    Task { await reload() }
                }
                filterRow

                switch phase {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    Text(message).foregroundStyle(Color.stoneInk)
                case .ready:
                    if let total = board?.collabs.total, total > 0 {
                        Text("\(total) post\(total == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundStyle(Color.stoneMuted)
                    }
                    if collabs.isEmpty {
                        Text(filtersActive ? "No posts match your filters." : "No collaborations found.")
                            .font(.body)
                            .foregroundStyle(Color.stoneMuted)
                    } else {
                        ForEach(collabs) { collab in
                            CreativeLink(route: CreativeRoute.collab(collab.id)) {
                                collabCard(collab)
                            }
                            .buttonStyle(.plain)
                        }
                        if board?.collabs.hasMore == true {
                            Button(loadingMore ? "Loading" : "Load more") {
                                Task { await loadMore() }
                            }
                            .buttonStyle(.bordered)
                            .tint(Color.collabPurple)
                            .disabled(loadingMore)
                        }
                    }
                }
                SiteFooter(session: session)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Student & Alumni Projects")
        .navigationBarTitleDisplayMode(.inline)
        .task { await reload() }
    }

    private var filtersActive: Bool {
        !type.isEmpty || !role.isEmpty || paidOnly || !roleType.isEmpty || archived || !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var filterRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip("Active", on: !archived) { archived = false; Task { await reload() } }
                    filterChip("Archived", on: archived) { archived = true; Task { await reload() } }
                    filterChip("Paid", on: paidOnly) { paidOnly.toggle(); Task { await reload() } }
                    filterChip("Crew Calls", on: roleType == "crew") { roleType = roleType == "crew" ? "" : "crew"; Task { await reload() } }
                    filterChip("Casting Calls", on: roleType == "cast") { roleType = roleType == "cast" ? "" : "cast"; Task { await reload() } }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip("All types", on: type.isEmpty) { type = ""; Task { await reload() } }
                    ForEach(projectTypes, id: \.self) { item in
                        filterChip(item, on: type == item) { type = item; Task { await reload() } }
                    }
                }
            }
            Menu {
                Button("All Roles") { role = ""; Task { await reload() } }
                ForEach(commonRoles, id: \.self) { item in
                    Button(item) { role = item; Task { await reload() } }
                }
            } label: {
                Text(role.isEmpty ? "All Roles" : role)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundStyle(role.isEmpty ? Color.stoneMuted : Color.collabPurple)
                    .background(role.isEmpty ? Color.card : Color.collabPurple.opacity(0.12))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(role.isEmpty ? Color.stoneLine : Color.collabPurple.opacity(0.45), lineWidth: 1))
            }
            if filtersActive {
                Button("Clear all") {
                    type = ""
                    role = ""
                    paidOnly = false
                    roleType = ""
                    archived = false
                    search = ""
                    Task { await reload() }
                }
                .buttonStyle(.plain)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255))
            }
        }
    }

    private func filterChip(_ title: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(on ? Color.collabPurple : Color.stoneMuted)
                .background(on ? Color.collabPurple.opacity(0.12) : Color.card)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(on ? Color.collabPurple.opacity(0.45) : Color.stoneLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func collabCard(_ collab: CollabCard) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let url = PortfolioProject.coverURL(collab.coverURL) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.stoneLine
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipped()
            }
            VStack(alignment: .leading, spacing: 8) {
                if let type = collab.type, !type.isEmpty {
                    Text(type)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.stoneInk)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.stone)
                        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
                }
                Text(collab.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                    .multilineTextAlignment(.leading)
                if let role = collab.role, !role.isEmpty {
                    let labels = role.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                    FlowRoles(labels: Array(labels.prefix(3)), extra: max(0, labels.count - 3))
                }
                HStack(spacing: 6) {
                    if let owner = collab.ownerName, !owner.isEmpty {
                        Text(owner).font(.caption).foregroundStyle(Color.stoneMuted)
                    }
                    if let deadline = collab.deadline, !deadline.isEmpty {
                        Text("Due \(deadline)").font(.caption.weight(.semibold)).foregroundStyle(Color.collabPurple)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.card)
        .overlay(alignment: .leading) { Rectangle().fill(Color.collabPurple).frame(width: 3) }
        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
    }

    private func reload() async {
        phase = .loading
        do {
            let page = try await client.collabs(search: search, page: 1, type: type, role: role, paidOnly: paidOnly, roleType: roleType, board: archived ? "archived" : "active")
            board = page
            collabs = page.collabs.data
            phase = .ready
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            phase = .failed(error.message)
        } catch {
            phase = .failed("Collabs could not be loaded.")
        }
    }

    private func loadMore() async {
        guard let board, board.collabs.hasMore, !loadingMore else { return }
        loadingMore = true
        defer { loadingMore = false }
        do {
            let page = try await client.collabs(search: search, page: board.collabs.currentPage + 1, type: type, role: role, paidOnly: paidOnly, roleType: roleType, board: archived ? "archived" : "active")
            self.board = page
            let existing = Set(collabs.map(\.id))
            collabs.append(contentsOf: page.collabs.data.filter { !existing.contains($0.id) })
        } catch APIError.unauthorized {
            session.signOut()
        } catch {
        }
    }
}

private struct FlowRoles: View {
    var labels: [String]
    var extra: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(labels.enumerated()), id: \.offset) { _, label in
                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.collabPurple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.collabPurple.opacity(0.35), lineWidth: 1))
            }
            if extra > 0 {
                Text("+\(extra)")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.stoneMuted)
            }
        }
    }
}

struct CollabDetailView: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL
    @State private var collab: CollabCard?
    @State private var phase: LoadPhase = .loading
    @State private var inquiryName = ""
    @State private var inquiryEmail = ""
    @State private var inquiryRole = ""
    @State private var inquiryReel = ""
    @State private var inquiryMessage = ""
    @State private var inquiryNotice: String?
    @State private var sendingInquiry = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                switch phase {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    Text(message).foregroundStyle(Color.stoneInk)
                case .ready:
                    if let collab {
                        if let url = PortfolioProject.coverURL(collab.coverURL) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.stoneLine
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipped()
                        }
                        Text(collab.title)
                            .font(.system(size: 40, weight: .bold, design: .serif))
                            .foregroundStyle(Color.stoneInk)
                        if let type = collab.type, !type.isEmpty {
                            Text(type).font(.subheadline.weight(.semibold)).foregroundStyle(Color.ecoOrange)
                        }
                        if let role = collab.role, !role.isEmpty {
                            Text(role).font(.body).foregroundStyle(Color.stoneInk)
                        }
                        if let owner = collab.ownerName, !owner.isEmpty {
                            Text(owner).font(.subheadline).foregroundStyle(Color.stoneMuted)
                        }
                        if let deadline = collab.deadline, !deadline.isEmpty {
                            Text("Apply by \(deadline)").font(.subheadline).foregroundStyle(Color.stoneMuted)
                        }
                        if let window = shootWindow(collab) {
                            Text("Shoot \(window)").font(.subheadline).foregroundStyle(Color.stoneMuted)
                        }
                        if let location = collab.location, !location.isEmpty {
                            Text(location).font(.subheadline).foregroundStyle(Color.stoneMuted)
                        }
                        if collab.remote == true {
                            Text("People can join remotely").font(.caption.weight(.semibold)).foregroundStyle(Color.ecoOrange)
                        }
                        if collab.paid == true {
                            Text("Paid").font(.caption.weight(.semibold)).foregroundStyle(Color.ecoOrange)
                        }
                        if let description = collab.description, !description.isEmpty {
                            Text(description).font(.body).foregroundStyle(Color.stoneMuted)
                        }
                        if let instructions = collab.contactInstructions, !instructions.isEmpty {
                            Text(instructions).font(.body).foregroundStyle(Color.stoneInk)
                        }
                        if let link = collab.applyURL, let url = URL(string: link) {
                            Button(link) { openURL(url) }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.collabPurple)
                        }
                        if collab.showContactButton == false {
                            EmptyView()
                        } else {
                        Text("Inquire")
                            .font(.headline)
                            .foregroundStyle(Color.stoneInk)
                            .padding(.top, 8)
                        TextField("Name", text: $inquiryName).textFieldStyle(.roundedBorder)
                        TextField("Email", text: $inquiryEmail).textFieldStyle(.roundedBorder)
                        TextField("Role", text: $inquiryRole).textFieldStyle(.roundedBorder)
                        TextField("https:// reel", text: $inquiryReel).textFieldStyle(.roundedBorder)
                        TextField("Message", text: $inquiryMessage, axis: .vertical).textFieldStyle(.roundedBorder)
                        Button(sendingInquiry ? "Sending…" : "Send inquiry") { Task { await inquire() } }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.collabPurple)
                            .disabled(sendingInquiry)
                        if let inquiryNotice {
                            Text(inquiryNotice).font(.caption).foregroundStyle(Color.stoneMuted)
                        }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Collab")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if inquiryName.isEmpty { inquiryName = session.account?.user.name ?? "" }
            if inquiryEmail.isEmpty { inquiryEmail = session.account?.user.email ?? "" }
            await load()
        }
    }

    private func shootWindow(_ collab: CollabCard) -> String? {
        let start = collab.shootStart?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let end = collab.shootEnd?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !start.isEmpty, !end.isEmpty { return "\(start) – \(end)" }
        if !start.isEmpty { return start }
        if !end.isEmpty { return end }
        return nil
    }

    private func load() async {
        do {
            collab = try await client.collab(id: id)
            phase = .ready
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            phase = .failed(error.message)
        } catch {
            phase = .failed("This collab could not be loaded.")
        }
    }

    private func inquire() async {
        sendingInquiry = true
        inquiryNotice = nil
        defer { sendingInquiry = false }
        var body: [String: Any] = [
            "name": inquiryName.trimmingCharacters(in: .whitespacesAndNewlines),
            "email": inquiryEmail.trimmingCharacters(in: .whitespacesAndNewlines),
            "message": inquiryMessage.trimmingCharacters(in: .whitespacesAndNewlines),
        ]
        let role = inquiryRole.trimmingCharacters(in: .whitespacesAndNewlines)
        if !role.isEmpty { body["role_applied_for"] = role }
        let reel = inquiryReel.trimmingCharacters(in: .whitespacesAndNewlines)
        if !reel.isEmpty { body["reel_url"] = reel }
        do {
            try await client.sendCollabInquiry(id: id, body: body)
            inquiryMessage = ""
            inquiryNotice = "Sent."
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            inquiryNotice = text
        } catch {
            inquiryNotice = "The inquiry could not be sent."
        }
    }
}

struct JobDetailView: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL
    @State private var job: JobCard?
    @State private var coverLetter = ""
    @State private var notice: String?
    @State private var applying = false
    @State private var phase: LoadPhase = .loading

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                switch phase {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    Text(message).foregroundStyle(Color.stoneInk)
                case .ready:
                    if let job {
                        Text(job.title)
                            .font(.system(size: 40, weight: .bold, design: .serif))
                            .foregroundStyle(Color.stoneInk)
                        if let company = job.company, !company.isEmpty {
                            Text(company).font(.title3).foregroundStyle(Color.ecoOrange)
                        }
                        if let location = job.location, !location.isEmpty {
                            Text(location).font(.subheadline).foregroundStyle(Color.stoneMuted)
                        }
                        if let type = job.type, !type.isEmpty {
                            Text(type.replacingOccurrences(of: "_", with: " "))
                                .font(.subheadline)
                                .foregroundStyle(Color.stoneInk)
                        }
                        if let level = job.level, !level.isEmpty {
                            Text(level.replacingOccurrences(of: "_", with: " "))
                                .font(.subheadline)
                                .foregroundStyle(Color.stoneInk)
                        }
                        if job.remote {
                            Text("Remote").font(.caption.weight(.semibold)).foregroundStyle(Color.ecoOrange)
                        }
                        if let posted = job.postedAt, !posted.isEmpty {
                            Text(posted).font(.caption).foregroundStyle(Color.stoneMuted)
                        }
                        if let address = job.applicationURL, !address.isEmpty, let url = URL(string: address) {
                            Button("Apply") { openURL(url) }
                                .buttonStyle(.borderedProminent)
                                .tint(Color.ecoOrange)
                        } else {
                            TextField("Cover letter", text: $coverLetter, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                            Button(applying ? "Sending…" : "Apply") { Task { await apply() } }
                                .buttonStyle(.borderedProminent)
                                .tint(Color.ecoOrange)
                                .disabled(applying)
                        }
                        if let notice {
                            Text(notice).font(.subheadline).foregroundStyle(Color.stoneMuted)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Job")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        do {
            job = try await client.job(id: id)
            phase = .ready
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            phase = .failed(error.message)
        } catch {
            phase = .failed("This job could not be loaded.")
        }
    }

    private func apply() async {
        applying = true
        notice = nil
        defer { applying = false }
        do {
            notice = try await client.applyToJob(id: id, coverLetter: coverLetter)
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            notice = text
        } catch {
            notice = "The application could not be sent."
        }
    }
}

enum LoadPhase: Equatable {
    case loading
    case ready
    case failed(String)
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

@ViewBuilder
private func cover(_ raw: String?) -> some View {
    if let url = AccountMedia.url(raw) ?? PortfolioProject.coverURL(raw) {
        AsyncImage(url: url) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Color.stone
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
