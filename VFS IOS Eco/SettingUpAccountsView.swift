import SwiftUI

enum AccountsCatalog {
    static let banks: [(name: String, url: String)] = [
        ("TD Canada Trust", "https://www.td.com/ca/en/personal-banking"),
        ("RBC Royal Bank", "https://www.rbcroyalbank.com/"),
        ("Scotiabank", "https://www.scotiabank.com/ca/en/personal.html"),
        ("CIBC", "https://www.cibc.com/en/personal-banking.html"),
        ("BMO", "https://www.bmo.com/main/personal"),
    ]

    static let carriers: [(group: String, name: String, badge: String, url: String)] = [
        ("Premium Carriers", "Rogers", "Premium", "https://www.rogers.com/plans"),
        ("Premium Carriers", "Bell", "Premium", "https://www.bell.ca/Mobility"),
        ("Premium Carriers", "Telus", "Premium", "https://www.telus.com/en/mobility"),
        ("Student Favorites", "Fido", "Mid-Range", "https://www.fido.ca/phones"),
        ("Student Favorites", "Virgin Plus", "Mid-Range", "https://www.virginplus.ca/en/plans/postpaid.html"),
        ("Student Favorites", "Koodo", "Mid-Range", "https://www.koodomobile.com/rate-plans"),
        ("Budget Friendly", "Freedom Mobile", "Affordable", "https://www.freedommobile.ca/en-CA/plans"),
        ("Budget Friendly", "Public Mobile", "Affordable", "https://www.publicmobile.ca/en/bc/plans"),
        ("Budget Friendly", "Chatr", "Affordable", "https://www.chatr.com/"),
    ]

    static let checklist = [
        "Passport & Study Permit",
        "VFS Letter of Acceptance",
        "Canadian Address (or temporary)",
    ]

    static let noUPass = "VFS is NOT part of the UPass program. VFS students do NOT receive any student discounts on Compass Cards or transit fares. You will need to pay regular adult fares."
    static let cardDeposit = "$6 deposit"
    static let studentPlan = "$35 - $55 CAD / month"
}

struct SettingUpAccountsView: View {
    @Environment(\.openURL) private var openURL
    @State private var tab: Tab = .banking

    private enum Tab: String, CaseIterable, Identifiable {
        case banking = "Banking"
        case phone = "Phone Plan"
        case transit = "Transit"
        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHero(
                    lead: "Setting Up",
                    accent: "Accounts",
                    accentColor: .hubBlue,
                    detail: "Get connected. A guide to banking, phone plans, and getting around Vancouver."
                )

                GuidePills(options: Array(Tab.allCases), title: { $0.rawValue }, selection: $tab)
                    .accessibilityIdentifier("accounts-tabs")

                switch tab {
                case .banking:
                    banking
                case .phone:
                    phone
                case .transit:
                    transit
                }
            }
            .padding(20)
        }
        .deskPage(tint: .hubBlue)
        .navigationTitle("Setup Accounts")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var banking: some View {
        VStack(alignment: .leading, spacing: 16) {
            card("Canadian Banking 101") {
                Text("Opening a bank account is essential. Most major banks offer specialized student accounts with no monthly fees.")
                Text("Tip: Bring your Letter of Acceptance & Study Permit")
                    .font(.subheadline.weight(.semibold))
                Text("Checklist").font(.headline)
                ForEach(AccountsCatalog.checklist, id: \.self) { item in
                    Text(item)
                }
            }
            ForEach(AccountsCatalog.banks, id: \.name) { bank in
                link(bank.name, bank.url)
            }
        }
    }

    private var phone: some View {
        VStack(alignment: .leading, spacing: 16) {
            card("Choose Your Plan") {
                Text("\"Bring Your Own Device\" (BYOD) plans are the most affordable option. Contracts including a phone are more expensive.")
            }
            let groups = ["Premium Carriers", "Student Favorites", "Budget Friendly"]
            ForEach(groups, id: \.self) { group in
                Text(group.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.1)
                    .foregroundStyle(Color.stoneMuted)
                ForEach(AccountsCatalog.carriers.filter { $0.group == group }, id: \.name) { carrier in
                    HStack {
                        link(carrier.name, carrier.url)
                        Spacer()
                        Text(carrier.badge)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.stoneMuted)
                    }
                }
            }
            card("Back-to-School Deals") {
                Text("August and September offer the best data promotions. Look for \"Student Plans\" offering 20GB+ data at discounted rates.")
                Text("Average Student Plan")
                    .font(.subheadline.weight(.semibold))
                Text(AccountsCatalog.studentPlan)
            }
        }
    }

    private var transit: some View {
        VStack(alignment: .leading, spacing: 16) {
            card("Compass Card") {
                Text("Your all-access pass to Metro Vancouver transit. Load fares or a monthly pass for unlimited travel on Bus, SkyTrain, and SeaBus.")
                Text("SkyTrain, Bus, and SeaBus")
                link("Visit Compass Card Website", "https://www.compasscard.ca/")
            }
            Text("Important: No UPass or Student Discounts")
                .font(.headline)
                .foregroundStyle(Color.stoneInk)
            Text(AccountsCatalog.noUPass)
                .font(.subheadline)
                .foregroundStyle(Color.stoneInk)
                .guideCard()
            card("1. Get a Card") {
                Text("Purchase from a SkyTrain station vending machine (\(AccountsCatalog.cardDeposit)).")
            }
            card("2. Register Online") {
                Text("Create an account at compasscard.ca to manage your card and set up AutoLoad.")
            }
            card("3. Load Fares") {
                Text("Add Stored Value or buy a Monthly Pass. AutoLoad keeps you topped up automatically.")
            }
        }
    }

    private func card(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(Color.stoneInk)
            content()
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
        }
        .guideCard()
    }

    private func link(_ title: String, _ address: String) -> some View {
        Button(title) {
            if let url = URL(string: address) { openURL(url) }
        }
        .font(.subheadline.weight(.semibold))
        .tint(Color.welcomeRed)
    }
}
