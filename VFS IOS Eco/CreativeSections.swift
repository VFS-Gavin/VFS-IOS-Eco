import SwiftUI

enum DiscoveryListKind: String, Hashable {
    case pitches
    case top5
    case reviews
    case taste
    case challenges

    var title: String {
        switch self {
        case .pitches: "Elevator Pitches"
        case .top5: "Top 5 Rankings"
        case .reviews: "Creator Reviews"
        case .taste: "Community Taste"
        case .challenges: "Weekly Challenges"
        }
    }

    var detail: String {
        switch self {
        case .pitches: "One sentence for the concept, then a fuller write-up if you want."
        case .top5: "The films, games, books, and people that shaped you, with a note on why each one matters."
        case .reviews: "Ratings and written reviews from the Creative ECOsystem."
        case .taste: "What people are watching and saving."
        case .challenges: "This week's challenge on Creative Engine."
        }
    }

    var path: String {
        switch self {
        case .pitches: "/api/creative/discovery/pitches"
        case .top5: "/api/creative/discovery/top-5"
        case .reviews: "/api/creative/discovery/reviews"
        case .taste: "/api/creative/discovery/taste"
        case .challenges: "/api/creative/discovery/challenges"
        }
    }
}

struct FundingView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL
    @State private var section: String?
    @State private var grants: [FundingGrant] = []
    @State private var message: String?
    @State private var loading = false
    private let green = Color(red: 22 / 255, green: 163 / 255, blue: 74 / 255)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let section {
                    Button("All Funding") { self.section = nil }
                        .buttonStyle(.plain)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(green)
                    sectionBody(section)
                } else {
                    Text("Fund Your")
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    Text("Creative Vision")
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundStyle(green)
                    Text("Grants, festivals, and exclusive VFS funding. Choose your path below.")
                        .font(.body)
                        .foregroundStyle(Color.stoneMuted)
                    pathCard("Exclusive Funding", "Funding opportunities offered directly by Vancouver Film School.", key: "vfs", bar: Color(red: 20 / 255, green: 83 / 255, blue: 45 / 255))
                    pathCard("Grants", "External funding from arts councils, foundations, and industry programs for creative projects.", key: "grants", bar: green)
                    pathCard("Film Festivals", "Curated festivals accepting submissions, from shorts and docs to animation and student showcases.", key: "festivals", bar: Color(red: 74 / 255, green: 222 / 255, blue: 128 / 255))
                }
                SiteFooter(session: session)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle(sectionTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private var sectionTitle: String {
        switch section {
        case "vfs": "Exclusive Funding"
        case "grants": "Grants"
        case "festivals": "Film Festivals"
        default: "Project Funding"
        }
    }

    @ViewBuilder
    private func sectionBody(_ key: String) -> some View {
        switch key {
        case "festivals":
            Text(FestivalCatalog.filmFreewayDetail)
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
            if let url = URL(string: FestivalCatalog.filmFreewayURL) {
                Button("Open FilmFreeway") { openURL(url) }
                    .buttonStyle(.bordered)
                    .tint(green)
            }
            ForEach(FestivalCatalog.groups) { group in
                Text(group.region)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                    .padding(.top, 8)
                Text(group.detail).font(.subheadline).foregroundStyle(Color.stoneMuted)
                ForEach(group.festivals) { festival in
                    Button {
                        if let url = URL(string: festival.url) { openURL(url) }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(festival.category).font(.caption2.weight(.bold)).foregroundStyle(green)
                            Text(festival.name).font(.headline).foregroundStyle(Color.stoneInk).multilineTextAlignment(.leading)
                            Text(festival.detail).font(.subheadline).foregroundStyle(Color.stoneMuted)
                            Text(festival.location).font(.caption).foregroundStyle(Color.stoneLabel)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.card)
                        .overlay(alignment: .leading) { Rectangle().fill(green).frame(width: 3) }
                        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        case "vfs":
            Text("Funding offered directly by VFS.")
                .font(.body)
                .foregroundStyle(Color.stoneMuted)
            vfsStep("01", "Submit Your Pitch", "A short project overview: your concept, team, timeline, and how the funding will be used.")
            vfsStep("02", "Review Period", "Applications are reviewed by VFS faculty and industry mentors within 2–3 weeks.")
            vfsStep("03", "Award & Kickoff", "Approved projects receive funding directly to bring your vision to life.")
            vfsStep("04", "Showcase Your Work", "Funded projects are featured in the Creative ECOsystem portfolio and VFS showcase events.")
            grantList(section: "vfs")
        default:
            Text("External grants from arts councils, foundations, and industry programs.")
                .font(.body)
                .foregroundStyle(Color.stoneMuted)
            grantList(section: "grant")
        }
    }

    private func grantList(section: String) -> some View {
        let rows = grants.filter { ($0.section ?? "grant") == section }
        return VStack(alignment: .leading, spacing: 12) {
            if loading { ProgressView() }
            if let message, rows.isEmpty {
                Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
            }
            ForEach(rows) { grant in
                VStack(alignment: .leading, spacing: 6) {
                    if let status = grant.status, !status.isEmpty {
                        Text(statusLabel(status)).font(.caption2.weight(.bold)).foregroundStyle(green)
                    }
                    Text(grant.name).font(.system(.title3, design: .serif)).foregroundStyle(Color.stoneInk)
                    if let amount = grant.amount, !amount.isEmpty {
                        Text(amount).font(.subheadline.weight(.semibold)).foregroundStyle(green)
                    }
                    if let description = grant.longDescription ?? grant.description, !description.isEmpty {
                        Text(description).font(.subheadline).foregroundStyle(Color.stoneMuted)
                    }
                    if let deadline = grant.deadline, !deadline.isEmpty {
                        Text(deadline).font(.caption).foregroundStyle(Color.stoneLabel)
                    }
                    if let link = grant.externalURL, let url = URL(string: link) {
                        Button("Open listing") { openURL(url) }
                            .buttonStyle(.plain)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(green)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.card)
                .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
            }
        }
    }

    private func statusLabel(_ status: String) -> String {
        switch status {
        case "open": "Open"
        case "coming_soon": "Soon"
        default: "Closed"
        }
    }

    private func vfsStep(_ number: String, _ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(number).font(.caption.weight(.bold)).foregroundStyle(green)
            Text(title).font(.headline).foregroundStyle(Color.stoneInk)
            Text(detail).font(.subheadline).foregroundStyle(Color.stoneMuted)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card)
        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
    }

    private func pathCard(_ title: String, _ detail: String, key: String, bar: Color) -> some View {
        Button { section = key } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.system(size: 28, weight: .bold, design: .serif)).foregroundStyle(Color.stoneInk)
                Text(detail).font(.subheadline).foregroundStyle(Color.stoneMuted)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.card)
            .overlay(alignment: .top) { Rectangle().fill(bar).frame(height: 4) }
            .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            grants = try await client.funding().grants
            message = nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The funding list isn't available from the app yet."
        }
    }
}

