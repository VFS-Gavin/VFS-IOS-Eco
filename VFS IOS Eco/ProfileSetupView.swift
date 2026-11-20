import SwiftUI

nonisolated struct ProfileDraft: Equatable {
    var displayName = ""
    var headline = ""
    var location = ""
    var program = ""
    var skills = ""
    var openToWork = false
    var openToCollab = false

    func payload() -> [String: Any] {
        var body: [String: Any] = [
            "display_name": displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            "headline": headline.trimmingCharacters(in: .whitespacesAndNewlines),
            "location": location.trimmingCharacters(in: .whitespacesAndNewlines),
            "skills": skillList,
            "open_to_work": openToWork,
            "open_to_collab": openToCollab,
            "visibility": "public",
        ]
        if !program.isEmpty {
            body["program"] = [program]
        }
        return body
    }

    var skillList: [String] {
        skills
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

enum ProfilePrograms {
    static let options: [(key: String, label: String)] = [
        ("3d_animation", "3D Animation & Visual Effects"),
        ("acting_film", "Acting for Film & Television"),
        ("animation_concept", "Animation Concept Art"),
        ("classical_animation", "Classical Animation"),
        ("digital_design", "Digital Design"),
        ("film_production", "Film Production"),
        ("game_design", "Game Design"),
        ("makeup_design", "Makeup Design for Film & Television"),
        ("programming_games", "Programming for Games, Web & Mobile"),
        ("sound_design", "Sound Design for Visual Media"),
        ("writing", "Writing for Film, Television & Games"),
        ("acting_essentials", "Acting Essentials"),
        ("acting_essentials_evening", "Acting Essentials - Evening & Weekend"),
        ("english_creative_arts", "English for Creative Arts"),
        ("foundation_film", "Foundation – Film"),
        ("foundation_animation", "Foundation – Animation"),
        ("foundation_design", "Foundation - Design"),
        ("foundation_art", "Foundation Visual Art & Design"),
    ]
}

struct ProfileSetupView: View {
    @Bindable var session: AppSession
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ProfileDraft()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CreativeHeadline(
                    lead: "Create your ",
                    accent: "Profile",
                    accentColor: .ecoOrange,
                    detail: "This is what other students and alumni see when they open your portfolio."
                )

                field("Display Name", text: $draft.displayName, prompt: "Your name")
                field("Headline", text: $draft.headline, prompt: "e.g. 3D Animator & Motion Designer")
                field("Location", text: $draft.location, prompt: "Vancouver, BC")

                VStack(alignment: .leading, spacing: 6) {
                    Text("Program")
                        .font(.subheadline.weight(.semibold))
                    Picker("Program", selection: $draft.program) {
                        Text("Choose a program").tag("")
                        ForEach(ProfilePrograms.options, id: \.key) { option in
                            Text(option.label).tag(option.key)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("profile-program")
                }

                field("Skills", text: $draft.skills, prompt: "Editing, Sound, Design")

                Toggle("Open to work", isOn: $draft.openToWork)
                    .tint(Color.ecoOrange)
                Toggle("Open to collaborate", isOn: $draft.openToCollab)
                    .tint(Color.ecoOrange)

                if let message = session.statusMessage, !message.isEmpty {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(Color.welcomeRed)
                }

                Button {
                    Task {
                        if await session.saveProfile(draft) != nil {
                            dismiss()
                        }
                    }
                } label: {
                    Text(session.isBusy ? "Saving..." : "Create Profile")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.ecoOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .opacity(canSave ? 1 : 0.4)
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
                .accessibilityIdentifier("profile-save")
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Your Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if draft.displayName.isEmpty {
                draft.displayName = session.account?.user.name ?? ""
            }
        }
    }

    private var canSave: Bool {
        !session.isBusy && !draft.headline.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func field(_ title: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            TextField(prompt, text: text)
                .textInputAutocapitalization(title == "Skills" ? .never : .words)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.card)
                .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
        }
    }
}
