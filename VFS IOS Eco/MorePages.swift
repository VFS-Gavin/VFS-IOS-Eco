import SwiftUI

struct FacilityDetailView: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @State private var item: FacilityItem?
    @State private var message: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if let item {
                    if let raw = item.imageURL, let url = AccountMedia.url(raw) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Color.stoneLine.frame(height: 180)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    Text(item.name)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    if let kind = item.kind, !kind.isEmpty {
                        Text(kind.replacingOccurrences(of: "_", with: " "))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(red: 8 / 255, green: 145 / 255, blue: 178 / 255))
                    }
                    if let description = item.description, !description.isEmpty {
                        Text(description).font(.body).foregroundStyle(Color.stoneInk)
                    }
                    if let capacity = item.capacity {
                        Text("Capacity \(capacity)").font(.subheadline).foregroundStyle(Color.stoneMuted)
                    }
                    if let amenities = item.amenities, !amenities.isEmpty {
                        Text("Amenities")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.stoneMuted)
                        ForEach(amenities, id: \.self) { amenity in
                            Text(amenity).font(.subheadline).foregroundStyle(Color.stoneInk)
                        }
                    }
                    FacilityBookCard(session: session, item: item, client: client)
                } else if let message {
                    Text(message).foregroundStyle(Color.stoneInk)
                } else {
                    ProgressView()
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Resource")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        do {
            let rows = try await client.facilities()
            item = rows.first { $0.id == id }
            if item == nil { message = "This resource isn't on the list." }
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This resource could not be loaded."
        }
    }
}

struct GrantDetailView: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL
    @State private var grant: FundingGrant?
    @State private var message: String?
    private let green = Color(red: 22 / 255, green: 163 / 255, blue: 74 / 255)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let grant {
                    if let status = grant.status, !status.isEmpty {
                        Text(statusLabel(status)).font(.caption.weight(.bold)).foregroundStyle(green)
                    }
                    Text(grant.name)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    if let amount = grant.amount, !amount.isEmpty {
                        Text(amount).font(.title3.weight(.semibold)).foregroundStyle(green)
                    }
                    if let deadline = grant.deadline, !deadline.isEmpty {
                        Text(deadline).font(.subheadline).foregroundStyle(Color.stoneMuted)
                    }
                    if let long = grant.longDescription, !long.isEmpty {
                        Text(long).font(.body).foregroundStyle(Color.stoneInk)
                    } else if let description = grant.description, !description.isEmpty {
                        Text(description).font(.body).foregroundStyle(Color.stoneInk)
                    }
                    if grant.section == "vfs", grant.status == "open" {
                        CreativeLink(route: .grantApply(grant.id)) {
                            Text("Apply for \(grant.name)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(red: 20 / 255, green: 83 / 255, blue: 45 / 255))
                        }
                        .buttonStyle(.plain)
                    }
                    if let link = grant.externalURL, let url = URL(string: link) {
                        Button("Open listing") { openURL(url) }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(green)
                    }
                } else if let message {
                    Text(message).foregroundStyle(Color.stoneInk)
                } else {
                    ProgressView()
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Funding")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func statusLabel(_ status: String) -> String {
        switch status {
        case "open": "Open"
        case "coming_soon": "Soon"
        default: "Closed"
        }
    }

    private func load() async {
        do {
            let board = try await client.funding()
            grant = board.grants.first { $0.id == id }
            if grant == nil { message = "This opportunity isn't on the list." }
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This opportunity could not be loaded."
        }
    }
}

struct WorkshopCourseView: View {
    @Bindable var session: AppSession
    var category: String
    var slug: String
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL
    @State private var course: WorkshopCourse?
    @State private var message: String?
    private let pink = Color(red: 219 / 255, green: 39 / 255, blue: 119 / 255)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let course {
                    if let badge = course.badge, !badge.isEmpty {
                        Text(badge).font(.caption.weight(.bold)).foregroundStyle(pink)
                    }
                    Text(course.name)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    if let dates = course.dates, !dates.isEmpty {
                        Text(dates).font(.subheadline).foregroundStyle(Color.stoneMuted)
                    }
                    if let summary = course.summary, !summary.isEmpty {
                        Text(summary).font(.body).foregroundStyle(Color.stoneInk)
                    }
                    if let link = course.signupURL ?? course.url, let url = URL(string: link) {
                        Button(course.signupURL == nil ? "Register on Eventbrite" : "Register") { openURL(url) }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(pink)
                    }
                } else if let message {
                    Text(message).foregroundStyle(Color.stoneInk)
                } else {
                    ProgressView()
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Workshop")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        do {
            let page = try await client.workshopCategory(category)
            course = page.courses.first { $0.slug == slug }
            if course == nil { message = "This workshop isn't on the list." }
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This workshop could not be loaded."
        }
    }
}

struct WorkshopEventView: View {
    @Bindable var session: AppSession
    var category: String
    var title: String
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL
    @State private var event: WorkshopEvent?
    @State private var message: String?
    private let pink = Color(red: 219 / 255, green: 39 / 255, blue: 119 / 255)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let event {
                    Text(event.title)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    if let dates = event.dates, !dates.isEmpty {
                        Text(dates).font(.subheadline.weight(.semibold)).foregroundStyle(pink)
                    }
                    if let location = event.location, !location.isEmpty {
                        Text(location).font(.subheadline).foregroundStyle(Color.stoneMuted)
                    }
                    if let description = event.description, !description.isEmpty {
                        Text(description).font(.body).foregroundStyle(Color.stoneInk)
                    }
                    if let link = event.url, let url = URL(string: link) {
                        Button("Open event") { openURL(url) }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(pink)
                    }
                } else if let message {
                    Text(message).foregroundStyle(Color.stoneInk)
                } else {
                    ProgressView()
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        do {
            let page = try await client.workshopCategory(category)
            event = page.events.first { $0.title == title }
            if event == nil { message = "This event isn't on the list." }
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This event could not be loaded."
        }
    }
}