struct WorkshopsView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @State private var events: [CalendarItem] = []
    @State private var message: String?
    private let pink = Color(red: 219 / 255, green: 39 / 255, blue: 119 / 255)
    private let categories: [(String, String, String)] = [
        ("technology-media-arts", "Technologies & Trends", "Explore emerging tools and creative tech"),
        ("business-media-arts", "The Creator Economy", "Build the business side of your creative career"),
        ("society-media-arts", "Creative Identity and Human Development", "Explore the intersection of creativity and culture"),
        ("in-production", "In Production Workshops", "VFS Studios: Exclusive Weekend Workshop Experiences"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Classes &")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Workshops")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(pink)
                Text("and On Campus")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Level up your skills and connections.")
                    .font(.body)
                    .foregroundStyle(Color.stoneMuted)
                ForEach(categories, id: \.0) { category in
                    NavigationLink(value: CreativeRoute.workshopCategory(category.0)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.1).font(.system(size: 26, weight: .bold, design: .serif)).foregroundStyle(Color.stoneInk)
                            Text(category.2).font(.subheadline).foregroundStyle(Color.stoneMuted)
                            Text(category.0 == "in-production" ? "Explore In Production Workshops" : "Explore Electives")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(pink)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.card)
                        .overlay(alignment: .top) { Rectangle().fill(pink).frame(height: 3) }
                        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                Text("What's going on at VFS!")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                    .padding(.top, 8)
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                } else if events.isEmpty {
                    Text("Nothing new on the calendar right now.")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                }
                ForEach(events) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        if let date = item.dateLabel, !date.isEmpty {
                            Text(date).font(.caption.weight(.semibold)).foregroundStyle(pink)
                        }
                        Text(item.title).font(.headline).foregroundStyle(Color.stoneInk)
                        if let when = item.when, !when.isEmpty {
                            Text(item.location.map { "\(when) · \($0)" } ?? when)
                                .font(.caption)
                                .foregroundStyle(Color.stoneMuted)
                        }
                        if let description = item.description, !description.isEmpty {
                            Text(description).font(.subheadline).foregroundStyle(Color.stoneMuted).lineLimit(3)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.card)
                    .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
                }
                SiteFooter(session: session)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Classes & Workshops")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        do {
            events = try await client.calendar()
            message = events.isEmpty ? nil : nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The calendar isn't available from the app yet."
        }
    }
}

