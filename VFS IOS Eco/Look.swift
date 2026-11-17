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
        .background(Color.white)
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
            .background(Color.white)
            .overlay(Rectangle().stroke(Color(red: 214 / 255, green: 211 / 255, blue: 209 / 255), lineWidth: 1))
            .accessibilityIdentifier(identifier)
            .onSubmit(onSubmit)
    }
}

struct SharpCard<Content: View>: View {
    var bar: Color
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .overlay(alignment: .leading) { Rectangle().fill(bar).frame(width: 3) }
            .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
    }
}
