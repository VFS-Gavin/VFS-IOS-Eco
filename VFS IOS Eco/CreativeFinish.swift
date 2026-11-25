import PhotosUI
import SwiftUI
import UIKit

nonisolated struct OkFlag: Decodable {
    var ok: Bool?
    var success: Bool?
}

nonisolated struct OwnTaste: Decodable {
    var favorites: [TasteItem]
    var highlighted: [TasteItem]
    var seen: [TasteItem]

    enum CodingKeys: String, CodingKey {
        case favorites, highlighted, seen
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        favorites = Self.rows(container, .favorites)
        highlighted = Self.rows(container, .highlighted)
        seen = Self.rows(container, .seen)
    }

    private static func rows(_ container: KeyedDecodingContainer<CodingKeys>, _ key: CodingKeys) -> [TasteItem] {
        if let list = try? container.decode([TasteItem].self, forKey: key) { return list }
        if let groups = try? container.decode([String: [TasteItem]].self, forKey: key) {
            return groups.values.flatMap { $0 }
        }
        return []
    }
}

nonisolated struct TasteItem: Decodable, Identifiable, Equatable {
    var id: Int
    var mediaType: String
    var externalID: String
    var title: String
    var posterURL: String?
    var year: String?
    var highlighted: Bool
    var note: String?

    enum CodingKeys: String, CodingKey {
        case id, title, year, note
        case mediaType = "media_type"
        case externalID = "external_id"
        case posterURL = "poster_url"
        case highlighted = "is_highlighted"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType) ?? ""
        externalID = try container.decodeIfPresent(String.self, forKey: .externalID) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        posterURL = try container.decodeIfPresent(String.self, forKey: .posterURL)
        if let text = try? container.decode(String.self, forKey: .year) {
            year = text
        } else if let number = try? container.decode(Int.self, forKey: .year) {
            year = String(number)
        } else {
            year = nil
        }
        highlighted = (try? container.decode(Bool.self, forKey: .highlighted)) ?? false
        note = try container.decodeIfPresent(String.self, forKey: .note)
    }
}

nonisolated struct TasteSearchPage: Decodable {
    var items: [TasteHit]
}

nonisolated struct TasteHit: Decodable, Identifiable {
    var id: String
    var title: String
    var type: String
    var year: String?
    var poster: String?

    enum CodingKeys: String, CodingKey {
        case id, title, type, year, poster
        case posterURL = "poster_url"
        case mediaType = "media_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let text = try? container.decode(String.self, forKey: .id) {
            id = text
        } else if let number = try? container.decode(Int.self, forKey: .id) {
            id = String(number)
        } else {
            id = ""
        }
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Untitled"
        type = try container.decodeIfPresent(String.self, forKey: .type)
            ?? container.decodeIfPresent(String.self, forKey: .mediaType)
            ?? "film"
        if let text = try? container.decode(String.self, forKey: .year) {
            year = text
        } else if let number = try? container.decode(Int.self, forKey: .year) {
            year = String(number)
        } else {
            year = nil
        }
        poster = try container.decodeIfPresent(String.self, forKey: .poster)
            ?? container.decodeIfPresent(String.self, forKey: .posterURL)
    }

    func favoriteBody(highlighted: Bool, note: String?) -> [String: Any] {
        var body: [String: Any] = [
            "media_type": type,
            "external_id": id,
            "title": title,
        ]
        if let poster, !poster.isEmpty { body["poster_url"] = poster }
        if let year, !year.isEmpty { body["year"] = year }
        if highlighted { body["is_highlighted"] = true }
        if let note, !note.isEmpty { body["note"] = note }
        return body
    }
}

nonisolated struct DiscoveryTitlePage: Decodable {
    var media: DiscoveryMedia
    var myReview: MyReview?
    var community: CommunityStats?
    var top5Users: Top5Board?

    enum CodingKeys: String, CodingKey {
        case media, myReview, community, top5Users
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        media = try container.decode(DiscoveryMedia.self, forKey: .media)
        myReview = try container.decodeIfPresent(MyReview.self, forKey: .myReview)
        community = try? container.decode(CommunityStats.self, forKey: .community)
        top5Users = try? container.decode(Top5Board.self, forKey: .top5Users)
    }
}

