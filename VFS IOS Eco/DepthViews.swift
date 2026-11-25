import SwiftUI

nonisolated struct RoommatePage: Decodable {
    var student: RoommateProfile

    enum CodingKeys: String, CodingKey { case student }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let student = try? container.decode(RoommateProfile.self, forKey: .student) {
            self.student = student
            return
        }
        student = try RoommateProfile(from: decoder)
    }
}

nonisolated struct RoommateProfile: Decodable {
    var id: Int
    var name: String
    var status: String?
    var program: String?
    var moveIn: String?
    var budget: String?
    var room: String?
    var places: String?
    var smoking: String?
    var pets: String?
    var gender: String?
    var about: String?
    var notes: String?
    var photo: String?

    enum CodingKeys: String, CodingKey {
        case id
        case first = "first_name"
        case last = "last_name"
        case full = "full_name"
        case status
        case statusLabel = "status_label"
        case program = "vfs_program"
        case moveIn = "preferred_move_in_date"
        case budget = "budget_range"
        case room = "accommodation_type"
        case roomLabel = "accommodation_type_label"
        case places = "location_preference"
        case smoking = "smoking_preference"
        case pets = "pets_preference"
        case gender = "gender_preference"
        case about = "about_me"
        case notes = "additional_notes"
        case photo = "profile_photo_url"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        if let full = try container.decodeIfPresent(String.self, forKey: .full), !full.isEmpty {
            name = full
        } else {
            let first = try container.decodeIfPresent(String.self, forKey: .first) ?? ""
            let last = try container.decodeIfPresent(String.self, forKey: .last) ?? ""
            name = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        }
        status = try container.decodeIfPresent(String.self, forKey: .statusLabel)
            ?? container.decodeIfPresent(String.self, forKey: .status)
        program = try container.decodeIfPresent(String.self, forKey: .program)
        moveIn = Self.text(container, .moveIn)
        budget = try container.decodeIfPresent(String.self, forKey: .budget)
        room = try container.decodeIfPresent(String.self, forKey: .roomLabel)
            ?? container.decodeIfPresent(String.self, forKey: .room)
        if let list = try? container.decode([String].self, forKey: .places) {
            places = list.joined(separator: ", ")
        } else {
            places = try container.decodeIfPresent(String.self, forKey: .places)
        }
        smoking = try container.decodeIfPresent(String.self, forKey: .smoking)
        pets = try container.decodeIfPresent(String.self, forKey: .pets)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        about = try container.decodeIfPresent(String.self, forKey: .about)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        photo = try container.decodeIfPresent(String.self, forKey: .photo)
    }

    private static func text(_ container: KeyedDecodingContainer<CodingKeys>, _ key: CodingKeys) -> String? {
        if let value = try? container.decode(String.self, forKey: key), !value.isEmpty { return value }
        return nil
    }
}

struct RoommateDetailView: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @State private var student: RoommateProfile?
    @State private var message: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let student {
                    if let photo = student.photo, let url = AccountMedia.url(photo) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.stoneLine
                        }
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                    }
                    Text(student.name.isEmpty ? "Roommate" : student.name)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    line("Status", student.status)
                    line("Program", student.program)
                    line("Move-in", student.moveIn)
                    line("Budget", student.budget)
                    line("Looking for", student.room?.replacingOccurrences(of: "_", with: " "))
                    line("Areas", student.places)
                    line("Smoking", student.smoking?.replacingOccurrences(of: "_", with: " "))
                    line("Pets", student.pets?.replacingOccurrences(of: "_", with: " "))
                    line("Gender preference", student.gender?.replacingOccurrences(of: "_", with: " "))
                    if let about = student.about, !about.isEmpty {
                        Text(about).font(.body).foregroundStyle(Color.stoneInk)
                    }
                    if let notes = student.notes, !notes.isEmpty {
                        Text(notes).font(.subheadline).foregroundStyle(Color.stoneMuted)
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
        .navigationTitle("Roommate")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    @ViewBuilder
    private func line(_ label: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption.weight(.semibold)).foregroundStyle(Color.stoneMuted)
                Text(value).font(.subheadline).foregroundStyle(Color.stoneInk)
            }
        }
    }

    private func load() async {
        do {
            student = try await client.housingStudent(id: id)
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This roommate profile isn't available from the app yet."
        }
    }
}

struct ProductionDetailView: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL
    @State private var production: ProductionCard?
    @State private var message: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let production {
                    Text(production.title)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    line("Region", production.region)
                    line("Category", production.category)
                    line("Company", production.productionCompany)
                    line("Producer", production.producer)
                    line("Director", production.director)
                    line("Schedule", production.schedule)
                    line("Starts", production.startDate)
                    line("Ends", production.endDate)
                    line("Address", production.productionAddress)
                    line("Production manager", production.productionManager)
                    line("Coordinator", production.productionCoordinator)
                    line("Location manager", production.locationManager)
                    line("Background casting", production.bgCasting)
                    line("Casting director", production.castingDirector)
                    line("Stunt coordinator", production.stuntCoordinator)
                    line("Email", production.email)
                    line("Phone", production.phone)
                    if let source = production.sourceURL, let url = URL(string: source) {
                        Button("Open source") { openURL(url) }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.ecoOrange)
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
        .navigationTitle("Production")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    @ViewBuilder
    private func line(_ label: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption.weight(.semibold)).foregroundStyle(Color.stoneMuted)
                Text(value).font(.subheadline).foregroundStyle(Color.stoneInk)
            }
        }
    }

    private func load() async {
        do {
            let board = try await client.jobs(search: "", page: 1, partnerPage: 1)
            production = board.productions.first { $0.id == id }
            if production == nil { message = "This production isn't on the current list." }
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This production could not be loaded."
        }
    }
}

struct CalendarEventView: View {
    @Bindable var session: AppSession
    var id: Int
    var client: APIClient = APIClient()
    @State private var event: CalendarItem?
    @State private var message: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let event {
                    if let raw = event.imageURL, let url = AccountMedia.url(raw) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Color.stoneLine.frame(height: 160)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    if let date = event.dateLabel, !date.isEmpty {
                        Text(date).font(.caption.weight(.semibold)).foregroundStyle(Color(red: 219 / 255, green: 39 / 255, blue: 119 / 255))
                    }
                    Text(event.title)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    if let when = event.when, !when.isEmpty {
                        Text(event.location.map { "\(when) · \($0)" } ?? when)
                            .font(.subheadline)
                            .foregroundStyle(Color.stoneMuted)
                    }
                    if let description = event.description, !description.isEmpty {
                        Text(description).font(.body).foregroundStyle(Color.stoneInk)
                    }
                    ForEach(event.badges ?? [], id: \.self) { badge in
                        Text(badge).font(.caption.weight(.bold)).foregroundStyle(Color.stoneMuted)
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
            let events = try await client.calendar()
            event = events.first { $0.id == id }
            if event == nil { message = "This event isn't on the calendar." }
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This event could not be loaded."
        }
    }
}
