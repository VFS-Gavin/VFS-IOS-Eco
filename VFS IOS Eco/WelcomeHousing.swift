import SwiftUI
import PhotosUI

struct HousingHubView: View {
    @Bindable var session: AppSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Find your home in Vancouver")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Connect with the VFS community. Find safe, student-friendly housing or meet your future roommates.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                NavigationLink {
                    HousingListingsView(session: session)
                } label: {
                    hubRow("Browse Listings", "Explore apartments, rooms, and shared houses available now.")
                }
                .buttonStyle(.plain)
                NavigationLink {
                    HousingStudentsView(session: session)
                } label: {
                    hubRow("Find Roommates", "Connect with students who are looking for a place to share.")
                }
                .buttonStyle(.plain)
                Text("Have a space to share?")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.stoneInk)
                    .padding(.top, 8)
                Text("Help a fellow student find their home away from home. List your property or spare room on the VFS Housing Portal today.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                NavigationLink {
                    LandlordListingView(session: session)
                } label: {
                    hubRow("List Your Property", "Post a room or a full unit for VFS students.")
                }
                .buttonStyle(.plain)
                NavigationLink {
                    HousingSeekingView(session: session)
                } label: {
                    hubRow("Student Profile", "Tell other students what kind of place you are looking for.")
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Housing")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func hubRow(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline).foregroundStyle(Color.stoneInk)
            Text(detail).font(.subheadline).foregroundStyle(Color.stoneMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct HousingListingsView: View {
    @Bindable var session: AppSession
    @State private var listings: [HousingListing] = []
    @State private var message: String?
    @State private var loading = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if loading { ProgressView() }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                ForEach(listings) { listing in
                    NavigationLink {
                        HousingListingDetailView(session: session, id: listing.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(listing.name).font(.headline).foregroundStyle(Color.stoneInk)
                            Text(listing.address).font(.caption).foregroundStyle(Color.stoneMuted)
                            Text(listing.rentLabel).font(.subheadline.weight(.semibold)).foregroundStyle(Color.welcomeRed)
                            Text(listing.bedsLabel).font(.caption).foregroundStyle(Color.stoneMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Browse Listings")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            listings = try await APIClient().housingProperties()
            if listings.isEmpty { message = "No listings yet." }
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "Housing listings aren't available from the app yet."
        }
    }
}

struct HousingListingDetailView: View {
    @Bindable var session: AppSession
    var id: Int
    @State private var listing: HousingListing?
    @State private var message: String?
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var saving = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let message, listing == nil {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                if let listing {
                    Text(listing.name).font(.system(size: 32, weight: .bold, design: .serif)).foregroundStyle(Color.stoneInk)
                    Text(listing.rentLabel).font(.title3.weight(.semibold)).foregroundStyle(Color.welcomeRed)
                    Text(listing.address).font(.subheadline).foregroundStyle(Color.stoneMuted)
                    Text(listing.bedsLabel).font(.subheadline).foregroundStyle(Color.stoneInk)
                    if let detail = listing.detail, !detail.isEmpty {
                        Text(detail).font(.body).foregroundStyle(Color.stoneInk)
                    }
                    Text("Register your interest")
                        .font(.headline)
                        .padding(.top, 8)
                    field("First name", text: $firstName)
                    field("Last name", text: $lastName)
                    field("Email", text: $email)
                    field("Phone", text: $phone)
                    if let message {
                        Text(message).font(.subheadline).foregroundStyle(Color.welcomeRed)
                    }
                    Button(saving ? "Sending…" : "Register") { Task { await register() } }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.welcomeRed)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .disabled(saving)
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Listing")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func field(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption.weight(.semibold)).foregroundStyle(Color.stoneMuted)
            TextField(label, text: text).textFieldStyle(.roundedBorder)
        }
    }

    private func load() async {
        do {
            listing = try await APIClient().housingProperty(id: id)
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "This listing isn't available from the app yet."
        }
    }

    private func register() async {
        saving = true
        defer { saving = false }
        var body: [String: Any] = [
            "first_name": firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            "last_name": lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
        ]
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedPhone.isEmpty { body["phone"] = trimmedPhone }
        do {
            message = try await APIClient().registerForHousing(propertyID: id, body: body)
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "Registration could not be sent."
        }
    }
}

struct HousingStudentsView: View {
    @Bindable var session: AppSession
    @State private var students: [HousingSeeker] = []
    @State private var message: String?
    @State private var loading = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if loading { ProgressView() }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                ForEach(students) { student in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(student.name).font(.headline).foregroundStyle(Color.stoneInk)
                        Text(student.summary).font(.subheadline).foregroundStyle(Color.stoneMuted)
                        if let about = student.about, !about.isEmpty {
                            Text(about).font(.caption).foregroundStyle(Color.stoneInk).lineLimit(3)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Find Roommates")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        loading = true
        defer { loading = false }
        do {
            students = try await APIClient().housingStudents()
            if students.isEmpty { message = "No roommate profiles yet." }
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "Roommate profiles aren't available from the app yet."
        }
    }
}

struct HousingSeekingView: View {
    @Bindable var session: AppSession
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var status = "current_student"
    @State private var program = ""
    @State private var moveIn = ""
    @State private var budget = "$800-$1000"
    @State private var accommodation = "private_room"
    @State private var smoking = "no"
    @State private var pets = "no"
    @State private var gender = "any"
    @State private var about = ""
    @State private var notes = ""
    @State private var message: String?
    @State private var saving = false

    private let budgets = ["$500-$800", "$800-$1000", "$1000-$1500", "$1500-$2000", "$2000+"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Student Profile")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Your profile is submitted for review. You will be notified once it is approved.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                field("First name", $firstName)
                field("Last name", $lastName)
                field("Email", $email)
                field("Phone", $phone)
                Picker("Status", selection: $status) {
                    Text("Current Student").tag("current_student")
                    Text("Future Student").tag("future_student")
                    Text("Alumni / Graduated").tag("alumni")
                }
                field("VFS program", $program)
                field("Preferred move-in date", $moveIn)
                Picker("Budget", selection: $budget) {
                    ForEach(budgets, id: \.self) { Text($0).tag($0) }
                }
                Picker("Accommodation", selection: $accommodation) {
                    Text("Shared Room").tag("shared_room")
                    Text("Private Room").tag("private_room")
                    Text("Full Room/House").tag("full_unit")
                }
                Picker("Smoking", selection: $smoking) {
                    Text("Yes").tag("yes")
                    Text("No").tag("no")
                    Text("No preference").tag("no_preference")
                }
                Picker("Pets", selection: $pets) {
                    Text("Yes").tag("yes")
                    Text("No").tag("no")
                    Text("No preference").tag("no_preference")
                }
                Picker("Roommate gender", selection: $gender) {
                    Text("No Preference").tag("any")
                    Text("Male Only").tag("male")
                    Text("Female Only").tag("female")
                    Text("Mixed Gender").tag("mixed")
                }
                field("About you", $about)
                field("Additional notes", $notes)
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.welcomeRed)
                }
                Button(saving ? "Sending…" : "Submit profile") { Task { await save() } }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.welcomeRed)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(saving)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Student Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func field(_ label: String, _ text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption.weight(.semibold)).foregroundStyle(Color.stoneMuted)
            TextField(label, text: text, axis: .vertical).textFieldStyle(.roundedBorder)
        }
    }

    private func save() async {
        saving = true
        message = nil
        defer { saving = false }
        var body: [String: Any] = [
            "first_name": firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            "last_name": lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines),
            "status": status,
            "budget_range": budget,
            "accommodation_type": accommodation,
            "smoking_preference": smoking,
            "pets_preference": pets,
            "gender_preference": gender,
        ]
        let extras: [(String, String)] = [
            ("phone", phone), ("vfs_program", program), ("preferred_move_in_date", moveIn),
            ("about_me", about), ("additional_notes", notes),
        ]
        for (key, value) in extras {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { body[key] = trimmed }
        }
        do {
            message = try await APIClient().submitHousingSeeking(body)
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The profile could not be submitted."
        }
    }
}