nonisolated struct CommunityStats: Decodable {
    var average: Double?
    var count: Int
    var reviews: [CommunityReview]

    enum CodingKeys: String, CodingKey {
        case average = "avg_rating"
        case count = "review_count"
        case reviews
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let number = try? container.decode(Double.self, forKey: .average) {
            average = number
        } else if let number = try? container.decode(Int.self, forKey: .average) {
            average = Double(number)
        } else {
            average = nil
        }
        count = (try? container.decode(Int.self, forKey: .count)) ?? 0
        reviews = (try? container.decode([CommunityReview].self, forKey: .reviews)) ?? []
    }
}

nonisolated struct CommunityReview: Decodable, Identifiable {
    var id: Int
    var name: String
    var slug: String?
    var rating: Double
    var review: String?

    enum CodingKeys: String, CodingKey {
        case id, user, rating, review
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        let person = try container.decodeIfPresent(ReviewAuthor.self, forKey: .user)
        name = person?.name ?? ""
        slug = person?.slug
        if let number = try? container.decode(Double.self, forKey: .rating) {
            rating = number
        } else if let number = try? container.decode(Int.self, forKey: .rating) {
            rating = Double(number)
        } else if let text = try? container.decode(String.self, forKey: .rating), let number = Double(text) {
            rating = number
        } else {
            rating = 0
        }
        review = try container.decodeIfPresent(String.self, forKey: .review)
    }
}

nonisolated struct ReviewAuthor: Decodable {
    var name: String?
    var slug: String?
}

nonisolated struct Top5Board: Decodable {
    var preview: [Top5Person]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        preview = (try? container.decode([Top5Person].self, forKey: .preview)) ?? []
    }

    enum CodingKeys: String, CodingKey { case preview }
}

nonisolated struct Top5Person: Decodable, Identifiable {
    var name: String
    var slug: String
    var note: String?
    var id: String { slug }

    enum CodingKeys: String, CodingKey { case name, slug, note }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        slug = try container.decodeIfPresent(String.self, forKey: .slug) ?? ""
        note = try container.decodeIfPresent(String.self, forKey: .note)
    }
}

nonisolated struct DiscoveryMedia: Decodable {
    var type: String
    var externalID: String
    var title: String
    var summary: String?
    var poster: String?
    var year: String?

    enum CodingKeys: String, CodingKey {
        case type, title, description, poster, year, id
        case externalID = "external_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        if let text = try? container.decode(String.self, forKey: .externalID), !text.isEmpty {
            externalID = text
        } else if let text = try? container.decode(String.self, forKey: .id) {
            externalID = text
        } else if let number = try? container.decode(Int.self, forKey: .id) {
            externalID = String(number)
        } else {
            externalID = ""
        }
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Untitled"
        summary = try container.decodeIfPresent(String.self, forKey: .description)
        poster = try container.decodeIfPresent(String.self, forKey: .poster)
        if let text = try? container.decode(String.self, forKey: .year) {
            year = text
        } else if let number = try? container.decode(Int.self, forKey: .year) {
            year = String(number)
        } else {
            year = nil
        }
    }
}

nonisolated struct MyReview: Decodable {
    var id: Int
    var rating: Double
    var review: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        if let number = try? container.decode(Double.self, forKey: .rating) {
            rating = number
        } else if let text = try? container.decode(String.self, forKey: .rating), let number = Double(text) {
            rating = number
        } else {
            rating = 0
        }
        review = try container.decodeIfPresent(String.self, forKey: .review)
    }

    enum CodingKeys: String, CodingKey {
        case id, rating, review
    }
}

