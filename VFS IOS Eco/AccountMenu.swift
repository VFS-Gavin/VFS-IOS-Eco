import SwiftUI

struct AccountMenu: View {
    @Bindable var session: AppSession
    var openWelcome: (() -> Void)?
    var push: ((CreativeRoute) -> Void)?
    @Environment(\.openURL) private var openURL

    init(session: AppSession, openWelcome: (() -> Void)? = nil, push: ((CreativeRoute) -> Void)? = nil) {
        self.session = session
        self.openWelcome = openWelcome
        self.push = push
    }

    var body: some View {
        Menu {
            if let user = session.account?.user {
                Text(user.name)
                Text(user.email)
            }
            if session.account?.creative == "full" {
                accountItems
            }
            Divider()
            Button("Report a Bug / Suggest a Feature") {
                if let url = URL(string: "https://forms.gle/9QXW6pAXUk7WtLjL6") {
                    openURL(url)
                }
            }
            Divider()
            Button("Sign out", role: .destructive) {
                session.signOut()
            }
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
        .accessibilityIdentifier("account-menu")
        .accessibilityLabel("Account")
    }

    @ViewBuilder
    private var accountItems: some View {
        if let slug = session.account?.profile?.slug {
            Button("My Profile") { push?(.profile(slug)) }
            Button("Manage Portfolio") { push?(.account(.managePortfolio)) }
        } else {
            Button("Create Profile") { push?(.setupProfile) }
        }
        Button("My Liked") { push?(.account(.liked)) }
        Button("Profile Settings") {
            if session.account?.profile == nil {
                push?(.setupProfile)
            } else {
                push?(.account(.profileSettings))
            }
        }
        Button("My Showcase") { push?(.account(.showcase)) }
        if session.account?.welcomeHub == true, let openWelcome {
            Button("Welcome Hub", action: openWelcome)
        }
        if session.account?.user.role == "alumni" {
            Button("Document Requests") { push?(.account(.documentRequests)) }
        }
    }

    private var initial: String {
        let name = session.account?.user.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return String(name.first ?? "?").uppercased()
    }
}