struct LandlordListingView: View {
    @Bindable var session: AppSession
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var status = "current_student"
    @State private var leaseStart = ""
    @State private var rent = ""
    @State private var rentalType = "single_room"
    @State private var bedrooms = "1"
    @State private var furnished = "yes"
    @State private var streetNumber = ""
    @State private var streetName = ""
    @State private var city = "Vancouver"
    @State private var postalCode = ""
    @State private var smoking = "no"
    @State private var pets = "no"
    @State private var shared = "yes"
    @State private var description = ""
    @State private var photos: [PhotosPickerItem] = []
    @State private var photoData: [Data] = []
    @State private var message: String?
    @State private var saving = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("List Your Property")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                field("First name", $firstName)
                field("Last name", $lastName)
                field("Email", $email)
                field("Phone", $phone)
                Picker("I am", selection: $status) {
                    Text("Current Student").tag("current_student")
                    Text("Future Student").tag("future_student")
                    Text("Alumni").tag("alumni")
                    Text("Not a student").tag("not_student")
                }
                field("Lease start", $leaseStart)
                field("Rent per month", $rent)
                Picker("Rental type", selection: $rentalType) {
                    Text("Full unit").tag("full_unit")
                    Text("Single room").tag("single_room")
                }
                Picker("Bedrooms", selection: $bedrooms) {
                    Text("Studio").tag("studio")
                    Text("1").tag("1")
                    Text("2").tag("2")
                    Text("3").tag("3")
                    Text("4").tag("4")
                    Text("5+").tag("5+")
                }
                Picker("Furnished", selection: $furnished) {
                    Text("Yes").tag("yes")
                    Text("No").tag("no")
                }
                field("Street number", $streetNumber)
                field("Street name", $streetName)
                field("City", $city)
                field("Postal code", $postalCode)
                Picker("Smoking allowed", selection: $smoking) {
                    Text("Yes").tag("yes")
                    Text("No").tag("no")
                }
                Picker("Pets allowed", selection: $pets) {
                    Text("Yes").tag("yes")
                    Text("No").tag("no")
                }
                Picker("Shared accommodation", selection: $shared) {
                    Text("Yes").tag("yes")
                    Text("No").tag("no")
                }
                field("Description", $description)
                PhotosPicker(selection: $photos, maxSelectionCount: 8, matching: .images) {
                    Text(photoData.isEmpty ? "Add photos" : "\(photoData.count) photos")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.welcomeRed)
                }
                .onChange(of: photos) { _, items in
                    Task {
                        var files: [Data] = []
                        for item in items {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let image = UIImage(data: data),
                               let jpeg = image.jpegData(compressionQuality: 0.85) {
                                files.append(jpeg)
                            }
                        }
                        photoData = files
                    }
                }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.welcomeRed)
                }
                Button(saving ? "Sending…" : "Submit listing") { Task { await save() } }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.welcomeRed)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(saving)
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("List Your Property")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func field(_ label: String, _ text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption.weight(.semibold)).foregroundStyle(Color.stoneMuted)
            TextField(label, text: text, axis: .vertical).textFieldStyle(.roundedBorder)
        }
    }

    private func save() async {
        saving = true
        message = nil
        defer { saving = false }
        let fields = [
            "first_name": firstName, "last_name": lastName, "contact_email": email, "contact_phone": phone,
            "landlord_status": status, "lease_start": leaseStart, "rent_amount": rent, "rental_type": rentalType,
            "bedrooms": bedrooms, "furnished": furnished, "street_number": streetNumber, "street_name": streetName,
            "city": city, "postal_code": postalCode, "smoking_allowed": smoking, "pets_allowed": pets,
            "shared_accommodation": shared, "property_description": description,
        ].mapValues { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        do {
            message = try await APIClient().submitLandlordListing(fields, photos: photoData)
        } catch APIError.unauthorized {
            session.signOut()
        } catch APIError.message(let text) {
            message = text
        } catch {
            message = "The listing could not be submitted."
        }
    }
}

