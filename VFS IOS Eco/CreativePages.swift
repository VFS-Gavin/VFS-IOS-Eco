import SwiftUI

nonisolated struct DiscoverySearchResponse: Decodable {
    var results: [DiscoveryHit]
}

nonisolated struct DiscoveryHit: Decodable, Identifiable {
    var id: String
    var title: String
    var type: String?
    var year: String?
    var poster: String?
    var slug: String?
    var resultType: String?

    enum CodingKeys: String, CodingKey {
        case id, title, name, type, year, poster, photo, avatar, slug, department
        case posterURL = "poster_url"
        case resultType = "result_type"
        case mediaType = "media_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let text = try? container.decode(String.self, forKey: .id) {
            id = text
        } else if let number = try? container.decode(Int.self, forKey: .id) {
            id = String(number)
        } else if let slug = try? container.decode(String.self, forKey: .slug) {
            id = slug
        } else {
            id = UUID().uuidString
        }
        let named = try container.decodeIfPresent(String.self, forKey: .name)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? named ?? "Untitled"
        type = try container.decodeIfPresent(String.self, forKey: .type)
            ?? container.decodeIfPresent(String.self, forKey: .mediaType)
            ?? container.decodeIfPresent(String.self, forKey: .department)
        if let text = try? container.decode(String.self, forKey: .year) {
            year = text
        } else if let number = try? container.decode(Int.self, forKey: .year) {
            year = String(number)
        } else {
            year = nil
        }
        poster = try container.decodeIfPresent(String.self, forKey: .poster)
            ?? container.decodeIfPresent(String.self, forKey: .posterURL)
            ?? container.decodeIfPresent(String.self, forKey: .photo)
            ?? container.decodeIfPresent(String.self, forKey: .avatar)
        slug = try container.decodeIfPresent(String.self, forKey: .slug)
        resultType = try container.decodeIfPresent(String.self, forKey: .resultType)
    }
}

nonisolated struct FacilitiesResponse: Decodable {
    var facilities: [FacilityItem]
}

nonisolated struct FacilityItem: Decodable, Identifiable, Equatable {
    var id: Int
    var name: String
    var kind: String?
    var capacity: Int?
    var description: String?
    var imageURL: String?
    var amenities: [String]?

    enum CodingKeys: String, CodingKey {
        case id, name, kind, capacity, description, amenities
        case imageURL = "image_url"
    }
}

