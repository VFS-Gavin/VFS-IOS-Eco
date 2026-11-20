import SwiftUI

enum HubTone {
    case crimson
    case blue
    case green

    var bar: Color {
        switch self {
        case .crimson: .welcomeRed
        case .blue: .hubBlue
        case .green: .hubGreen
        }
    }

    var wash: Color { bar.opacity(0.12) }
}

extension WelcomeGroup {
    var tone: HubTone {
        let key = (id + " " + title).lowercased()
        if key.contains("ready") || key.contains("prepar") || key.contains("logistic") {
            return .green
        }
        if key.contains("experience") || key.contains("campus") {
            return .blue
        }
        return .crimson
    }

    var subtitle: String {
        switch tone {
        case .crimson: "The essentials to get you started"
        case .blue: "Explore your future campus"
        case .green: "Logistics and student life"
        }
    }
}

enum HubEmoji {
    static func symbol(for path: String) -> String {
        switch path {
        case "/welcome/acceptance": "🎉"
        case "/welcome/study-permit": "✈️"
        case "/welcome/insurance": "🛡️"
        case "/welcome/coordinator": "👨‍🏫"
        case "/welcome/forms": "📋"
        case "/welcome/payment-methods": "💳"
        case "/welcome/instructors": "🏫"
        case "/welcome/campus-tour": "📍"
        case "/welcome/mental-health": "💚"
        case "/welcome/student-announcements": "📣"
        case "/welcome/school-info": "📅"
        case "/welcome/setting-up-accounts": "📱"
        case "/welcome/financial-planning": "💰"
        case "/welcome/student-stories": "🎓"
        case "/welcome/o-day": "📅"
        case "/welcome/housing": "🏠"
        case "/welcome/social-media": "📱"
        case "/welcome/connect": "🤝"
        case "/welcome/documents": "📘"
        default: "📄"
        }
    }
}

struct HubSectionHeader: View {
    var title: String
    var subtitle: String
    var tone: HubTone

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(tone.bar)
                .frame(width: 6, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.stoneInk)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
            }
        }
    }
}

struct HubCard: View {
    var emoji: String
    var title: String
    var description: String
    var wash: Color

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(emoji)
                .font(.title2)
                .frame(width: 48, height: 48)
                .background(wash)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.stoneInk)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.stoneLine, lineWidth: 1))
    }
}

struct CreativeHeadline: View {
    var lead: String
    var accent: String
    var accentColor: Color
    var detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            (Text(lead).foregroundStyle(Color.stoneInk) + Text(accent).foregroundStyle(accentColor))
                .font(.system(size: 40, weight: .bold, design: .serif))
            Text(detail)
                .font(.body)
                .foregroundStyle(Color.stoneMuted)
        }
    }
}

struct CreativeSearchField: View {
    var placeholder: String
    @Binding var text: String
    var identifier: String
    var onSubmit: () -> Void = {}

    var body: some View {
        TextField(placeholder, text: $text)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.card)
            .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
            .accessibilityIdentifier(identifier)
            .onSubmit(onSubmit)
    }
}

struct GuideHero: View {
    var lead: String
    var accent: String
    var accentColor: Color
    var detail: String

    var body: some View {
        VStack(spacing: 8) {
            Text(lead)
                .font(.system(size: 38, weight: .black))
                .foregroundStyle(Color.stoneInk)
                .multilineTextAlignment(.center)
            Text(accent)
                .font(.system(size: 38, weight: .black))
                .foregroundStyle(accentColor)
                .multilineTextAlignment(.center)
            if !detail.isEmpty {
                Text(detail)
                    .font(.title3)
                    .foregroundStyle(Color.stoneMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }
}

struct GuidePills<Selection: Hashable>: View {
    var options: [Selection]
    var title: (Selection) -> String
    @Binding var selection: Selection

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    Text(title(option))
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(selection == option ? Color.stoneInk : Color.stoneMuted)
                        .background(selection == option ? Color.card : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(Color.stoneLine.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.stoneLine, lineWidth: 1))
    }
}

struct CrimsonButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color.welcomeRed.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

extension View {
    func guideCard() -> some View {
        padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.card)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.stoneLine, lineWidth: 1))
    }

    func deskPage(tint: Color = .welcomeRed) -> some View {
        background {
            ZStack {
                Color.stone
                RadialGradient(colors: [tint.opacity(0.16), .clear], center: .topTrailing, startRadius: 8, endRadius: 340)
            }
            .ignoresSafeArea()
        }
    }
}

struct SharpCard<Content: View>: View {
    var bar: Color
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.card)
            .overlay(alignment: .leading) { Rectangle().fill(bar).frame(width: 3) }
            .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
    }
}