nonisolated struct HousingPropertiesPage: Decodable {
    var listings: [HousingListing]

    init(from decoder: Decoder) throws {
        listings = HousingPageReader.listings(from: decoder, keys: ["properties", "data"])
    }
}

nonisolated struct HousingPropertyPage: Decodable {
    var listing: HousingListing

    init(from decoder: Decoder) throws {
        let rows = HousingPageReader.listings(from: decoder, keys: ["property", "data"])
        if let first = rows.first {
            listing = first
        } else {
            listing = try HousingListing(from: decoder)
        }
    }
}

nonisolated struct HousingStudentsPage: Decodable {
    var students: [HousingSeeker]

    init(from decoder: Decoder) throws {
        students = HousingPageReader.students(from: decoder, keys: ["students", "data"])
    }
}

private enum HousingPageReader {
    static func listings(from decoder: Decoder, keys: [String]) -> [HousingListing] {
        guard let object = try? decoder.container(keyedBy: JSONKey.self) else { return [] }
        for key in keys {
            if let page = try? object.decode(Page<HousingListing>.self, forKey: JSONKey(key)), !page.data.isEmpty {
                return page.data
            }
            if let row = try? object.decode(HousingListing.self, forKey: JSONKey(key)) {
                return [row]
            }
            if let rows = try? object.decode([HousingListing].self, forKey: JSONKey(key)) {
                return rows
            }
        }
        return (try? object.decode(Page<HousingListing>.self, forKey: JSONKey("data")))?.data ?? []
    }