struct DiscoveryView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @State private var query = ""
    @State private var type = ""
    @State private var hits: [DiscoveryHit] = []
    @State private var message: String?
    @State private var searching = false
    private let accent = Color(red: 14 / 255, green: 165 / 255, blue: 233 / 255)
    private let types = [
        ("", "All"),
        ("film", "Films"),
        ("tv", "TV"),
        ("game", "Games"),
        ("book", "Books"),
        ("person", "People"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Explore")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("the Unknown")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(accent)
                Text("Search a title to rate it or add it to your catalogue. Pitches and Top 5s have their own pages — use the cards below.")
                    .font(.body)
                    .foregroundStyle(Color.stoneMuted)
                CreativeSearchField(
                    placeholder: type == "person" ? "Search a director, actor, or @classmate..." : "Search a film, show, game, or book to rate it...",
                    text: $query,
                    identifier: "discovery-search"
                ) {
                    Task { await search() }
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(types, id: \.0) { item in
                            Button(item.1) {
                                type = item.0
                                if query.count >= 2 { Task { await search() } }
                            }
                            .buttonStyle(.plain)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundStyle(type == item.0 ? Color.card : Color.stoneMuted)
                            .background(type == item.0 ? Color.stoneInk : Color.clear)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.stoneLine, lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                if searching { ProgressView() }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                ForEach(hits) { hit in
                    discoveryRow(hit)
                }
                NavigationLink(value: CreativeRoute.discoveryList(.pitches)) {
                    discoveryCard("Write an elevator pitch", "One sentence for the concept, then a fuller write-up if you want. Posted on the pitches page, not by searching a title.", cue: "Open pitches")
                }
                .buttonStyle(.plain)
                NavigationLink(value: CreativeRoute.discoveryList(.top5)) {
                    discoveryCard("Build your Top 5", "The films, games, books, and people that shaped you, with a note on why each one matters.", cue: "Your Top 5")
                }
                .buttonStyle(.plain)
                discoveryCard("Rate what you've seen", "Search the title above, open it, then rate, review, or add it to your catalogue.", cue: "Focus search")
                Button {
                    type = "person"
                } label: {
                    discoveryCard("Find people", "Search @classmates, or look up directors and actors. Follow taste that matches yours, and find collaborators from pitches.", cue: "Search people")
                }
                .buttonStyle(.plain)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        browseLink("Elevator Pitches", .pitches)
                        browseLink("Top 5 Rankings", .top5)
                        browseLink("Creator Reviews", .reviews)
                        browseLink("Community Taste", .taste)
                        browseLink("Weekly Challenges", .challenges)
                    }
                }
                SiteFooter(session: session)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Creative Engine")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func discoveryRow(_ hit: DiscoveryHit) -> some View {
        if hit.resultType == "profile", let slug = hit.slug, !slug.isEmpty {
            NavigationLink(value: CreativeRoute.profile(slug)) {
                discoveryRowBody(hit)
            }
            .buttonStyle(.plain)
        } else {
            discoveryRowBody(hit)
        }
    }

    private func discoveryRowBody(_ hit: DiscoveryHit) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if let poster = hit.poster, poster.hasPrefix("http"), let url = URL(string: poster) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.stoneLine
                }
                .frame(width: 42, height: 58)
                .clipped()
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(hit.title).font(.subheadline.weight(.semibold)).foregroundStyle(Color.stoneInk)
                HStack(spacing: 8) {
                    if let type = hit.type, !type.isEmpty {
                        Text(type.uppercased())
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(accent)
                    }
                    if let year = hit.year, !year.isEmpty {
                        Text(year).font(.caption).foregroundStyle(Color.stoneMuted)
                    }
                }
            }
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card)
        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
    }

    private func browseLink(_ title: String, _ kind: DiscoveryListKind) -> some View {
        NavigationLink(value: CreativeRoute.discoveryList(kind)) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(accent.opacity(0.45), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func discoveryCard(_ title: String, _ detail: String, cue: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(Color.stoneInk)
            Text(detail).font(.caption).foregroundStyle(Color.stoneMuted)
            Text(cue).font(.caption.weight(.bold)).foregroundStyle(accent)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.stoneLine, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            hits = []
            message = nil
            return
        }
        searching = true
        defer { searching = false }
        do {
            hits = try await client.discoverySearch(query: trimmed, type: type)
            message = hits.isEmpty ? (type == "person" ? "No people matched." : "No titles matched.") : nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            hits = []
            message = text
        } catch {
            hits = []
            message = "Search isn't available from the app yet."
        }
    }
}

