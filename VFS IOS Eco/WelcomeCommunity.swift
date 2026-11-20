import SwiftUI

nonisolated struct AmbassadorDirectory: Decodable {
    var ambassadors: [AmbassadorCard]
}

nonisolated struct AmbassadorPage: Decodable {
    var ambassador: AmbassadorCard
}

nonisolated struct AmbassadorCard: Decodable, Identifiable, Equatable {
    var id: Int
    var name: String
    var program: String?
    var bio: String?
    var specialization: String?
    var profilePhoto: String?
    var interests: [String]
    var languages: [String]
    var country: String?
    var availabilityStatus: String?
    var lastActive: String?
    var contactEmail: String?

    enum CodingKeys: String, CodingKey {
        case id, name, program, bio, specialization, interests, languages, country
        case profilePhoto = "profile_photo"
        case availabilityStatus = "availability_status"
        case lastActive = "last_active_at"
        case contactEmail = "contact_email"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Unknown"
        program = try container.decodeIfPresent(String.self, forKey: .program)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        specialization = try container.decodeIfPresent(String.self, forKey: .specialization)
        profilePhoto = try container.decodeIfPresent(String.self, forKey: .profilePhoto)
        interests = (try? container.decode([String].self, forKey: .interests)) ?? []
        languages = (try? container.decode([String].self, forKey: .languages)) ?? []
        country = try container.decodeIfPresent(String.self, forKey: .country)
        availabilityStatus = try container.decodeIfPresent(String.self, forKey: .availabilityStatus)
        lastActive = try container.decodeIfPresent(String.self, forKey: .lastActive)
        contactEmail = try container.decodeIfPresent(String.self, forKey: .contactEmail)
    }
}

nonisolated struct ConversationStart: Decodable {
    var conversationID: Int

    enum CodingKeys: String, CodingKey {
        case conversationID = "conversation_id"
    }
}

nonisolated struct ChatPerson: Decodable {
    var name: String
}

nonisolated struct ChatIndex: Decodable {
    var conversations: [ChatThread]
    var messages: [ChatLine]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        conversations = (try? container.decode([ChatThread].self, forKey: .conversations)) ?? []
        messages = (try? container.decode([ChatLine].self, forKey: .messages)) ?? []
    }

    enum CodingKeys: String, CodingKey {
        case conversations, messages
    }
}

nonisolated struct ChatSend: Decodable {
    var message: ChatLine
}

nonisolated struct ChatThread: Decodable, Identifiable, Equatable {
    var id: Int
    var name: String
    var preview: String?
    var unread: Int

    enum CodingKeys: String, CodingKey {
        case id
        case otherUser = "other_user"
        case lastMessage = "last_message"
        case unread = "unread_count"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        unread = (try? container.decode(Int.self, forKey: .unread)) ?? 0
        name = (try? container.decode(ChatPerson.self, forKey: .otherUser))?.name ?? "Conversation"
        preview = (try? container.decode(ChatPreview.self, forKey: .lastMessage))?.body
    }
}

nonisolated struct ChatPreview: Decodable {
    var body: String?
}

nonisolated struct ChatLine: Decodable, Identifiable, Equatable {
    var id: Int
    var body: String
    var senderName: String
    var mine: Bool
    var time: String

    enum CodingKeys: String, CodingKey {
        case id, body
        case senderName = "sender_name"
        case mine = "is_mine"
        case time = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        body = try container.decodeIfPresent(String.self, forKey: .body) ?? ""
        senderName = try container.decodeIfPresent(String.self, forKey: .senderName) ?? ""
        mine = (try? container.decode(Bool.self, forKey: .mine)) ?? false
        time = try container.decodeIfPresent(String.self, forKey: .time) ?? ""
    }
}