struct TasteEditorView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @State private var board: OwnTaste?
    @State private var type = "film"
    @State private var query = ""
    @State private var hits: [TasteHit] = []
    @State private var notes: [Int: String] = [:]
    @State private var message: String?
    private let types = ["film", "tv", "game", "book"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your catalogue")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Search a title, add it, mark it seen, and choose up to five highlights.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                Picker("Type", selection: $type) {
                    ForEach(types, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)
                TextField("Search", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { Task { await search() } }
                if let message {
                    Text(message).font(.caption).foregroundStyle(Color.stoneMuted)
                }
                ForEach(hits) { hit in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(hit.title).font(.subheadline.weight(.semibold)).foregroundStyle(Color.stoneInk)
                            if let year = hit.year { Text(year).font(.caption).foregroundStyle(Color.stoneMuted) }
                        }
                        Spacer()
                        Button("Add") { Task { await add(hit) } }.font(.caption.weight(.bold)).foregroundStyle(Color.ecoOrange)
                        Button("Seen") { Task { await seen(hit) } }.font(.caption.weight(.bold)).foregroundStyle(Color.ecoOrange)
                    }
                }
                Text("Top 5")
                    .font(.title2.bold())
                    .foregroundStyle(Color.stoneInk)
                ForEach(board?.favorites ?? []) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Toggle(item.title, isOn: highlightBinding(item))
                            Button("Remove") { Task { await remove(item) } }
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255))
                        }
                        if item.highlighted || notes[item.id] != nil {
                            TextField("Why it matters", text: noteBinding(item))
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                Button("Save Top 5") { Task { await saveHighlights() } }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.ecoOrange)
                if let seen = board?.seen, !seen.isEmpty {
                    Text("Watch list")
                        .font(.title2.bold())
                        .foregroundStyle(Color.stoneInk)
                    ForEach(seen) { item in
                        Text(item.title).font(.subheadline).foregroundStyle(Color.stoneInk)
                    }
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Catalogue")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func highlightBinding(_ item: TasteItem) -> Binding<Bool> {
        Binding(get: { board?.favorites.first { $0.id == item.id }?.highlighted ?? false }, set: { on in
            guard var favorites = board?.favorites, let index = favorites.firstIndex(where: { $0.id == item.id }) else { return }
            let already = favorites.filter(\.highlighted).count
            if on, !favorites[index].highlighted, already >= 5 {
                message = "Max 5 highlights allowed"
                return
            }
            favorites[index].highlighted = on
            board?.favorites = favorites
        })
    }

    private func noteBinding(_ item: TasteItem) -> Binding<String> {
        Binding(get: { notes[item.id] ?? item.note ?? "" }, set: { notes[item.id] = $0 })
    }

    private func load() async {
        do {
            let page = try await client.tasteBoard()
            board = page
            message = nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "Your catalogue could not be loaded."
        }
    }

    private func search() async {
        guard query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else { return }
        do {
            hits = try await client.searchTaste(type: type, query: query)
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "That search could not be completed."
        }
    }

    private func add(_ hit: TasteHit) async {
        do {
            try await client.addTasteItem(hit)
            await load()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "That title could not be added."
        }
    }

    private func remove(_ item: TasteItem) async {
        do {
            try await client.removeTasteItem(id: item.id)
            await load()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "That title could not be removed."
        }
    }

    private func seen(_ hit: TasteHit) async {
        do {
            try await client.markSeen(hit, seen: true)
            await load()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "That title could not be marked seen."
        }
    }

    private func saveHighlights() async {
        guard var favorites = board?.favorites else { return }
        for index in favorites.indices {
            if let note = notes[favorites[index].id] {
                favorites[index].note = note
            }
        }
        do {
            try await client.saveHighlights(favorites)
            message = nil
            await load()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The Top 5 could not be saved."
        }
    }
}

