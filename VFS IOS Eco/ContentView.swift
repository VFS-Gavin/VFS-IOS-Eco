import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var session: AppSession?
    @State private var pendingLink: URL?

    var body: some View {
        Group {
            if let session {
                RootScreen(session: session)
            } else {
                Color.stone.ignoresSafeArea()
            }
        }
        .onOpenURL { url in
            pendingLink = url
            openPendingLink()
        }
        .task {
            if session == nil {
                let created = AppSession(context: modelContext)
                session = created
                await created.restore()
                openPendingLink()
            }
        }
    }

    private func openPendingLink() {
        guard let session, let url = pendingLink else { return }
        pendingLink = nil
        Task { await session.open(url: url) }
    }
}

struct RootScreen: View {
    @Bindable var session: AppSession

    var body: some View {
        Group {
            switch session.phase {
            case .signedOut, .checkEmail:
                SignInView(session: session)
            case .signedIn:
                signedIn
            }
        }
    }

    @ViewBuilder
    private var signedIn: some View {
        if session.account?.welcomeHub == true {
            WelcomeHubView(session: session)
        } else if session.account?.home == "portfolio" {
            DestinationView(title: "Portfolio", subtitle: "Creative ECOsystem", session: session)
        } else {
            DestinationView(title: "Creative ECOsystem", subtitle: "Portfolio, collabs, and jobs", session: session)
        }
    }
}

struct SignInView: View {
    @Bindable var session: AppSession
    @State private var pastedLink = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Creative ECOsystem")
                .font(.system(.largeTitle, design: .serif))
                .foregroundStyle(Color.stoneInk)

            if session.phase == .checkEmail {
                Text("Check your email")
                    .font(.system(.title2, design: .serif))
                Text(session.email)
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneLabel)
                #if DEBUG
                TextField("Paste the sign-in link", text: $pastedLink)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityIdentifier("paste-sign-in-link")
                Button("Continue") {
                    let trimmed = pastedLink.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard let url = URL(string: trimmed) else { return }
                    Task { await session.open(url: url) }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.welcomeRed)
                .disabled(session.isBusy || URL(string: pastedLink.trimmingCharacters(in: .whitespacesAndNewlines)) == nil)
                .accessibilityIdentifier("continue-sign-in-link")
                #endif
                if let statusMessage = session.statusMessage {
                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneInk)
                }
            } else {
                TextField("Email", text: $session.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityIdentifier("sign-in-email")

                Button {
                    Task { await session.sendLink() }
                } label: {
                    Text(session.isBusy ? "Sending" : "Send sign-in link")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.welcomeRed)
                .disabled(session.isBusy || session.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("send-sign-in-link")

                if let statusMessage = session.statusMessage {
                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneInk)
                }
            }
            #if DEBUG
            devSignIn
            #endif
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.stone.ignoresSafeArea())
    }

    #if DEBUG
    private var devSignIn: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dev sign-in")
                .font(.subheadline)
                .foregroundStyle(Color.stoneLabel)
            ForEach(
                [
                    ("Pending", "pending"),
                    ("Student", "student"),
                    ("Alumni", "alumni"),
                    ("Industry", "industry"),
                ],
                id: \.1
            ) { title, role in
                Button(title) {
                    Task { await session.devSignIn(role: role) }
                }
                .buttonStyle(.bordered)
                .tint(Color.welcomeRed)
                .disabled(session.isBusy)
                .accessibilityIdentifier("dev-sign-in-\(role)")
            }
        }
    }
    #endif
}

struct WelcomeHubView: View {
    @Bindable var session: AppSession

    private var accent: Color {
        Color(hex: session.welcome?.accent ?? "8B1A1A") ?? .welcomeRed
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    if session.welcome?.setUpPortfolio == true || session.account?.setUpPortfolio == true {
                        Text("Set Up Your Portfolio")
                            .font(.system(.title3, design: .serif))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    ForEach(session.welcome?.groups ?? []) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(group.title.uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.4)
                                .foregroundStyle(Color.stoneLabel)
                            ForEach(group.cards) { card in
                                NavigationLink(value: WelcomeRoute(card: card)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(card.title)
                                            .font(.system(.headline, design: .serif))
                                            .foregroundStyle(Color.stoneInk)
                                        Text(card.description)
                                            .font(.subheadline)
                                            .foregroundStyle(Color.stoneLabel)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier(card.path)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.stone)
            .navigationTitle("Welcome Hub")
            .navigationDestination(for: WelcomeRoute.self) { route in
                switch route {
                case .schoolInfo:
                    SchoolInfoView()
                case .oDay:
                    ODayView(session: session)
                case .coordinator:
                    CoordinatorView()
                case .forms:
                    WelcomeFormsView(session: session)
                case .summary(let title, let description):
                    PageSummaryView(title: title, description: description)
                }
            }
            .toolbar {
                Button("Sign out") { session.signOut() }
            }
        }
        .tint(accent)
    }
}

struct PageSummaryView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(.largeTitle, design: .serif))
                .foregroundStyle(Color.stoneInk)
            Text(description)
                .font(.body)
                .foregroundStyle(Color.stoneLabel)
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.stone)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DestinationView: View {
    let title: String
    let subtitle: String
    @Bindable var session: AppSession

    var body: some View {
        NavigationStack {
            destination
        }
    }

    private var destination: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(.largeTitle, design: .serif))
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.stoneLabel)
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.stone.ignoresSafeArea())
        .toolbar {
            Button("Sign out") { session.signOut() }
        }
        .navigationTitle(title)
    }
}

extension Color {
    static let stone = Color(red: 250 / 255, green: 250 / 255, blue: 249 / 255)
    static let stoneInk = Color(red: 28 / 255, green: 25 / 255, blue: 23 / 255)
    static let stoneLabel = Color(red: 168 / 255, green: 162 / 255, blue: 158 / 255)
    static let welcomeRed = Color(red: 139 / 255, green: 26 / 255, blue: 26 / 255)

    init?(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard cleaned.count == 6, let value = Int(cleaned, radix: 16) else { return nil }
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CachedAccount.self, inMemory: true)
}