struct AmbassadorsView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @State private var search = ""
    @State private var people: [AmbassadorCard] = []
    @State private var message: String?
    @State private var loading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Ambassador Directory")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Connect with experienced VFS ambassadors")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                TextField("Search ambassadors", text: $search)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { Task { await load() } }
                if loading { ProgressView() }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                ForEach(people) { person in
                    NavigationLink(value: WelcomeRoute.ambassador(person.id)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(person.name).font(.headline).foregroundStyle(Color.stoneInk)
                            if let program = person.program, !program.isEmpty {
                                Text(program).font(.subheadline).foregroundStyle(Color.welcomeRed)
                            }
                            if let status = person.availabilityStatus, !status.isEmpty {
                                Text(status.replacingOccurrences(of: "_", with: " ")).font(.caption).foregroundStyle(Color.stoneMuted)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.card)
                        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Ambassadors")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            people = try await client.ambassadors(search: search)
            message = people.isEmpty ? "No ambassadors match that search." : nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "Ambassadors aren't available from the app yet."
        }
    }
}

struct AmbassadorDetailView: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @Environment(\.openWelcomeRoute) private var openWelcome
    @State private var person: AmbassadorCard?
    @State private var message: String?
    @State private var starting = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let person {
                    Text(person.name)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    if let program = person.program, !program.isEmpty {
                        Text(program).font(.headline).foregroundStyle(Color.welcomeRed)
                    }
                    if let specialization = person.specialization, !specialization.isEmpty {
                        Text(specialization).font(.subheadline).foregroundStyle(Color.stoneInk)
                    }
                    if let bio = person.bio, !bio.isEmpty {
                        Text(bio).font(.body).foregroundStyle(Color.stoneMuted)
                    }
                    if !person.interests.isEmpty {
                        Text(person.interests.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundStyle(Color.stoneInk)
                    }
                    if !person.languages.isEmpty {
                        Text(person.languages.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(Color.stoneMuted)
                    }
                    if let email = person.contactEmail, !email.isEmpty {
                        Text(email).font(.subheadline).foregroundStyle(Color.stoneInk)
                    }
                    Button(starting ? "Opening…" : "Message") { Task { await start() } }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.welcomeRed)
                        .disabled(starting)
                } else if let message {
                    Text(message).foregroundStyle(Color.stoneInk)
                } else {
                    ProgressView()
                }
                if person != nil, let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Ambassador")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        do {
            person = try await client.ambassador(id: id)
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This ambassador isn't available from the app yet."
        }
    }

    private func start() async {
        starting = true
        defer { starting = false }
        do {
            let conversation = try await client.startConversation(ambassadorID: id)
            openWelcome(.conversation(conversation))
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The conversation could not be opened."
        }
    }
}

struct MessagesView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @State private var threads: [ChatThread] = []
    @State private var message: String?
    @State private var loading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Messages")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Chat with ambassadors and students")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                if loading { ProgressView() }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                if !loading && threads.isEmpty && message == nil {
                    Text("No conversations yet.").font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                ForEach(threads) { thread in
                    NavigationLink(value: WelcomeRoute.conversation(thread.id)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(thread.name).font(.headline).foregroundStyle(Color.stoneInk)
                            if let preview = thread.preview, !preview.isEmpty {
                                Text(preview).font(.subheadline).foregroundStyle(Color.stoneMuted).lineLimit(2)
                            }
                            if thread.unread > 0 {
                                Text("\(thread.unread) unread").font(.caption.weight(.semibold)).foregroundStyle(Color.welcomeRed)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.card)
                        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            threads = try await client.conversations()
            message = nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "Messages aren't available from the app yet."
        }
    }
}

struct ConversationView: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @State private var lines: [ChatLine] = []
    @State private var draft = ""
    @State private var message: String?
    @State private var sending = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                ForEach(lines) { line in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(line.mine ? "You" : line.senderName)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(line.mine ? Color.welcomeRed : Color.stoneInk)
                        Text(line.body).font(.body).foregroundStyle(Color.stoneInk)
                        if !line.time.isEmpty {
                            Text(line.time).font(.caption2).foregroundStyle(Color.stoneMuted)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.card)
                    .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
                }
                TextField("Message", text: $draft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                Button(sending ? "Sending…" : "Send") { Task { await send() } }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.welcomeRed)
                    .disabled(sending || draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Conversation")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        do {
            lines = try await client.conversationMessages(id: id)
            message = nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This conversation isn't available from the app yet."
        }
    }

    private func send() async {
        let body = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else { return }
        sending = true
        defer { sending = false }
        do {
            let line = try await client.sendChat(id: id, body: body)
            lines.append(line)
            draft = ""
            message = nil
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The message could not be sent."
        }
    }
}