struct DiscoveryTitleView: View {
    @Bindable var session: AppSession
    var type: String
    var externalID: String
    var client: APIClient = APIClient()
    @State private var page: DiscoveryTitlePage?
    @State private var rating = 4.0
    @State private var review = ""
    @State private var message: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if let media = page?.media {
                    if let poster = media.poster, let url = URL(string: poster) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Color.stoneLine.frame(height: 180)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    Text(media.title)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    if let year = media.year, !year.isEmpty {
                        Text(year).font(.subheadline).foregroundStyle(Color.stoneMuted)
                    }
                    if let summary = media.summary, !summary.isEmpty {
                        Text(summary).font(.body).foregroundStyle(Color.stoneMuted)
                    }
                    if let mine = page?.myReview {
                        Text("Your rating \(mine.rating, format: .number.precision(.fractionLength(1)))")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.ecoOrange)
                        if let text = mine.review, !text.isEmpty {
                            Text(text).font(.subheadline).foregroundStyle(Color.stoneInk)
                        }
                        Button("Remove review") { Task { await remove(mine.id) } }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255))
                    }
                    Stepper(value: $rating, in: 0.5...5, step: 0.5) {
                        Text("Rating \(rating, format: .number.precision(.fractionLength(1)))")
                    }
                    TextField("Review", text: $review, axis: .vertical).textFieldStyle(.roundedBorder)
                    Button("Save review") { Task { await save(media) } }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.ecoOrange)
                    Button("Add to catalogue") { Task { await add(media) } }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.ecoOrange)
                    Button("Mark seen") { Task { await seen(media) } }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.ecoOrange)
                    if let community = page?.community, community.count > 0 {
                        Text(community.average.map { "Community \(community.count) reviews · \($0, format: .number.precision(.fractionLength(1)))" } ?? "Community \(community.count) reviews")
                            .font(.headline)
                            .foregroundStyle(Color.stoneInk)
                            .padding(.top, 8)
                        ForEach(community.reviews) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                if let slug = item.slug, !slug.isEmpty {
                                    CreativeLink(route: .profile(slug)) {
                                        Text(item.name.isEmpty ? "Student" : item.name)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Color.ecoOrange)
                                    }
                                    .buttonStyle(.plain)
                                } else if !item.name.isEmpty {
                                    Text(item.name).font(.caption.weight(.semibold)).foregroundStyle(Color.stoneInk)
                                }
                                Text("\(item.rating, format: .number.precision(.fractionLength(1))) / 5")
                                    .font(.caption)
                                    .foregroundStyle(Color.stoneMuted)
                                if let text = item.review, !text.isEmpty {
                                    Text(text).font(.subheadline).foregroundStyle(Color.stoneInk)
                                }
                            }
                        }
                    }
                    if let people = page?.top5Users?.preview.filter({ !$0.slug.isEmpty }), !people.isEmpty {
                        Text("In a Top 5")
                            .font(.headline)
                            .foregroundStyle(Color.stoneInk)
                            .padding(.top, 8)
                        ForEach(people) { person in
                            CreativeLink(route: .profile(person.slug)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(person.name).font(.subheadline.weight(.semibold)).foregroundStyle(Color.ecoOrange)
                                    if let note = person.note, !note.isEmpty {
                                        Text(note).font(.subheadline).foregroundStyle(Color.stoneInk)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else if message == nil {
                    ProgressView()
                }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Title")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        do {
            let loaded = try await client.discoveryTitle(type: type, externalID: externalID)
            page = loaded
            if let mine = loaded.myReview {
                rating = mine.rating
                review = mine.review ?? ""
            }
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This title could not be loaded."
        }
    }

    private func save(_ media: DiscoveryMedia) async {
        do {
            message = try await client.saveReview(type: media.type.isEmpty ? type : media.type, externalID: media.externalID.isEmpty ? externalID : media.externalID, title: media.title, poster: media.poster, year: media.year, rating: rating, review: review)
            await load()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The review could not be saved."
        }
    }

    private func remove(_ id: Int) async {
        do {
            message = try await client.deleteReview(id: id)
            await load()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The review could not be removed."
        }
    }

    private func add(_ media: DiscoveryMedia) async {
        let hit = TasteHit(type: media.type.isEmpty ? type : media.type, id: media.externalID.isEmpty ? externalID : media.externalID, title: media.title, year: media.year, poster: media.poster)
        do {
            try await client.addTasteItem(hit)
            message = nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "That title could not be added."
        }
    }

    private func seen(_ media: DiscoveryMedia) async {
        let hit = TasteHit(type: media.type.isEmpty ? type : media.type, id: media.externalID.isEmpty ? externalID : media.externalID, title: media.title, year: media.year, poster: media.poster)
        do {
            try await client.markSeen(hit, seen: true)
            message = nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "That title could not be marked seen."
        }
    }
}

extension TasteHit {
    init(type: String, id: String, title: String, year: String?, poster: String?) {
        self.id = id
        self.title = title
        self.type = type
        self.year = year
        self.poster = poster
    }
}

struct ChallengeReply: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @State private var bodyText = ""
    @State private var message: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Your response", text: $bodyText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            Button("Save response") { Task { await save() } }
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.ecoOrange)
            if let message {
                Text(message).font(.caption).foregroundStyle(Color.stoneMuted)
            }
        }
    }

    private func save() async {
        do {
            try await client.saveChallengeResponse(id: id, body: bodyText.trimmingCharacters(in: .whitespacesAndNewlines))
            message = nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The response could not be saved."
        }
    }
}

