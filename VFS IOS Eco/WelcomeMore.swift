import SwiftUI

struct SocialMediaView: View {
    @Environment(\.openURL) private var openURL

    private let platforms: [(name: String, handle: String, detail: String, url: String)] = [
        ("Instagram", "@vancouverfilmschool", "Follow our daily updates, student work, and behind-the-scenes content.", "https://www.instagram.com/vancouverfilmschool/"),
        ("YouTube", "vancouverfilmschool", "Watch student films, tutorials, and campus tours.", "https://www.youtube.com/vancouverfilmschool"),
        ("Facebook", "vancouverfilmschool", "Join our community for events, news, and alumni stories.", "https://www.facebook.com/vancouverfilmschool"),
        ("TikTok", "@vancouverfilmschool", "Short-form content showcasing student life and creativity.", "https://www.tiktok.com/@vancouverfilmschool"),
        ("LinkedIn", "Vancouver Film School", "Connect with alumni, staff, and industry professionals.", "https://www.linkedin.com/edu/school?id=20077"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Connect with VFS")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Follow us on social media to stay updated with the latest news, student work, events, and behind-the-scenes content from Vancouver Film School.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                ForEach(platforms, id: \.name) { platform in
                    Button {
                        if let url = URL(string: platform.url) { openURL(url) }
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(platform.name)
                                .font(.headline)
                                .foregroundStyle(Color.stoneInk)
                            Text(platform.handle)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.welcomeRed)
                            Text(platform.detail)
                                .font(.subheadline)
                                .foregroundStyle(Color.stoneMuted)
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
        .navigationTitle("Social Media")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ConnectView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Connect with Industry")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Questions about your program, tuition, or student life? Our dedicated team is ready to assist you.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                contact("Admissions", "Application status, enrollment requirements, and general program inquiries.", "admissions@vfs.edu")
                contact("Student Services", "Housing support, study insurance, study permits, and student wellbeing.", "studentservices@vfs.edu")
                contact("Financial Aid", "Tuition payments, student loans, scholarships, and payment plans.", "financialaid@vfs.edu")
                Text("Learn from the Industry Pros")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.stoneInk)
                    .padding(.top, 8)
                Text("Our instructors aren't just teachers; they are working professionals. They bring current industry standards, workflows, and connections directly into the classroom.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                Text("Join the Conversation")
                    .font(.headline)
                    .foregroundStyle(Color.stoneInk)
                Button("Instagram") { open("https://instagram.com/vancouverfilmschool") }
                Button("Twitter") { open("https://twitter.com/vfs") }
                Button("Facebook") { open("https://facebook.com/vancouverfilmschool") }
                Button("YouTube") { open("https://youtube.com/vancouverfilmschool") }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Connect")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func contact(_ title: String, _ detail: String, _ email: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline).foregroundStyle(Color.stoneInk)
            Text(detail).font(.subheadline).foregroundStyle(Color.stoneMuted)
            Button(email) { open("mailto:\(email)") }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.welcomeRed)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func open(_ raw: String) {
        if let url = URL(string: raw) { openURL(url) }
    }
}

struct DocumentsView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Download Documents")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Please download and review the documents below. Signed forms can be submitted through the forms on Welcome Hub or emailed to your coordinator.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                document("Student Handbook", "Complete guide covering campus locations, policies, academic requirements, student services, safety procedures, and all essential information for your time at VFS.", path: "/documents/student_handbook.pdf", sections: ["Campus Information & Maps", "Academic Policies", "Student Services", "Safety & Security", "General Policies"])
                document("Campus Map", "Detailed map showing all VFS campus locations in downtown Vancouver including 198 West Hastings, 400 West Hastings, 151 West Cordova, 142 Water, and 1248 Franklin.", path: "/documents/campus_map.pdf", sections: [])
                document("Code of Conduct", "Professional standards, respectful treatment policy, academic honesty guidelines, and expectations for student behavior throughout your program.", path: nil, sections: [])
                document("Equipment & Resources", "Guidelines for borrowing equipment, using Resource Centres, VIPER card system, loan periods, reservations, and maintaining school property.", path: nil, sections: [])
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Documents")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func document(_ title: String, _ detail: String, path: String?, sections: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).foregroundStyle(Color.stoneInk)
            Text(detail).font(.subheadline).foregroundStyle(Color.stoneMuted)
            ForEach(sections, id: \.self) { section in
                Text(section).font(.caption).foregroundStyle(Color.stoneInk)
            }
            if let path {
                Button("Download") {
                    openURL(APIConfiguration.baseURL.appending(path: String(path.dropFirst())))
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.welcomeRed)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
