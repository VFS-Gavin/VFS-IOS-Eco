import SwiftUI

struct ProjectDetailView: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL
    @State private var project: ProjectDetail?
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
                            .font(.system(.largeTitle, design: .serif))
                            .foregroundStyle(Color.stoneInk)
                        if !project.programLabel.isEmpty {
                            Text(project.programLabel)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.ecoOrange)
                        }
                        if let owner = project.ownerName, !owner.isEmpty {
                            if let slug = project.profileSlug, !slug.isEmpty {
                                NavigationLink(value: CreativeRoute.profile(slug)) {
                                    Text(owner).font(.headline)
                                }
                                .tint(Color.ecoOrange)
                            } else {
                                Text(owner).font(.headline).foregroundStyle(Color.stoneInk)
                            }
                        }
                        Text(project.liked ? "\(project.likesCount) likes · You liked this" : "\(project.likesCount) likes")
                            .font(.caption)
                            .foregroundStyle(Color.stoneLabel)
                        if let description = project.description, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundStyle(Color.stoneLabel)
                        }
                        if !project.tools.isEmpty {
                            Text(project.tools.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundStyle(Color.stoneInk)
                        }
                        ForEach(project.media) { item in
                            if let address = item.url, let url = PortfolioProject.coverURL(address) ?? URL(string: address) {
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
                            .font(.system(.largeTitle, design: .serif))
                            .foregroundStyle(Color.stoneInk)
                        if let headline = profile.headline, !headline.isEmpty {
                            Text(headline).font(.body).foregroundStyle(Color.stoneLabel)
                        }
                        if let program = profile.programLabel, !program.isEmpty {
                            Text(program).font(.subheadline.weight(.semibold)).foregroundStyle(Color.ecoOrange)
                        }
                        if let location = profile.location, !location.isEmpty {
                            Text(location).font(.subheadline).foregroundStyle(Color.stoneLabel)
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
                            NavigationLink(value: CreativeRoute.project(project.id)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(project.title).font(.headline).foregroundStyle(Color.stoneInk)
                                    Text("\(project.likesCount) likes")
                                        .font(.caption)
                                        .foregroundStyle(Color.stoneLabel)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
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
    @State private var phase: LoadPhase = .loading
    @State private var loadingMore = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Collabs")
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                TextField("Search collabs", text: $search)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityIdentifier("collab-search")
                    .onSubmit { Task { await reload() } }

                switch phase {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    Text(message).foregroundStyle(Color.stoneInk)
                case .ready:
                    if collabs.isEmpty {
                        Text("No collabs found.")
                            .font(.body)
                            .foregroundStyle(Color.stoneLabel)
                    } else {
                        ForEach(collabs) { collab in
                            NavigationLink(value: CreativeRoute.collab(collab.id)) {
                                collabCard(collab)
                            }
                            .buttonStyle(.plain)
                        }
                        if board?.collabs.hasMore == true {
                            Button(loadingMore ? "Loading" : "Load more") {
                                Task { await loadMore() }
                            }
                            .buttonStyle(.bordered)
                            .tint(Color.ecoOrange)
                            .disabled(loadingMore)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .task { await reload() }
    }

    private func collabCard(_ collab: CollabCard) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(collab.title).font(.headline).foregroundStyle(Color.stoneInk)
            if let role = collab.role, !role.isEmpty {
                Text(role).font(.subheadline).foregroundStyle(Color.ecoOrange)
            }
            if let owner = collab.ownerName, !owner.isEmpty {
                Text(owner).font(.caption).foregroundStyle(Color.stoneLabel)
            }
            if let deadline = collab.deadline, !deadline.isEmpty {
                Text(deadline).font(.caption).foregroundStyle(Color.stoneLabel)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func reload() async {
        phase = .loading
        do {
            let page = try await client.collabs(search: search, page: 1)
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
            let page = try await client.collabs(search: search, page: board.collabs.currentPage + 1)
            self.board = page
            let existing = Set(collabs.map(\.id))
            collabs.append(contentsOf: page.collabs.data.filter { !existing.contains($0.id) })
        } catch APIError.unauthorized {
            session.signOut()
        } catch {
        }
    }
}

struct CollabDetailView: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @State private var collab: CollabCard?
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
                    if let collab {
                        Text(collab.title)
                            .font(.system(.largeTitle, design: .serif))
                            .foregroundStyle(Color.stoneInk)
                        if let type = collab.type, !type.isEmpty {
                            Text(type).font(.subheadline.weight(.semibold)).foregroundStyle(Color.ecoOrange)
                        }
                        if let role = collab.role, !role.isEmpty {
                            Text(role).font(.body).foregroundStyle(Color.stoneInk)
                        }
                        if let owner = collab.ownerName, !owner.isEmpty {
                            Text(owner).font(.subheadline).foregroundStyle(Color.stoneLabel)
                        }
                        if let deadline = collab.deadline, !deadline.isEmpty {
                            Text(deadline).font(.subheadline).foregroundStyle(Color.stoneLabel)
                        }
                        if let location = collab.location, !location.isEmpty {
                            Text(location).font(.subheadline).foregroundStyle(Color.stoneLabel)
                        }
                        if collab.remote == true {
                            Text("Remote").font(.caption.weight(.semibold)).foregroundStyle(Color.ecoOrange)
                        }
                        if collab.paid == true {
                            Text("Paid").font(.caption.weight(.semibold)).foregroundStyle(Color.ecoOrange)
                        }
                        if let description = collab.description, !description.isEmpty {
                            Text(description).font(.body).foregroundStyle(Color.stoneLabel)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Collab")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
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
}

struct JobsView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @State private var board: JobsBoard?
    @State private var jobs: [JobCard] = []
    @State private var partnerJobs: [JobCard] = []
    @State private var search = ""
    @State private var phase: LoadPhase = .loading
    @State private var loadingJobs = false
    @State private var loadingPartners = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Jobs")
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                TextField("Search jobs", text: $search)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityIdentifier("job-search")
                    .onSubmit { Task { await reload() } }

                switch phase {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    Text(message).foregroundStyle(Color.stoneInk)
                case .ready:
                    jobSection("Jobs", jobs)
                    if board?.jobs.hasMore == true {
                        Button(loadingJobs ? "Loading" : "Load more") {
                            Task { await loadMoreJobs() }
                        }
                        .buttonStyle(.bordered)
                        .tint(Color.ecoOrange)
                        .disabled(loadingJobs)
                    }
                    if !partnerJobs.isEmpty {
                        jobSection("Partner jobs", partnerJobs)
                        if board?.partnerJobs.hasMore == true {
                            Button(loadingPartners ? "Loading" : "Load more partner jobs") {
                                Task { await loadMorePartners() }
                            }
                            .buttonStyle(.bordered)
                            .tint(Color.ecoOrange)
                            .disabled(loadingPartners)
                        }
                    }
                    if let productions = board?.productions, !productions.isEmpty {
                        Text("Productions")
                            .font(.system(.title3, design: .serif))
                            .foregroundStyle(Color.stoneInk)
                        ForEach(productions) { production in
                            productionCard(production)
                        }
                    }
                    if jobs.isEmpty && partnerJobs.isEmpty && (board?.productions.isEmpty != false) {
                        Text("No jobs found.")
                            .font(.body)
                            .foregroundStyle(Color.stoneLabel)
                    }
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .task { await reload() }
    }

    private func jobSection(_ title: String, _ cards: [JobCard]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if !cards.isEmpty {
                Text(title)
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(Color.stoneInk)
            }
            ForEach(cards) { job in
                NavigationLink(value: CreativeRoute.job(job.id)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(job.title).font(.headline).foregroundStyle(Color.stoneInk)
                        if let company = job.company, !company.isEmpty {
                            Text(company).font(.subheadline).foregroundStyle(Color.ecoOrange)
                        }
                        if let location = job.location, !location.isEmpty {
                            Text(location).font(.caption).foregroundStyle(Color.stoneLabel)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func productionCard(_ production: ProductionCard) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(production.title).font(.headline).foregroundStyle(Color.stoneInk)
            line(production.region)
            line(production.category)
            line(production.productionCompany)
            line(production.schedule)
            if let start = production.startDate {
                Text(production.endDate.map { "\(start) – \($0)" } ?? start)
                    .font(.caption)
                    .foregroundStyle(Color.stoneLabel)
            }
            line(production.productionAddress)
            if let email = production.email, let url = URL(string: "mailto:\(email)") {
                Link(email, destination: url).font(.subheadline).tint(Color.ecoOrange)
            }
            if let phone = production.phone, let url = SupportLinks.phone(phone) {
                Link(phone, destination: url).font(.subheadline).tint(Color.ecoOrange)
            }
            if let source = production.sourceURL, let url = URL(string: source) {
                Link("Source", destination: url).font(.subheadline).tint(Color.ecoOrange)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func line(_ value: String?) -> some View {
        Group {
            if let value, !value.isEmpty {
                Text(value).font(.caption).foregroundStyle(Color.stoneLabel)
            }
        }
    }

    private func reload() async {
        phase = .loading
        do {
            let page = try await client.jobs(search: search, page: 1, partnerPage: 1)
            board = page
            jobs = page.jobs.data
            partnerJobs = page.partnerJobs.data
            phase = .ready
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            phase = .failed(error.message)
        } catch {
            phase = .failed("Jobs could not be loaded.")
        }
    }

    private func loadMoreJobs() async {
        guard let board, board.jobs.hasMore, !loadingJobs else { return }
        loadingJobs = true
        defer { loadingJobs = false }
        do {
            let page = try await client.jobs(search: search, page: board.jobs.currentPage + 1, partnerPage: board.partnerJobs.currentPage)
            self.board = JobsBoard(jobs: page.jobs, partnerJobs: board.partnerJobs, productions: page.productions)
            let existing = Set(jobs.map(\.id))
            jobs.append(contentsOf: page.jobs.data.filter { !existing.contains($0.id) })
        } catch APIError.unauthorized {
            session.signOut()
        } catch {
        }
    }

    private func loadMorePartners() async {
        guard let board, board.partnerJobs.hasMore, !loadingPartners else { return }
        loadingPartners = true
        defer { loadingPartners = false }
        do {
            let page = try await client.jobs(search: search, page: board.jobs.currentPage, partnerPage: board.partnerJobs.currentPage + 1)
            self.board = JobsBoard(jobs: board.jobs, partnerJobs: page.partnerJobs, productions: page.productions)
            let existing = Set(partnerJobs.map(\.id))
            partnerJobs.append(contentsOf: page.partnerJobs.data.filter { !existing.contains($0.id) })
        } catch APIError.unauthorized {
            session.signOut()
        } catch {
        }
    }
}

struct JobDetailView: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL
    @State private var job: JobCard?
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
                            .font(.system(.largeTitle, design: .serif))
                            .foregroundStyle(Color.stoneInk)
                        if let company = job.company, !company.isEmpty {
                            Text(company).font(.title3).foregroundStyle(Color.ecoOrange)
                        }
                        if let location = job.location, !location.isEmpty {
                            Text(location).font(.subheadline).foregroundStyle(Color.stoneLabel)
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
                            Text(posted).font(.caption).foregroundStyle(Color.stoneLabel)
                        }
                        if let address = job.applicationURL, let url = URL(string: address) {
                            Button("Apply") { openURL(url) }
                                .buttonStyle(.borderedProminent)
                                .tint(Color.ecoOrange)
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
}

private enum LoadPhase {
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
    if let url = PortfolioProject.coverURL(raw) {
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
