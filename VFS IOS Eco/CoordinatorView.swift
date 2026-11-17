import SwiftUI

struct CoordinatorView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Contact Your Coordinator")
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Your dedicated points of contact for academic success. Here to guide you from day one to graduation.")
                    .font(.body)
                    .foregroundStyle(Color.stoneLabel)

                ForEach(CoordinatorCatalog.people) { person in
                    personCard(person)
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Contact Coordinator")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func personCard(_ person: CoordinatorContact) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(person.name)
                .font(.system(.title3, design: .serif))
                .foregroundStyle(Color.stoneInk)
            Text(person.title)
                .font(.subheadline)
                .foregroundStyle(Color.stoneLabel)

            contactRow("Direct", person.phone, url: person.phoneURL)
            if let mobile = person.mobile {
                contactRow("Mobile", mobile, url: person.mobileURL)
            }
            if let tollFree = person.tollFree {
                contactRow("Toll-Free", tollFree, url: nil)
            }

            if let mailURL = person.mailURL {
                Button(person.email) { openURL(mailURL) }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.welcomeRed)
            }
            if let calendly = person.calendly, let label = person.calendlyLabel {
                Button(label) { openURL(calendly) }
                    .buttonStyle(.bordered)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityIdentifier("coordinator-\(person.email)")
    }

    private func contactRow(_ label: String, _ value: String, url: URL?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Color.stoneLabel)
            if let url {
                Button(value) { openURL(url) }
                    .font(.subheadline.weight(.semibold))
                    .tint(Color.welcomeRed)
            } else {
                Text(value)
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}