struct CollabCreateView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var details = ""
    @State private var roleType = "crew"
    @State private var roles = ""
    @State private var location = ""
    @State private var projectType = ""
    @State private var remote = false
    @State private var paid = false
    @State private var deadline = ""
    @State private var shootStart = ""
    @State private var shootEnd = ""
    @State private var contact = ""
    @State private var applyURL = ""
    @State private var showContact = true
    @State private var coverItem: PhotosPickerItem?
    @State private var coverData: Data?
    @State private var galleryItems: [PhotosPickerItem] = []
    @State private var galleryData: [Data] = []
    @State private var message: String?
    @State private var saving = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Post a collaboration")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                TextField("Title", text: $title).textFieldStyle(.roundedBorder)
                TextField("Description", text: $details, axis: .vertical).textFieldStyle(.roundedBorder)
                Picker("Project type", selection: $projectType) {
                    Text("Choose a type").tag("")
                    ForEach(["Short Film", "Music Video", "Animation", "Game", "Web Series", "Podcast", "ADR / Redubbing", "Portfolio Piece", "Other"], id: \.self) { Text($0).tag($0) }
                }
                Picker("These roles are", selection: $roleType) {
                    Text("Crew").tag("crew")
                    Text("Cast").tag("cast")
                    Text("Both").tag("both")
                }
                TextField("Roles needed, comma separated", text: $roles).textFieldStyle(.roundedBorder)
                Picker("Where", selection: $location) {
                    Text("Choose a city").tag("")
                    Text("Vancouver").tag("Vancouver")
                    Text("Surrey").tag("Surrey")
                    Text("Burnaby").tag("Burnaby")
                    Text("New Westminster").tag("New Westminster")
                    Text("Remote").tag("Remote")
                }
                Toggle("People can join remotely", isOn: $remote)
                Toggle("Paid", isOn: $paid)
                TextField("Apply by (YYYY-MM-DD)", text: $deadline).textFieldStyle(.roundedBorder)
                TextField("Shoot starts (YYYY-MM-DD)", text: $shootStart).textFieldStyle(.roundedBorder)
                TextField("Shoot ends (YYYY-MM-DD)", text: $shootEnd).textFieldStyle(.roundedBorder)
                TextField("What should they do?", text: $contact, axis: .vertical).textFieldStyle(.roundedBorder)
                TextField("https://", text: $applyURL).textFieldStyle(.roundedBorder)
                Toggle("Let people message you from the post", isOn: $showContact)
                PhotosPicker(selection: $coverItem, matching: .images) {
                    Text(coverData == nil ? "Add a cover" : "Replace cover")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.collabPurple)
                }
                .onChange(of: coverItem) { _, item in
                    Task { coverData = await Self.jpeg(item) }
                }
                PhotosPicker(selection: $galleryItems, maxSelectionCount: 5, matching: .images) {
                    Text(galleryData.isEmpty ? "Add gallery photos" : "\(galleryData.count) gallery photos")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.collabPurple)
                }
                .onChange(of: galleryItems) { _, items in
                    Task {
                        var files: [Data] = []
                        for item in items {
                            if let jpeg = await Self.jpeg(item) { files.append(jpeg) }
                        }
                        galleryData = files
                    }
                }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                Button(saving ? "Posting…" : "Post") { Task { await post() } }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.collabPurple)
                    .disabled(saving)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("New collab")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func post() async {
        saving = true
        defer { saving = false }
        let needed = roles.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        var body: [String: Any] = [
            "title": title.trimmingCharacters(in: .whitespacesAndNewlines),
            "description": details.trimmingCharacters(in: .whitespacesAndNewlines),
            "role_type": roleType,
            "remote_ok": remote,
            "is_paid": paid,
            "show_contact_button": showContact,
        ]
        if !projectType.isEmpty { body["project_type"] = projectType }
        if !needed.isEmpty { body["roles_needed"] = needed }
        let place = location.trimmingCharacters(in: .whitespacesAndNewlines)
        if !place.isEmpty { body["location"] = place }
        let due = deadline.trimmingCharacters(in: .whitespacesAndNewlines)
        if !due.isEmpty { body["deadline"] = due }
        let start = shootStart.trimmingCharacters(in: .whitespacesAndNewlines)
        if !start.isEmpty { body["shoot_start_date"] = start }
        let end = shootEnd.trimmingCharacters(in: .whitespacesAndNewlines)
        if !end.isEmpty { body["shoot_end_date"] = end }
        let note = contact.trimmingCharacters(in: .whitespacesAndNewlines)
        if !note.isEmpty { body["contact_instructions"] = note }
        let link = applyURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if !link.isEmpty { body["apply_url"] = link }
        do {
            message = try await client.createCollab(body, cover: coverData, gallery: galleryData)
            dismiss()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The collaboration could not be posted."
        }
    }

    private static func jpeg(_ item: PhotosPickerItem?) async -> Data? {
        guard let data = try? await item?.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return nil }
        return image.jpegData(compressionQuality: 0.85)
    }
}