struct FacilitiesView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @State private var category: String?
    @State private var facilities: [FacilityItem] = []
    @State private var message: String?
    @State private var loading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Studios & Facilities")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(Color.stoneMuted)
                if let category {
                    Button("All resources") { self.category = nil }
                        .buttonStyle(.plain)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(red: 8 / 255, green: 145 / 255, blue: 178 / 255))
                    Text(categoryTitle(category))
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    if loading { ProgressView() }
                    if let message {
                        Text(message).font(.body).foregroundStyle(Color.stoneMuted)
                    }
                    ForEach(filtered(category)) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name).font(.headline).foregroundStyle(Color.stoneInk)
                            if let description = item.description, !description.isEmpty {
                                Text(description).font(.subheadline).foregroundStyle(Color.stoneMuted)
                            }
                            if let capacity = item.capacity {
                                Text("Capacity \(capacity)").font(.caption).foregroundStyle(Color.stoneLabel)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.card)
                        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
                    }
                } else {
                    facilityCard("VFS Studios", "Facilities", "Production stages, screening rooms, recording suites, and creative spaces — reserve a VFS studio for your next project.", key: "studios")
                    facilityCard("VFS Studios", "Equipment", "Cameras, lighting rigs, audio gear, and production kits — request the equipment you need for your shoot.", key: "equipment")
                    facilityCard("Prop Room", "Acting props", "Furniture, costumes, and set pieces from the acting prop room. Request a prop the same way you book a studio.", key: "props")
                }
                SiteFooter(session: session)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Resources")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func facilityCard(_ title: String, _ subtitle: String, _ detail: String, key: String) -> some View {
        Button {
            category = key
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.system(size: 28, weight: .bold, design: .serif)).foregroundStyle(Color.stoneInk)
                Text(subtitle).font(.body.weight(.medium)).foregroundStyle(Color.stoneMuted)
                Text(detail).font(.subheadline).foregroundStyle(Color.stoneMuted)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.card)
            .overlay(alignment: .top) { Rectangle().fill(Color(red: 8 / 255, green: 145 / 255, blue: 178 / 255)).frame(height: 4) }
            .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func categoryTitle(_ key: String) -> String {
        switch key {
        case "equipment": "Equipment"
        case "props": "Prop Room"
        default: "VFS Studios"
        }
    }

    private func filtered(_ key: String) -> [FacilityItem] {
        let equipmentWords = ["equipment", "camera", "gear", "kit", "lens", "tripod pack", "lighting package"]
        return facilities.filter { item in
            let blob = (item.name + " " + (item.description ?? "")).lowercased()
            let prop = item.kind == "prop"
            switch key {
            case "props": return prop
            case "studios": return !prop && !equipmentWords.contains { blob.contains($0) }
            case "equipment": return !prop && equipmentWords.contains { blob.contains($0) }
            default: return true
            }
        }
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            facilities = try await client.facilities()
            message = nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The booking list isn't available from the app yet."
        }
    }
}

struct StudiosView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Student Crews,")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Real Clients")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .italic()
                    .foregroundStyle(Color(red: 164 / 255, green: 16 / 255, blue: 52 / 255))
                Text("Past and ongoing VFS Studios productions.")
                    .font(.body)
                    .foregroundStyle(Color.stoneMuted)
                ForEach(StudioCatalog.projects) { project in
                    NavigationLink(value: CreativeRoute.studio(project.id)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(project.title).font(.system(size: 22, weight: .bold, design: .serif)).foregroundStyle(Color.stoneInk)
                            Text(project.client).font(.subheadline).foregroundStyle(Color(red: 164 / 255, green: 16 / 255, blue: 52 / 255))
                            Text("\(project.program) · \(project.year)").font(.caption).foregroundStyle(Color.stoneMuted)
                            Text(project.description).font(.subheadline).foregroundStyle(Color.stoneLabel).lineLimit(3)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.card)
                        .overlay(alignment: .leading) { Rectangle().fill(Color(red: 164 / 255, green: 16 / 255, blue: 52 / 255)).frame(width: 4) }
                        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("VFS Studios")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StudioDetailView: View {
    var project: StudioProject
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(project.title).font(.system(size: 32, weight: .bold, design: .serif)).foregroundStyle(Color.stoneInk)
                Text(project.client).foregroundStyle(Color(red: 164 / 255, green: 16 / 255, blue: 52 / 255))
                Text(project.description).foregroundStyle(Color.stoneMuted)
                if let synopsis = project.synopsis {
                    Text(synopsis).foregroundStyle(Color.stoneInk)
                }
                if let support = project.support {
                    Text(support).foregroundStyle(Color.stoneMuted)
                }
                ForEach(project.quotes) { quote in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("“\(quote.text)”").italic().foregroundStyle(Color.stoneInk)
                        Text("\(quote.author), \(quote.role)").font(.caption).foregroundStyle(Color.stoneMuted)
                    }
                }
                if !project.team.isEmpty {
                    Text("Team").font(.headline).foregroundStyle(Color.stoneInk)
                    ForEach(project.team) { person in
                        Text("\(person.name) — \(person.role)").font(.subheadline).foregroundStyle(Color.stoneLabel)
                    }
                }
                ForEach(project.links) { link in
                    if let url = URL(string: link.url) {
                        Button(link.label) { openURL(url) }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.ecoOrange)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.stone)
        .navigationTitle(project.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
