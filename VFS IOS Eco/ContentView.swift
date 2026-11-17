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
            PortalTabs(session: session)
        } else if session.account?.home == "portfolio" {
            PortfolioScreen(session: session, navigationTitle: "Portfolio", industryLine: false)
        } else {
            PortfolioScreen(session: session, navigationTitle: "Creative ECOsystem", industryLine: true)
        }
    }
}

struct PortalTabs: View {
    @Bindable var session: AppSession
    @State private var tab = 0

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if tab == 0 {
                    WelcomeHubView(session: session)
                } else {
                    PortfolioScreen(session: session, navigationTitle: "Creative ECOsystem", industryLine: false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack(spacing: 8) {
                portalTab("Welcome Hub", index: 0, tint: .welcomeRed)
                portalTab("Creative", index: 1, tint: .ecoOrange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .overlay(alignment: .top) { Rectangle().fill(Color.stoneLine).frame(height: 1) }
        }
        .background(Color.stone)
    }

    private func portalTab(_ title: String, index: Int, tint: Color) -> some View {
        Button {
            tab = index
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .textCase(.uppercase)
                .tracking(0.4)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundStyle(tab == index ? tint : Color.stoneMuted)
                .background(tab == index ? tint.opacity(0.12) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(index == 0 ? "tab-welcome" : "tab-creative")
    }
}

struct SignInView: View {
    @Bindable var session: AppSession
    @State private var pastedLink = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                if session.phase == .checkEmail {
                    Text("Check your email")
                        .font(.system(size: 40, weight: .black))
                        .foregroundStyle(Color.stoneInk)
                    Text("We'll send you a secure, one-time login link.")
                        .font(.title3)
                        .foregroundStyle(Color.stoneMuted)
                    Text(session.email)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.stoneInk)
                    #if DEBUG
                    TextField("Paste the sign-in link", text: $pastedLink)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.stoneLine, lineWidth: 1))
                        .accessibilityIdentifier("paste-sign-in-link")
                    signInButton("Continue", identifier: "continue-sign-in-link", enabled: !session.isBusy && URL(string: pastedLink.trimmingCharacters(in: .whitespacesAndNewlines)) != nil) {
                        let trimmed = pastedLink.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard let url = URL(string: trimmed) else { return }
                        Task { await session.open(url: url) }
                    }
                    #endif
                } else {
                    Text("Sign In")
                        .font(.system(size: 44, weight: .black))
                        .foregroundStyle(Color.stoneInk)
                    Text("Enter your email to get started.")
                        .font(.title3)
                        .foregroundStyle(Color.stoneMuted)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.body.weight(.bold))
                            .foregroundStyle(Color.stoneInk)
                        TextField("name@example.com", text: $session.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.stoneLine, lineWidth: 1))
                            .accessibilityIdentifier("sign-in-email")
                    }

                    signInButton(session.isBusy ? "Sending" : "Send Login Link", identifier: "send-sign-in-link", enabled: !session.isBusy && !session.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                        Task { await session.sendLink() }
                    }
                }
                if let statusMessage = session.statusMessage {
                    Text(statusMessage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.stoneInk)
                }
                #if DEBUG
                devSignIn
                #endif
            }
            .padding(28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                Color.stone
                RadialGradient(colors: [Color.welcomeRed.opacity(0.16), .clear], center: .topTrailing, startRadius: 10, endRadius: 320)
            }
            .ignoresSafeArea()
        }
    }

    private func signInButton(_ title: String, identifier: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(.white)
                .background(enabled ? Color.welcomeRed : Color.welcomeRed.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityIdentifier(identifier)
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
    @State private var search = ""

    private var accent: Color {
        Color(hex: session.welcome?.accent ?? "8B1A1A") ?? .welcomeRed
    }

    private var query: String {
        search.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Creative")
                            .font(.system(size: 40, weight: .black))
                            .foregroundStyle(Color.stoneInk)
                        Text("Future Starts Here")
                            .font(.system(size: 40, weight: .black))
                            .foregroundStyle(Color.welcomeRed)
                        Text("Everything you need to prepare for an extraordinary education at Vancouver Film School.")
                            .font(.title3)
                            .foregroundStyle(Color.stoneMuted)
                    }

                    TextField("Search anything...", text: $search)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.stoneLine, lineWidth: 1))
                        .accessibilityIdentifier("welcome-search")

                    WelcomeAlerts(session: session)

                    if query.isEmpty && (session.welcome?.setUpPortfolio == true || session.account?.setUpPortfolio == true) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Creative ECOsystem")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.4)
                                .foregroundStyle(Color(red: 225 / 255, green: 29 / 255, blue: 72 / 255))
                            Text("Set Up Your Portfolio")
                                .font(.system(size: 26, weight: .black))
                                .foregroundStyle(Color.stoneInk)
                            Text("You came here to share your work. Open Creative ECOsystem to create your profile and start adding projects.")
                                .font(.subheadline)
                                .foregroundStyle(Color.stoneMuted)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 244 / 255, green: 63 / 255, blue: 94 / 255).opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(red: 244 / 255, green: 63 / 255, blue: 94 / 255).opacity(0.3), lineWidth: 1))
                    }

                    if showsAnnouncements {
                        NavigationLink(value: WelcomeRoute.announcements) {
                            HubCard(emoji: "📣", title: "Student Announcements", description: "VFS achievements, events and webinars", wash: Color.welcomeRed.opacity(0.12))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("welcome-announcements")
                    }

                    let groups = session.welcome?.groups ?? []
                    let visible = groups.map { ($0, matching($0)) }.filter { !$0.1.isEmpty }
                    if !query.isEmpty && visible.isEmpty && !showsAnnouncements {
                        Text("No results found for \"\(query)\"")
                            .font(.body)
                            .foregroundStyle(Color.stoneMuted)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 24)
                    }
                    ForEach(visible, id: \.0.id) { group, cards in
                        VStack(alignment: .leading, spacing: 14) {
                            HubSectionHeader(title: group.title, subtitle: group.subtitle, tone: group.tone)
                            ForEach(cards) { card in
                                NavigationLink(value: WelcomeRoute(card: card)) {
                                    HubCard(emoji: HubEmoji.symbol(for: card.path), title: card.title, description: card.description, wash: group.tone.wash)
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier(card.path)
                            }
                        }
                    }

                    if query.isEmpty {
                        VStack(spacing: 14) {
                            Text("Questions? We're here.")
                                .font(.system(size: 32, weight: .black))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("Reach out to your admissions coordinator for personalized help.")
                                .font(.body)
                                .foregroundStyle(Color.white.opacity(0.75))
                                .multilineTextAlignment(.center)
                            NavigationLink(value: WelcomeRoute.coordinator) {
                                Text("Contact Coordinator")
                                    .font(.body.weight(.bold))
                                    .foregroundStyle(Color.stoneInk)
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                }
                .padding(20)
            }
            .background {
                ZStack {
                    Color.stone
                    RadialGradient(colors: [Color.welcomeRed.opacity(0.16), .clear], center: .topTrailing, startRadius: 10, endRadius: 340)
                }
            }
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
                case .acceptance:
                    AcceptanceView()
                case .studyPermit:
                    StudyPermitView()
                case .insurance:
                    InsuranceView()
                case .mentalHealth:
                    MentalHealthView()
                case .studentStories:
                    StudentStoriesView()
                case .instructors:
                    InstructorsView(session: session)
                case .paymentMethods:
                    PaymentMethodsView()
                case .campusTour:
                    CampusTourView()
                case .settingUpAccounts:
                    SettingUpAccountsView()
                case .financialPlanning:
                    FinancialPlanningView()
                case .announcements:
                    StudentAnnouncementsView(session: session)
                case .programPrep(let slug):
                    ProgramPrepView(slug: slug)
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

    private var showsAnnouncements: Bool {
        query.isEmpty
            || "Student Announcements".localizedCaseInsensitiveContains(query)
            || "achievements".localizedCaseInsensitiveContains(query)
            || "events".localizedCaseInsensitiveContains(query)
    }

    private func matching(_ group: WelcomeGroup) -> [WelcomeCard] {
        guard !query.isEmpty else { return group.cards }
        return group.cards.filter {
            $0.title.localizedCaseInsensitiveContains(query) || $0.description.localizedCaseInsensitiveContains(query)
        }
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
    static let stoneMuted = Color(red: 120 / 255, green: 113 / 255, blue: 108 / 255)
    static let stoneLine = Color(red: 231 / 255, green: 229 / 255, blue: 228 / 255)
    static let welcomeRed = Color(red: 139 / 255, green: 26 / 255, blue: 26 / 255)
    static let ecoOrange = Color(red: 234 / 255, green: 88 / 255, blue: 12 / 255)
    static let hubBlue = Color(red: 37 / 255, green: 99 / 255, blue: 235 / 255)
    static let hubGreen = Color(red: 22 / 255, green: 163 / 255, blue: 74 / 255)
    static let collabPurple = Color(red: 168 / 255, green: 85 / 255, blue: 247 / 255)
    static let jobGold = Color(red: 202 / 255, green: 138 / 255, blue: 4 / 255)

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