struct GrantApplyView: View {
    @Bindable var session: AppSession
    var grantID: Int
    var client: APIClient = APIClient()
    @State private var name = ""
    @State private var program = ""
    @State private var year = ""
    @State private var projectTitle = ""
    @State private var concept = ""
    @State private var help = ""
    @State private var team = ""
    @State private var timeline = ""
    @State private var portfolio = ""
    @State private var projectID = 0
    @State private var ownProjects: [ManagedProject] = []
    @State private var message: String?
    @State private var saving = false
    @State private var filled = false
    private let years = ["Year 1", "Year 2", "Alumni (within 3 years)"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Grant application")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                field("Full Name", $name)
                field("VFS Program", $program)
                Picker("Year / Status", selection: $year) {
                    Text("Select one").tag("")
                    ForEach(years, id: \.self) { Text($0).tag($0) }
                }
                if !ownProjects.isEmpty {
                    Picker("Link a Portfolio Project", selection: $projectID) {
                        Text("None (use a link instead)").tag(0)
                        ForEach(ownProjects) { Text($0.title).tag($0.id) }
                    }
                }
                if projectID == 0 {
                    field("Portfolio Link", $portfolio)
                }
                field("Project Title", $projectTitle)
                field("Project Concept", $concept)
                field("How Will You Use the Funding?", $help)
                field("Team Members", $team)
                field("Timeline", $timeline)
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                Button(saving ? "Sending…" : "Submit application") { Task { await submit() } }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.ecoOrange)
                    .disabled(saving)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Apply")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !filled {
                name = session.account?.user.name ?? ""
                filled = true
            }
            if let board = try? await client.managePortfolio() {
                ownProjects = board.projects
            }
        }
    }

    private func field(_ label: String, _ text: Binding<String>) -> some View {
        TextField(label, text: text, axis: .vertical).textFieldStyle(.roundedBorder)
    }

    private func submit() async {
        saving = true
        defer { saving = false }
        var body: [String: Any] = [
            "funding_grant_id": grantID,
            "name": name.trimmingCharacters(in: .whitespacesAndNewlines),
            "email": session.account?.user.email ?? "",
            "program": program.trimmingCharacters(in: .whitespacesAndNewlines),
            "year": year.trimmingCharacters(in: .whitespacesAndNewlines),
            "project_title": projectTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            "concept": concept.trimmingCharacters(in: .whitespacesAndNewlines),
            "how_funding_helps": help.trimmingCharacters(in: .whitespacesAndNewlines),
            "timeline": timeline.trimmingCharacters(in: .whitespacesAndNewlines),
        ]
        let members = team.trimmingCharacters(in: .whitespacesAndNewlines)
        if !members.isEmpty { body["team_members"] = members }
        if projectID > 0 {
            body["creative_project_id"] = projectID
        } else {
            let link = portfolio.trimmingCharacters(in: .whitespacesAndNewlines)
            if !link.isEmpty { body["portfolio_link"] = link }
        }
        do {
            message = try await client.applyForGrant(body)
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The application could not be sent."
        }
    }
}

