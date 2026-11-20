import SwiftUI

struct AccountMenu: View {
    @Bindable var session: AppSession
    var openWelcome: (() -> Void)?
    var push: ((CreativeRoute) -> Void)?
    @Environment(\.openURL) private var openURL
    @State private var open = false

    init(session: AppSession, openWelcome: (() -> Void)? = nil, push: ((CreativeRoute) -> Void)? = nil) {
        self.session = session
        self.openWelcome = openWelcome
        self.push = push
    }

    var body: some View {
        Button {
            open = true
        } label: {
            HStack(spacing: 4) {
                Text(initial)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .background(Color(red: 185 / 255, green: 28 / 255, blue: 28 / 255))
                    .clipShape(Circle())
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.stoneMuted)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("account-menu")
        .accessibilityLabel("Account")
        .popover(isPresented: $open, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
            panel
                .presentationCompactAdaptation(.popover)
                .presentationBackground(Color.card)
        }
    }

    private var panel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle().fill(Color.ecoOrange).frame(height: 3)
            if let user = session.account?.user {
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.stoneInk)
                        .lineLimit(1)
                    Text(user.email)
                        .font(.caption)
                        .foregroundStyle(Color.stoneMuted)
                        .lineLimit(1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                Divider().overlay(Color.stoneLine)
            }
            if session.account?.showsCreative == true && session.account?.creative == "full" {
                accountItems
                Divider().overlay(Color.stoneLine).padding(.horizontal, 16)
            }
            row("Report a Bug / Suggest a Feature", tint: Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255)) {
                open = false
                if let url = URL(string: "https://forms.gle/9QXW6pAXUk7WtLjL6") {
                    openURL(url)
                }
            }
            Divider().overlay(Color.stoneLine).padding(.horizontal, 16)
            row("Sign out", tint: Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255)) {
                open = false
                session.signOut()
            }
        }
        .frame(width: 280)
        .background(Color.card)
    }

    @ViewBuilder
    private var accountItems: some View {
        if let slug = session.account?.profile?.slug {
            row("My Profile") { choose(.profile(slug)) }
            row("Manage Portfolio") { choose(.account(.managePortfolio)) }
        } else {
            row("Create Profile") { choose(.setupProfile) }
        }
        row("My Liked") { choose(.account(.liked)) }
        row("Profile Settings") {
            if session.account?.profile == nil {
                choose(.setupProfile)
            } else {
                choose(.account(.profileSettings))
            }
        }
        row("My Showcase") { choose(.account(.showcase)) }
        if session.account?.showsWelcomeHub == true, let openWelcome {
            row("Welcome Hub") {
                open = false
                openWelcome()
            }
        }
        if session.account?.user.role == "alumni" {
            row("Document Requests") { choose(.account(.documentRequests)) }
        }
    }

    private func row(_ title: String, tint: Color = .stoneInk, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func choose(_ route: CreativeRoute) {
        open = false
        push?(route)
    }

    private var initial: String {
        let name = session.account?.user.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return String(name.first ?? "?").uppercased()
    }
}
