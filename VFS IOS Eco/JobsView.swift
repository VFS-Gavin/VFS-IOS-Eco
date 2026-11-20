import SwiftUI

private enum JobSection: String, CaseIterable, Identifiable {
    case studios
    case filming
    case partner
    var id: String { rawValue }
}

struct JobsView: View {
    @Bindable var session: AppSession
    var board: String? = nil
    var client: APIClient = APIClient()
    @State private var feed: JobsBoard?
    @State private var jobs: [JobCard] = []
    @State private var partnerJobs: [JobCard] = []
    @State private var search = ""
    @State private var type = ""
    @State private var level = ""
    @State private var remote = false
    @State private var sort = ""
    @State private var program = ""
    @State private var company = ""
    @State private var city = ""
    @State private var region = ""
    @State private var phase: LoadPhase = .loading
    @State private var loadingJobs = false
    @State private var loadingPartners = false

    private let types = [("", "All Types"), ("full_time", "Full Time"), ("part_time", "Part Time"), ("contract", "Contract"), ("internship", "Internship")]
    private let levels = [("", "All Levels"), ("entry", "Entry"), ("mid", "Mid"), ("senior", "Senior")]
    private let sorts = [("", "Mixed"), ("company", "Studio A–Z"), ("location", "City A–Z"), ("newest", "Newest")]
    private let regions = ["", "vancouver", "alberta", "toronto", "los-angeles", "austin", "atlanta"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let board, let kind = JobSection(rawValue: board) {
                    sectionContent(kind)
                } else {
                    landing
                }
                SiteFooter(session: session)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle(boardTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task { await reload() }
    }

    private var boardTitle: String {
        switch board {
        case "studios": "Real Jobs at Top Studios"
        case "filming": "What's Filming?"
        case "partner": "All Other Jobs"
        default: "Industry Opportunities"
        }
    }

    private var landing: some View {
        VStack(alignment: .leading, spacing: 16) {
            CreativeHeadline(
                lead: "The Industry\n",
                accent: "at your fingertips",
                accentColor: .jobGold,
                detail: "Choose your path below."
            )
            pathCard("Real Jobs at Top Studios", "Open positions pulled directly from top VFX, animation, and game studio career pages.", count: feed?.jobs.total, unit: "open roles", section: .studios)
            pathCard("What's Filming?", "Active film & TV productions shooting in Vancouver, Alberta, Toronto, LA, Austin & Atlanta. Updated regularly.", count: feed?.productions.count, unit: "active productions", section: .filming)
            pathCard("All Other Jobs & Work Opportunities", "Openings sent in by companies and industry partners, such as a studio hiring an editor. VFS reviews each post before it goes live.", count: feed?.partnerJobs.total, unit: "open roles", section: .partner)
            if phase == .loading { ProgressView() }
            if case .failed(let message) = phase {
                Text(message).foregroundStyle(Color.stoneInk)
            }
        }
    }

    private func pathCard(_ title: String, _ detail: String, count: Int?, unit: String, section: JobSection) -> some View {
        CreativeLink(route: .jobBoard(section.rawValue)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.system(size: 26, weight: .bold, design: .serif)).foregroundStyle(Color.stoneInk)
                Text(detail).font(.subheadline).foregroundStyle(Color.stoneMuted)
                if let count {
                    Text("\(count) \(unit)").font(.subheadline.weight(.semibold)).foregroundStyle(Color.jobGold)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.card)
            .overlay(alignment: .top) { Rectangle().fill(Color.jobGold).frame(height: 4) }
            .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func sectionContent(_ section: JobSection) -> some View {
        switch section {
        case .studios:
            filters
            jobList(jobs, empty: "No jobs found.")
            if feed?.jobs.hasMore == true {
                moreButton(loadingJobs ? "Loading" : "Load more") { await loadMoreJobs() }
            }
        case .partner:
            CreativeSearchField(placeholder: "Search roles, companies...", text: $search, identifier: "job-search") {
                Task { await reload() }
            }
            jobList(shownPartners, empty: "No partner jobs found.")
            if feed?.partnerJobs.hasMore == true {
                moreButton(loadingPartners ? "Loading" : "Load more") { await loadMorePartners() }
            }
        case .filming:
            chipRow(regions.map { ($0, regionLabel($0)) }, selected: region) { region = $0 }
            let rows = shownProductions
            if rows.isEmpty {
                Text("No productions in this region.").foregroundStyle(Color.stoneMuted)
            }
            ForEach(rows) { production in
                CreativeLink(route: .production(production.id)) {
                    productionCard(production)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var filters: some View {
        VStack(alignment: .leading, spacing: 10) {
            CreativeSearchField(placeholder: "Search roles, companies...", text: $search, identifier: "job-search") {
                Task { await reload() }
            }
            chipRow(types, selected: type) { type = $0; Task { await reload() } }
            chipRow(levels, selected: level) { level = $0; Task { await reload() } }
            chipRow(sorts, selected: sort) { sort = $0; Task { await reload() } }
            chipRow([("", "All Programs")] + ProfilePrograms.options.map { ($0.key, $0.label) }, selected: program) { program = $0; Task { await reload() } }
            TextField("Studio", text: $company)
                .textFieldStyle(.roundedBorder)
                .onSubmit { Task { await reload() } }
            TextField("City", text: $city)
                .textFieldStyle(.roundedBorder)
                .onSubmit { Task { await reload() } }
            Button("Apply studio and city") { Task { await reload() } }
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.jobGold)
            Button(remote ? "Remote only" : "Remote") {
                remote.toggle()
                Task { await reload() }
            }
            .buttonStyle(.plain)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(remote ? Color.jobGold : Color.stoneMuted)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(remote ? Color.jobGold : Color.stoneLine, lineWidth: 1))
        }
    }

    private func chipRow(_ options: [(String, String)], selected: String, choose: @escaping (String) -> Void) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.0) { option in
                    Button(option.1.isEmpty ? "All" : option.1) { choose(option.0) }
                        .buttonStyle(.plain)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(selected == option.0 ? Color.stoneInk : Color.stoneMuted)
                        .background(selected == option.0 ? Color.jobGold.opacity(0.18) : Color.card)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(selected == option.0 ? Color.jobGold : Color.stoneLine, lineWidth: 1))
                }
            }
        }
    }

    private func jobList(_ cards: [JobCard], empty: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if cards.isEmpty, phase == .ready {
                Text(empty).foregroundStyle(Color.stoneMuted)
            }
            ForEach(cards) { job in
                CreativeLink(route: CreativeRoute.job(job.id)) {
                    SharpCard(bar: .jobGold) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(job.title).font(.system(.headline, design: .serif)).foregroundStyle(Color.stoneInk)
                            if let company = job.company, !company.isEmpty {
                                Text(company).font(.subheadline).foregroundStyle(Color.jobGold)
                            }
                            HStack(spacing: 8) {
                                if let location = job.location, !location.isEmpty {
                                    Text(location).font(.caption).foregroundStyle(Color.stoneMuted)
                                }
                                if let type = job.type, !type.isEmpty {
                                    Text(typeLabel(type)).font(.caption).foregroundStyle(Color.stoneLabel)
                                }
                                if job.remote {
                                    Text("Remote").font(.caption.weight(.semibold)).foregroundStyle(Color.jobGold)
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func moreButton(_ title: String, action: @escaping () async -> Void) -> some View {
        Button(title) { Task { await action() } }
            .buttonStyle(.bordered)
            .tint(Color.ecoOrange)
    }

    private func productionCard(_ production: ProductionCard) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(production.title).font(.headline).foregroundStyle(Color.stoneInk)
            if let region = production.region { Text(regionLabel(region)).font(.caption).foregroundStyle(Color.jobGold) }
            if let category = production.category, !category.isEmpty {
                Text(category).font(.caption).foregroundStyle(Color.stoneMuted)
            }
            if let company = production.productionCompany, !company.isEmpty {
                Text(company).font(.caption).foregroundStyle(Color.stoneLabel)
            }
            if let start = production.startDate {
                Text(production.endDate.map { "\(start) – \($0)" } ?? start)
                    .font(.caption)
                    .foregroundStyle(Color.stoneMuted)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card)
        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
    }

    private var shownPartners: [JobCard] {
        let needle = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return partnerJobs }
        return partnerJobs.filter {
            $0.title.lowercased().contains(needle)
                || ($0.company ?? "").lowercased().contains(needle)
                || ($0.location ?? "").lowercased().contains(needle)
        }
    }

    private var shownProductions: [ProductionCard] {
        guard !region.isEmpty else { return feed?.productions ?? [] }
        return (feed?.productions ?? []).filter { $0.region == region }
    }

    private func regionLabel(_ value: String) -> String {
        switch value {
        case "": "All regions"
        case "vancouver": "Vancouver"
        case "alberta": "Alberta"
        case "toronto": "Toronto"
        case "los-angeles": "Los Angeles"
        case "austin": "Austin"
        case "atlanta": "Atlanta"
        default: value.capitalized
        }
    }

    private func typeLabel(_ value: String) -> String {
        types.first { $0.0 == value }?.1 ?? value
    }

    private func reload() async {
        phase = .loading
        do {
            let page = try await client.jobs(search: search, page: 1, partnerPage: 1, type: type, remote: remote, level: level, sort: sort, program: program, company: company.trimmingCharacters(in: .whitespacesAndNewlines), city: city.trimmingCharacters(in: .whitespacesAndNewlines))
            feed = page
            jobs = page.jobs.data
            partnerJobs = page.partnerJobs.data
            phase = .ready
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            phase = .failed(text)
        } catch {
            phase = .failed("Jobs could not be loaded.")
        }
    }

    private func loadMoreJobs() async {
        guard let feed, feed.jobs.hasMore, !loadingJobs else { return }
        loadingJobs = true
        defer { loadingJobs = false }
        do {
            let page = try await client.jobs(search: search, page: feed.jobs.currentPage + 1, partnerPage: feed.partnerJobs.currentPage, type: type, remote: remote, level: level, sort: sort, program: program, company: company.trimmingCharacters(in: .whitespacesAndNewlines), city: city.trimmingCharacters(in: .whitespacesAndNewlines))
            self.feed = JobsBoard(jobs: page.jobs, partnerJobs: feed.partnerJobs, productions: page.productions)
            let existing = Set(jobs.map(\.id))
            jobs.append(contentsOf: page.jobs.data.filter { !existing.contains($0.id) })
        } catch APIError.unauthorized {
            session.signOut()
        } catch {
        }
    }

    private func loadMorePartners() async {
        guard let feed, feed.partnerJobs.hasMore, !loadingPartners else { return }
        loadingPartners = true
        defer { loadingPartners = false }
        do {
            let page = try await client.jobs(search: search, page: feed.jobs.currentPage, partnerPage: feed.partnerJobs.currentPage + 1, type: type, remote: remote, level: level, sort: sort)
            self.feed = JobsBoard(jobs: feed.jobs, partnerJobs: page.partnerJobs, productions: page.productions)
            let existing = Set(partnerJobs.map(\.id))
            partnerJobs.append(contentsOf: page.partnerJobs.data.filter { !existing.contains($0.id) })
        } catch APIError.unauthorized {
            session.signOut()
        } catch {
        }
    }
}