struct WorkshopCategoryView: View {
    @Bindable var session: AppSession
    var slug: String
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL
    @State private var page: WorkshopCategoryPage?
    @State private var message: String?
    private let pink = Color(red: 219 / 255, green: 39 / 255, blue: 119 / 255)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(page?.label.isEmpty == false ? page!.label : fallbackTitle)
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                if let message {
                    Text(message).font(.body).foregroundStyle(Color.stoneMuted)
                }
                if let page {
                    ForEach(page.courses) { course in
                        VStack(alignment: .leading, spacing: 6) {
                            if let badge = course.badge, !badge.isEmpty {
                                Text(badge).font(.caption2.weight(.bold)).foregroundStyle(pink)
                            }
                            Text(course.name).font(.headline).foregroundStyle(Color.stoneInk)
                            if let dates = course.dates, !dates.isEmpty {
                                Text(dates).font(.caption).foregroundStyle(Color.stoneMuted)
                            }
                            if let summary = course.summary, !summary.isEmpty {
                                Text(summary).font(.subheadline).foregroundStyle(Color.stoneMuted)
                            }
                            if let link = course.signupURL ?? course.url, let url = URL(string: link) {
                                Button(course.signupURL == nil ? "Register on Eventbrite" : "Register") { openURL(url) }
                                    .buttonStyle(.plain)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(pink)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.card)
                        .overlay(alignment: .top) { Rectangle().fill(pink).frame(height: 3) }
                        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
                    }
                    ForEach(page.events) { event in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(event.title).font(.headline).foregroundStyle(Color.stoneInk)
                            if let dates = event.dates, !dates.isEmpty {
                                Text(dates).font(.caption).foregroundStyle(pink)
                            }
                            if let location = event.location, !location.isEmpty {
                                Text(location).font(.caption).foregroundStyle(Color.stoneMuted)
                            }
                            if let description = event.description, !description.isEmpty {
                                Text(description).font(.subheadline).foregroundStyle(Color.stoneMuted)
                            }
                            if let link = event.url, let url = URL(string: link) {
                                Button("Open event") { openURL(url) }
                                    .buttonStyle(.plain)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(pink)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.card)
                        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
                    }
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Classes & Workshops")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private var fallbackTitle: String {
        switch slug {
        case "technology-media-arts": "Technologies & Trends"
        case "business-media-arts": "The Creator Economy"
        case "society-media-arts": "Creative Identity and Human Development"
        case "in-production": "In Production Workshops"
        default: "Classes & Workshops"
        }
    }

    private func load() async {
        do {
            page = try await client.workshopCategory(slug)
            let empty = (page?.courses.isEmpty ?? true) && (page?.events.isEmpty ?? true)
            message = empty ? "Nothing is listed in this track yet." : nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This workshop list isn't available from the app yet."
        }
    }
}

struct DiscoveryListView: View {
    @Bindable var session: AppSession
    var kind: DiscoveryListKind
    var client: APIClient = APIClient()
    @State private var items: [DiscoveryListItem] = []
    @State private var seen: [DiscoveryListItem] = []
    @State private var saved: [DiscoveryListItem] = []
    @State private var message: String?
    @State private var loading = false
    private let accent = Color(red: 14 / 255, green: 165 / 255, blue: 233 / 255)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(kind.title)
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text(kind.detail)
                    .font(.body)
                    .foregroundStyle(Color.stoneMuted)
                if loading { ProgressView() }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                if !seen.isEmpty {
                    Text("Most watched").font(.headline).foregroundStyle(Color.stoneInk)
                    list(seen)
                }
                if !saved.isEmpty {
                    Text("Most saved").font(.headline).foregroundStyle(Color.stoneInk)
                    list(saved)
                }
                list(items)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle(kind.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func list(_ rows: [DiscoveryListItem]) -> some View {
        ForEach(rows) { item in
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title).font(.headline).foregroundStyle(Color.stoneInk)
                if let subtitle = item.subtitle, !subtitle.isEmpty {
                    Text(subtitle).font(.caption).foregroundStyle(accent)
                }
                if let body = item.body, !body.isEmpty, body != item.title {
                    Text(body).font(.subheadline).foregroundStyle(Color.stoneMuted).lineLimit(4)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.card)
            .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
        }
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            let page = try await client.discoveryList(path: kind.path)
            items = page.items
            seen = page.seen
            saved = page.saved
            message = items.isEmpty && seen.isEmpty && saved.isEmpty ? "Nothing is listed yet." : nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This Creative Engine list isn't available from the app yet."
        }
    }
}
