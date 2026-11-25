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
                NavigationLink(value: WelcomeRoute.housingListings) {
                    hubRow("Browse Listings", "Explore apartments, rooms, and shared houses available now.")
                }
                .buttonStyle(.plain)
                NavigationLink(value: WelcomeRoute.housingStudents) {
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
                NavigationLink(value: WelcomeRoute.housingLandlord) {
                    hubRow("List Your Property", "Post a room or a full unit for VFS students.")
                }
                .buttonStyle(.plain)
                NavigationLink(value: WelcomeRoute.housingSeeking) {
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
    @State private var bedrooms = ""
    @State private var furnished = ""
    @State private var pets = ""
    @State private var maxRent = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Bedrooms", selection: $bedrooms) {
                    Text("Any beds").tag("")
                    Text("Studio").tag("studio")
                    Text("1").tag("1")
                    Text("2").tag("2")
                    Text("3").tag("3")
                    Text("4").tag("4")
                }
                Picker("Furnished", selection: $furnished) {
                    Text("Furnished or not").tag("")
                    Text("Furnished").tag("yes")
                    Text("Unfurnished").tag("no")
                }
                Picker("Pets", selection: $pets) {
                    Text("Pets").tag("")
                    Text("Pets allowed").tag("yes")
                    Text("No pets").tag("no")
                }
                TextField("Max rent", text: $maxRent)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                Button("Apply filters") { Task { await load() } }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.welcomeRed)
                if loading { ProgressView() }
                if let message {
                    Text(message).font(.subheadline).foregroundStyle(Color.stoneMuted)
                }
                ForEach(listings) { listing in
                    NavigationLink(value: WelcomeRoute.housingProperty(listing.id)) {
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
            listings = try await APIClient().housingProperties(bedrooms: bedrooms, furnished: furnished, pets: pets, maxRent: maxRent.trimmingCharacters(in: .whitespacesAndNewlines))
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
                    if let furnished = listing.furnished, !furnished.isEmpty {
                        Text(furnished == "yes" ? "Furnished" : "Unfurnished").font(.subheadline).foregroundStyle(Color.stoneInk)
                    }
                    if let pets = listing.pets, !pets.isEmpty {
                        Text(pets == "yes" ? "Pets allowed" : "No pets").font(.subheadline).foregroundStyle(Color.stoneInk)
                    }
                    if let smoking = listing.smoking, !smoking.isEmpty {
                        Text(smoking == "yes" ? "Smoking allowed" : "No smoking").font(.subheadline).foregroundStyle(Color.stoneInk)
                    }
                    if let laundry = listing.laundry, !laundry.isEmpty {
                        Text("Laundry: \(laundry.replacingOccurrences(of: "_", with: " "))").font(.subheadline).foregroundStyle(Color.stoneMuted)
                    }
                    if let parking = listing.parking, !parking.isEmpty {
                        Text("Parking: \(parking.replacingOccurrences(of: "_", with: " "))").font(.subheadline).foregroundStyle(Color.stoneMuted)
                    }
                    ForEach(listing.photoURLs, id: \.self) { raw in
                        if let url = AccountMedia.url(raw) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                Color.stoneLine.frame(height: 160)
                            }
                            .frame(maxWidth: .infinity)
                        }
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
                    NavigationLink(value: WelcomeRoute.housingStudent(student.id)) {
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
                    .buttonStyle(.plain)
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
    @State private var places: Set<String> = []
    private let placeChoices = [
        ("near_transit", "Near Transit"),
        ("near_vfs", "Near VFS Campus"),
        ("near_downtown", "Downtown"),
        ("kitsilano", "Kitsilano"),
        ("commercial_drive", "Commercial Drive"),
        ("main_street", "Main Street"),
    ]
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
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
                Text("Areas")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.stoneMuted)
                ForEach(placeChoices, id: \.0) { key, label in
                    Button {
                        if places.contains(key) { places.remove(key) } else { places.insert(key) }
                    } label: {
                        Text(places.contains(key) ? "✓ \(label)" : label)
                            .font(.subheadline)
                            .foregroundStyle(places.contains(key) ? Color.welcomeRed : Color.stoneInk)
                    }
                    .buttonStyle(.plain)
                }
                Picker("Roommate gender", selection: $gender) {
                    Text("No Preference").tag("any")
                    Text("Male Only").tag("male")
                    Text("Female Only").tag("female")
                    Text("Mixed Gender").tag("mixed")
                }
                field("About you", $about)
                field("Additional notes", $notes)
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Text(photoData == nil ? "Add a profile photo" : "Replace profile photo")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.welcomeRed)
                }
                .onChange(of: photoItem) { _, item in
                    Task {
                        guard let data = try? await item?.loadTransferable(type: Data.self),
                              let image = UIImage(data: data) else { return }
                        photoData = image.jpegData(compressionQuality: 0.85)
                    }
                }
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
        if !places.isEmpty { body["location_preference"] = Array(places).sorted() }
        do {
            message = try await APIClient().submitHousingSeeking(body, photo: photoData)
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
    @State private var program = ""
    @State private var size = ""
    @State private var laundry = ""
    @State private var parking = ""
    @State private var features: Set<String> = []
    @State private var included: Set<String> = []
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
                field("VFS program", $program)
                field("Size in square feet", $size)
                Picker("Laundry", selection: $laundry) {
                    Text("Laundry").tag("")
                    Text("In unit").tag("in_unit")
                    Text("In building").tag("in_building")
                    Text("Nearby").tag("nearby")
                    Text("None").tag("none")
                }
                Picker("Parking", selection: $parking) {
                    Text("Parking").tag("")
                    Text("Included").tag("included")
                    Text("Available").tag("available")
                    Text("Street").tag("street")
                    Text("None").tag("none")
                }
                field("Description", $description)
                Text("Location").font(.caption.weight(.semibold)).foregroundStyle(Color.stoneMuted)
                ForEach(Self.locationChoices, id: \.0) { key, label in
                    toggleLine(label, on: features.contains(key)) {
                        if features.contains(key) { features.remove(key) } else { features.insert(key) }
                    }
                }
                Text("Included").font(.caption.weight(.semibold)).foregroundStyle(Color.stoneMuted)
                ForEach(Self.includeChoices, id: \.0) { key, label in
                    toggleLine(label, on: included.contains(key)) {
                        if included.contains(key) { included.remove(key) } else { included.insert(key) }
                    }
                }
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

    private static let locationChoices = [
        ("near_transit", "Near Transit"),
        ("near_vfs", "Near VFS Campus"),
        ("near_downtown", "Near Downtown"),
        ("near_grocery", "Near Grocery Stores"),
        ("quiet_area", "Quiet Area"),
    ]
    private static let includeChoices = [
        ("electricity", "Electricity"),
        ("heating", "Heating"),
        ("internet", "Internet"),
        ("cable", "Cable TV"),
        ("water", "Water"),
    ]

    private func toggleLine(_ label: String, on: Bool, flip: @escaping () -> Void) -> some View {
        Button(action: flip) {
            Text(on ? "✓ \(label)" : label)
                .font(.subheadline)
                .foregroundStyle(on ? Color.welcomeRed : Color.stoneInk)
        }
        .buttonStyle(.plain)
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
            "vfs_program": program, "size_sqft": size, "laundry": laundry, "parking": parking,
        ].mapValues { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.value.isEmpty }
        var lists: [String: [String]] = [:]
        if !features.isEmpty { lists["location_features"] = features.sorted() }
        if !included.isEmpty { lists["includes"] = included.sorted() }
        do {
            message = try await APIClient().submitLandlordListing(fields, photos: photoData, lists: lists)
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
    var furnished: String?
    var pets: String?
    var smoking: String?
    var laundry: String?
    var parking: String?
    var photoURLs: [String]

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
        case furnished, laundry, parking, photos
        case pets = "pets_allowed"
        case smoking = "smoking_allowed"
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
        furnished = try container.decodeIfPresent(String.self, forKey: .furnished)
        pets = try container.decodeIfPresent(String.self, forKey: .pets)
        smoking = try container.decodeIfPresent(String.self, forKey: .smoking)
        laundry = try container.decodeIfPresent(String.self, forKey: .laundry)
        parking = try container.decodeIfPresent(String.self, forKey: .parking)
        let shots = (try? container.decode([HousingPhoto].self, forKey: .photos)) ?? []
        photoURLs = shots.compactMap(\.url)
        if photoURLs.isEmpty, let photo, !photo.isEmpty { photoURLs = [photo] }
    }
}

private struct HousingPhoto: Decodable {
    var url: String?
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
