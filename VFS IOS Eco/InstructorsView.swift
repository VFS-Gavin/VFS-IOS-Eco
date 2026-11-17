import SwiftUI

struct InstructorsView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    @Environment(\.openURL) private var openURL

    @State private var directory = InstructorDirectory.empty
    @State private var phase: LoadPhase = .loading
    @State private var program = "all"
    @State private var role = ""
    @State private var search = ""
    @State private var expanded: Set<Int> = []

    private enum LoadPhase {
        case loading
        case ready
        case failed(String)
    }

    private var visible: [Instructor] {
        directory.members(program: program, role: role, search: search)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHero(
                    lead: "Meet Your",
                    accent: "Instructors",
                    accentColor: .pagePink,
                    detail: "Learn directly from \(directory.everyone.count) award-winning professionals who are shaping the entertainment industry today."
                )

                switch phase {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    Text(message)
                        .foregroundStyle(Color.stoneInk)
                case .ready:
                    filters
                    if visible.isEmpty {
                        empty
                    } else {
                        ForEach(visible) { person in
                            card(person)
                        }
                    }
                }
            }
            .padding(20)
        }
        .deskPage(tint: .pagePink)
        .navigationTitle("Instructors")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private var filters: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Search by name, title, or program...", text: $search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityIdentifier("instructor-search")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    programButton("All Programs", slug: "all", count: directory.everyone.count)
                    ForEach(directory.programs) { item in
                        programButton(item.program, slug: item.programSlug, count: directory.faculty[item.programSlug]?.count ?? 0)
                    }
                }
            }

            if directory.roles.count > 1 {
                Picker("Role", selection: $role) {
                    Text("All Roles").tag("")
                    ForEach(directory.roles, id: \.self) { title in
                        Text(title).tag(title)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("instructor-role")
            }
        }
    }

    private func programButton(_ name: String, slug: String, count: Int) -> some View {
        Button {
            program = slug
            search = ""
            role = ""
        } label: {
            Text("\(name) \(count)")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(program == slug ? Color.welcomeRed : Color.white)
                .foregroundStyle(program == slug ? Color.white : Color.stoneInk)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("instructor-program-\(slug)")
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("No instructors found")
                .font(.headline)
            Text("Try adjusting your search or selecting a different program.")
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
        }
        .accessibilityIdentifier("instructors-empty")
    }

    private func card(_ person: Instructor) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let photo = resolved(person.photoURL) {
                AsyncImage(url: photo) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.stone
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            if program == "all", let programName = person.program {
                Text(programName)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.welcomeRed)
            }
            Text(person.name)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(Color.stoneInk)
            if let title = person.title, !title.isEmpty {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.welcomeRed)
            }
            if let bio = person.bio, !bio.isEmpty {
                Text(shownBio(bio, id: person.id))
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                if bio.count > 150 {
                    Button(expanded.contains(person.id) ? "Show less" : "Read more") {
                        if expanded.contains(person.id) {
                            expanded.remove(person.id)
                        } else {
                            expanded.insert(person.id)
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .tint(Color.welcomeRed)
                }
            }
            HStack(spacing: 8) {
                link("IMDb", person.imdbURL)
                link("LinkedIn", person.linkedinURL)
                link("Website", person.websiteURL)
            }
        }
        .guideCard()
        .accessibilityIdentifier("instructor-\(person.id)")
    }

    @ViewBuilder
    private func link(_ title: String, _ raw: String?) -> some View {
        if let url = resolved(raw) {
            Button(title) { openURL(url) }
                .buttonStyle(.bordered)
                .tint(Color.welcomeRed)
        }
    }

    private func shownBio(_ bio: String, id: Int) -> String {
        guard bio.count > 150, !expanded.contains(id) else { return bio }
        return String(bio.prefix(150)) + "..."
    }

    private func resolved(_ raw: String?) -> URL? {
        guard let raw, !raw.isEmpty else { return nil }
        if let url = URL(string: raw), url.scheme != nil {
            return url
        }
        return URL(string: raw, relativeTo: APIConfiguration.baseURL)?.absoluteURL
    }

    private func load() async {
        do {
            directory = try await client.instructors()
            phase = .ready
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            phase = .failed(error.message)
        } catch {
            phase = .failed("Instructors could not be loaded.")
        }
    }
}

private extension InstructorDirectory {
    static let empty = InstructorDirectory(faculty: [:], programs: [])
}

private extension InstructorDirectory {
    init(faculty: [String: [Instructor]], programs: [InstructorProgram]) {
        self.faculty = faculty
        self.programs = programs
    }
}

private extension APIError {
    var message: String {
        switch self {
        case .message(let message):
            return message
        case .unauthorized:
            return "Sign in again."
        }
    }
}