    static func students(from decoder: Decoder, keys: [String]) -> [HousingSeeker] {
        guard let object = try? decoder.container(keyedBy: JSONKey.self) else { return [] }
        for key in keys {
            if let page = try? object.decode(Page<HousingSeeker>.self, forKey: JSONKey(key)) {
                return page.data
            }
            if let rows = try? object.decode([HousingSeeker].self, forKey: JSONKey(key)) {
                return rows
            }
        }
        return []
    }

    private struct Page<Item: Decodable>: Decodable {
        var data: [Item]
    }

    private struct JSONKey: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        init(_ value: String) { stringValue = value }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }
}

nonisolated struct HousingListing: Decodable, Identifiable {
    var id: Int
    var name: String
    var address: String
    var rent: String
    var bedrooms: String
    var detail: String?
    var photo: String?

    var rentLabel: String { rent.isEmpty ? "" : "$\(rent)/mo" }
    var bedsLabel: String { bedrooms == "studio" ? "Studio" : "\(bedrooms) Beds" }

    enum CodingKeys: String, CodingKey {
        case id
        case name = "property_name"
        case address
        case rent = "rent_amount"
        case bedrooms
        case detail = "property_description"
        case photo = "primary_photo_url"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Listing"
        address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        if let number = try? container.decode(Double.self, forKey: .rent) {
            rent = number.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(number)) : String(number)
        } else {
            rent = (try? container.decode(String.self, forKey: .rent)) ?? ""
        }
        if let text = try? container.decode(String.self, forKey: .bedrooms) {
            bedrooms = text
        } else if let number = try? container.decode(Int.self, forKey: .bedrooms) {
            bedrooms = String(number)
        } else {
            bedrooms = ""
        }
        detail = try container.decodeIfPresent(String.self, forKey: .detail)
        photo = try container.decodeIfPresent(String.self, forKey: .photo)
    }
}

nonisolated struct HousingSeeker: Decodable, Identifiable {
    var id: Int
    var name: String
    var summary: String
    var about: String?

    enum CodingKeys: String, CodingKey {
        case id
        case first = "first_name"
        case last = "last_name"
        case budget = "budget_range"
        case accommodation = "accommodation_type"
        case about = "about_me"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        let first = try container.decodeIfPresent(String.self, forKey: .first) ?? ""
        let last = try container.decodeIfPresent(String.self, forKey: .last) ?? ""
        name = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        let budget = try container.decodeIfPresent(String.self, forKey: .budget) ?? ""
        let room = try container.decodeIfPresent(String.self, forKey: .accommodation) ?? ""
        summary = [budget, room.replacingOccurrences(of: "_", with: " ")].filter { !$0.isEmpty }.joined(separator: " · ")
        about = try container.decodeIfPresent(String.self, forKey: .about)
    }
}