struct PitchEditorView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @State private var rows: [PitchDraft] = [PitchDraft()]
    @State private var message: String?
    @State private var saving = false
    private let categories = [
        ("feature_film", "Feature Film"),
        ("short_form", "Short Form"),
        ("video_game", "Video Game"),
        ("documentary", "Documentary"),
        ("tv_series", "TV Series"),
        ("animation", "Animation"),
        ("other", "Other"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Elevator pitches")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                ForEach($rows) { $row in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("One sentence", text: $row.pitch, axis: .vertical).textFieldStyle(.roundedBorder)
                        Picker("Category", selection: $row.category) {
                            Text("Choose").tag("")
                            ForEach(categories, id: \.0) { Text($0.1).tag($0.0) }
                        }
                        TextField("More detail", text: $row.detail, axis: .vertical).textFieldStyle(.roundedBorder)
                    }
                    .padding(12)
                    .background(Color.card)
                }
                if rows.count < 5 {
                    Button("Add pitch") { rows.append(PitchDraft()) }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.ecoOrange)
                }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                Button(saving ? "Saving…" : "Save pitches") { Task { await save() } }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.ecoOrange)
                    .disabled(saving)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Pitches")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        do {
            let page = try await client.ownProfile()
            let loaded = page.pitches.map { PitchDraft(savedID: $0.id, pitch: $0.pitch, category: $0.category ?? "", detail: $0.description ?? "") }
            if !loaded.isEmpty { rows = loaded }
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "Pitches could not be loaded."
        }
    }

    private func save() async {
        saving = true
        defer { saving = false }
        let pitches: [[String: Any]] = rows.compactMap { row in
            let text = row.pitch.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return nil }
            var item: [String: Any] = ["pitch": text, "category": row.category]
            if let id = row.savedID { item["id"] = id }
            let detail = row.detail.trimmingCharacters(in: .whitespacesAndNewlines)
            if !detail.isEmpty { item["description"] = detail }
            return item
        }
        do {
            try await client.savePitches(pitches)
            message = nil
            await load()
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The pitches could not be saved."
        }
    }
}

private struct PitchDraft: Identifiable {
    let id = UUID()
    var savedID: Int?
    var pitch = ""
    var category = ""
    var detail = ""
}
