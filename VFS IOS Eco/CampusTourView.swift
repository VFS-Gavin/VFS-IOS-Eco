import SwiftUI

struct CampusLocation: Identifiable, Equatable {
    var id: Int
    var name: String
    var address: String
    var city: String
    var mapLink: String
    var programs: [String]
}

enum CampusCatalog {
    static let mapPath = "/documents/campus_map.pdf"
    static let mapNote = "Shows all five VFS locations in downtown Vancouver with street names and landmarks"

    static let campuses: [CampusLocation] = [
        CampusLocation(
            id: 1,
            name: "198 West Hastings",
            address: "198 West Hastings St.",
            city: "Vancouver, BC",
            mapLink: "https://maps.app.goo.gl/c57Q5kETbgk1Uguv6",
            programs: [
                "Acting Essentials",
                "Acting for Film & TV",
                "Game Design",
                "Writing for Film, TV & Games",
            ]
        ),
        CampusLocation(
            id: 2,
            name: "400 West Hastings",
            address: "400 West Hastings St.",
            city: "Vancouver, BC",
            mapLink: "https://maps.app.goo.gl/nEseuMrEydD4Yu5SA",
            programs: [
                "Digital Design",
                "Foundation Visual Art & Design",
                "Sound Design",
            ]
        ),
        CampusLocation(
            id: 3,
            name: "VFS Production Centre",
            address: "151 W. Cordova St. & 142 Water St.",
            city: "Vancouver, BC",
            mapLink: "https://maps.app.goo.gl/oMGSM9Ejy4JGNsyU6",
            programs: [
                "3D Animation & VFX",
                "Animation Concept Art",
                "Acting for Film & TV",
                "Classical Animation",
                "Film Production",
                "Game Design",
                "Makeup Design",
                "Sound Design",
            ]
        ),
        CampusLocation(
            id: 4,
            name: "Makeup Design Campus",
            address: "1248 Franklin St.",
            city: "Vancouver, BC",
            mapLink: "https://maps.app.goo.gl/hbRzUsM1WV78fU3W9",
            programs: ["Makeup Design for Film & TV"]
        ),
    ]
}

struct CampusTourView: View {
    @Environment(\.openURL) private var openURL
    @State private var selectedID = 1
    @State private var showAllPrograms = false

    private var selected: CampusLocation {
        CampusCatalog.campuses.first { $0.id == selectedID } ?? CampusCatalog.campuses[0]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHero(
                    lead: "Explore",
                    accent: "Our World",
                    accentColor: .welcomeRed,
                    detail: "Discover the world-class facilities where VFS students create their future in the heart of downtown Vancouver."
                )

                Text("Locations")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(Color.stoneInk)
                Text("Select a campus to explore")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)

                ForEach(CampusCatalog.campuses) { campus in
                    Button {
                        selectedID = campus.id
                        showAllPrograms = false
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(campus.id)")
                                .font(.headline)
                                .frame(width: 36, height: 36)
                                .background(selectedID == campus.id ? Color.white : Color.stone)
                                .foregroundStyle(selectedID == campus.id ? Color.welcomeRed : Color.stoneInk)
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(campus.name)
                                    .font(.headline)
                                Text(campus.address)
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(selectedID == campus.id ? Color.welcomeRed : Color.card)
                        .foregroundStyle(selectedID == campus.id ? Color.white : Color.stoneInk)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("campus-\(campus.id)")
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("\(selected.address), \(selected.city)")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    programChips
                    if let url = URL(string: selected.mapLink) {
                        Button("Get Directions") { openURL(url) }
                            .buttonStyle(CrimsonButtonStyle())
                    }
                }
                .guideCard()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Need a Printable Map?")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(Color.stoneInk)
                    Text("Download our detailed campus map for easy navigation")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    Text(CampusCatalog.mapNote)
                        .font(.caption)
                        .foregroundStyle(Color.stoneMuted)
                    if let url = WelcomeFormCatalog.downloadURL(path: CampusCatalog.mapPath, base: APIConfiguration.baseURL) {
                        Button("Download Map") { openURL(url) }
                            .tint(Color.welcomeRed)
                    }
                }
                .guideCard()

                VStack(alignment: .leading, spacing: 8) {
                    Text("See It For Yourself")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(Color.stoneInk)
                    Text("Want a private tour of campus? Reach out to your coordinator and they'll help set one up for you.")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    NavigationLink(value: WelcomeRoute.coordinator) {
                        Text("Contact Your Coordinator")
                            .font(.subheadline.weight(.semibold))
                    }
                    .tint(Color.welcomeRed)
                }
                .guideCard()
            }
            .padding(20)
        }
        .deskPage()
        .navigationTitle("Campus Tour")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var programChips: some View {
        let programs = selected.programs
        let visible = showAllPrograms || programs.count <= 3 ? programs : Array(programs.prefix(3))
        return VStack(alignment: .leading, spacing: 8) {
            ForEach(visible, id: \.self) { program in
                Text(program)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.card)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            if programs.count > 3 {
                Button(showAllPrograms ? "Show less" : "+\(programs.count - 3) more") {
                    showAllPrograms.toggle()
                }
                .font(.caption.weight(.semibold))
                .tint(Color.welcomeRed)
            }
        }
    }
}
