import SwiftUI

struct MentalHealthView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("Mental Health Resources")
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text(MentalHealthCatalog.intro)
                    .font(.body)
                    .foregroundStyle(Color.stoneLabel)
                Text(MentalHealthCatalog.startHere)
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneInk)

                section(MentalHealthCatalog.crisis, banner: MentalHealthCatalog.crisisBanner)
                section(MentalHealthCatalog.students)
                section(MentalHealthCatalog.vancouver)
                section(MentalHealthCatalog.apps)
                section(MentalHealthCatalog.international)
                section(MentalHealthCatalog.indigenous)
                section(MentalHealthCatalog.lgbtq)
                section(MentalHealthCatalog.substance)
                section(MentalHealthCatalog.safety)

                VStack(alignment: .leading, spacing: 8) {
                    Text(MentalHealthCatalog.disclaimerTitle)
                        .font(.headline)
                        .foregroundStyle(Color.stoneInk)
                    Text(MentalHealthCatalog.disclaimer)
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneLabel)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Mental Health")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(_ section: SupportSection, banner: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.system(.title2, design: .serif))
                .foregroundStyle(Color.stoneInk)
            Text(section.subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.stoneLabel)
            if let banner {
                Text(banner)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.welcomeRed)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.welcomeRed.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            ForEach(section.resources) { resource in
                resourceCard(resource)
            }
        }
        .accessibilityIdentifier("mental-health-\(section.id)")
    }

    private func resourceCard(_ resource: SupportResource) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(resource.name)
                    .font(.headline)
                    .foregroundStyle(Color.stoneInk)
                Spacer(minLength: 8)
                if resource.recommended {
                    Text("Recommended")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.welcomeRed)
                } else if let tag = resource.tag {
                    Text(tag)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.stoneLabel)
                }
            }
            Text(resource.detail)
                .font(.subheadline)
                .foregroundStyle(Color.stoneLabel)
            if let note = resource.note {
                Text(note)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.stoneInk)
            }
            if let label = resource.phoneLabel, let url = resource.phoneURL {
                Button(label) { openURL(url) }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.welcomeRed)
            }
            if let label = resource.secondPhoneLabel, let url = resource.secondPhoneURL {
                Button(label) { openURL(url) }
                    .buttonStyle(.bordered)
                    .tint(Color.welcomeRed)
            }
            if resource.opensCoordinator {
                NavigationLink(value: WelcomeRoute.coordinator) {
                    Text(resource.siteLabel ?? "Contact Your Coordinator")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.welcomeRed)
            } else if let label = resource.siteLabel, let url = resource.siteURL {
                Button(label) { openURL(url) }
                    .buttonStyle(.bordered)
                    .tint(Color.welcomeRed)
            }
            if let hours = resource.hours {
                Text(hours)
                    .font(.caption)
                    .foregroundStyle(Color.stoneLabel)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityIdentifier("support-\(resource.name)")
    }
}
