import SwiftUI

struct WelcomeAlerts: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @State private var items: [SiteNotificationItem] = []

    var body: some View {
        Group {
            if !items.isEmpty {
                AnnouncementCards(items: items, tint: .welcomeRed)
            }
        }
        .task { await load() }
    }

    private func load() async {
        guard session.account?.welcomeHub == true else { return }
        do {
            items = try await client.welcomeAnnouncements().notifications
        } catch APIError.unauthorized {
            session.signOut()
        } catch {
            items = []
        }
    }
}

struct CreativeAlerts: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @State private var items: [SiteNotificationItem] = []

    var body: some View {
        Group {
            if !items.isEmpty {
                AnnouncementCards(items: items, tint: .ecoOrange)
            }
        }
        .task { await load() }
    }

    private func load() async {
        do {
            items = try await client.creativeAnnouncements().notifications
        } catch APIError.unauthorized {
            session.signOut()
        } catch {
            items = []
        }
    }
}

struct AnnouncementCards: View {
    var items: [SiteNotificationItem]
    var tint: Color
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items) { item in
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.label.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.1)
                        .foregroundStyle(item.type == "urgent" ? Color.red : tint)
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(Color.stoneInk)
                    if let body = item.body, !body.isEmpty {
                        Text(body)
                            .font(.subheadline)
                            .foregroundStyle(Color.stoneLabel)
                    }
                    if let link = item.link, let url = AnnouncementLink.url(link, base: APIConfiguration.baseURL) {
                        Button((item.linkLabel?.isEmpty == false ? item.linkLabel : nil) ?? "Open") {
                            openURL(url)
                        }
                        .font(.subheadline.weight(.semibold))
                        .tint(tint)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(alignment: .leading) { Rectangle().fill(tint).frame(width: 3) }
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.stoneLine, lineWidth: 1))
            }
        }
    }
}

enum AnnouncementLink {
    static func url(_ link: String, base: URL) -> URL? {
        if link.hasPrefix("http://") || link.hasPrefix("https://") || link.hasPrefix("mailto:") {
            return URL(string: link)
        }
        guard link.hasPrefix("/") else { return nil }
        return WelcomeFormCatalog.downloadURL(path: link, base: base)
    }
}

struct StudentAnnouncementsView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL

    @State private var events: [StudentEventItem] = []
    @State private var phase: LoadPhase = .loading

    private enum LoadPhase {
        case loading
        case ready
        case failed(String)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Student Announcements")
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Stay updated with VFS achievements, upcoming events, and opportunities for growth and connection.")
                    .font(.body)
                    .foregroundStyle(Color.stoneLabel)

                Text("VFS Achievements")
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Button("View all on VFS Blog") {
                    if let url = URL(string: AchievementCatalog.blog) { openURL(url) }
                }
                .tint(Color.welcomeRed)

                ForEach(Array(AchievementCatalog.items.enumerated()), id: \.offset) { _, item in
                    Button {
                        if let url = URL(string: AchievementCatalog.blog) { openURL(url) }
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(item.category.uppercased())
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(1.1)
                                    .foregroundStyle(Color.welcomeRed)
                                Spacer()
                                Text(item.date)
                                    .font(.caption)
                                    .foregroundStyle(Color.stoneLabel)
                            }
                            Text(item.title)
                                .font(.headline)
                                .foregroundStyle(Color.stoneInk)
                                .multilineTextAlignment(.leading)
                            Text(item.summary)
                                .font(.subheadline)
                                .foregroundStyle(Color.stoneLabel)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }

                Text("Student Events & Webinars")
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(Color.stoneInk)

                switch phase {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    Text(message)
                        .foregroundStyle(Color.stoneInk)
                case .ready:
                    if events.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No upcoming events")
                                .font(.headline)
                                .foregroundStyle(Color.stoneInk)
                            Text("Check back soon for new events and webinars!")
                                .font(.subheadline)
                                .foregroundStyle(Color.stoneLabel)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        ForEach(events) { event in
                            VStack(alignment: .leading, spacing: 6) {
                                if let type = event.type, !type.isEmpty {
                                    Text(type.uppercased())
                                        .font(.system(size: 10, weight: .bold))
                                        .tracking(1.1)
                                        .foregroundStyle(Color.welcomeRed)
                                }
                                Text(event.title)
                                    .font(.headline)
                                    .foregroundStyle(Color.stoneInk)
                                if let date = event.date, !date.isEmpty {
                                    Text(date)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.stoneLabel)
                                }
                                if let time = event.time, !time.isEmpty {
                                    Text(time)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.stoneLabel)
                                }
                                if let location = event.location, !location.isEmpty {
                                    Text(location)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.stoneLabel)
                                }
                                if let summary = event.summary, !summary.isEmpty {
                                    Text(summary)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.stoneLabel)
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Announcements")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        do {
            let feed = try await client.welcomeAnnouncements()
            events = feed.studentAnnouncements
            phase = .ready
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            phase = .failed(error.message)
        } catch {
            phase = .failed("Announcements could not be loaded.")
        }
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
