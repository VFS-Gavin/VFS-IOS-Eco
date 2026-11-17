import SwiftUI

enum PlanningCatalog {
    static let monthlyRange = "$1,500 - $2,500 CAD"
    static let tuitionNote = "Tuition is not included."
    static let costs: [(name: String, range: String, detail: String)] = [
        ("Housing", "$800 - $1,500", "Rent is your biggest expense. Cost varies significantly by neighborhood and roommates."),
        ("Food & Groceries", "$300 - $500", "Cooking at home is key. Dining out in Vancouver averages $20-$40 per meal."),
        ("Transportation", "$100 - $180", "A Compass Card monthly pass provides unlimited transit access across all zones."),
        ("Personal & Misc", "$200 - $400", "Phone plan, internet, entertainment, and personal care items."),
    ]
    static let homes: [(name: String, price: String, badge: String, points: [String])] = [
        ("Shared Room", "$800+", "Best Value", ["Most Affordable", "Shared bedroom", "Shared amenities"]),
        ("Private Room", "$1,000+", "Recommended", ["Private bedroom", "Shared house/apt", "Balance of privacy & cost"]),
        ("Studio Apt", "$1,800+", "Premium", ["Full privacy", "Private kitchen/bath", "Premium lifestyle"]),
    ]
    static let steps: [(title: String, detail: String)] = [
        ("Calculate Your Income", "Know exactly how much money you have each month from all sources (savings, family support, part-time work)."),
        ("List Fixed Expenses", "Start with bills that don't change: rent, phone plan, subscriptions. These come out first."),
        ("Track Variable Spending", "Food, entertainment, and shopping vary monthly. Track for 2-3 weeks to see patterns."),
        ("Review & Adjust", "Check your budget weekly. Overspent on food? Cut back next week. It's flexible!"),
    ]
    static let saves: [(title: String, detail: String)] = [
        ("Student Discounts", "Always ask! Many coffee shops, tech stores, and grocers near campus offer 10-15% off with your Student ID."),
        ("Cook at Home", "Meal prepping is the #1 way to save money. Eating out daily can easily cost $800+ per month."),
        ("Skip the Car", "Gas, insurance, and parking in Vancouver are very expensive. Stick to transit and walking."),
        ("Buy Used Gear", "Connect with alumni or check Facebook Marketplace for second-hand textbooks and equipment."),
    ]
    static let eats: [(name: String, place: String, detail: String, url: String?)] = [
        ("VCC Culinary Arts Cafe", "250 W Pender St", "Student-run restaurant with quality meals at training prices. Lunch ~$10-15.", "https://www.google.com/maps/search/VCC+Culinary+Arts+250+W+Pender+St+Vancouver"),
        ("Chinatown Eats", "Pender & Keefer St", "BBQ spots, dim sum, and noodle houses. Full meals for $8-12.", "https://www.google.com/maps/search/Chinatown+Vancouver+restaurants"),
        ("Brooklyn Pizza", "595 Hornby St", "Huge NY-style slices that fill you up. Great value for hungry students.", "https://maps.app.goo.gl/FLf57DV7oTJgedht9"),
        ("Costco Food Court", "605 Expo Blvd", "Famous $1.50 hot dog + drink combo. Pizza slices ~$2.50. Membership required - split with roommates!", "https://www.google.com/maps/search/Costco+605+Expo+Blvd+Vancouver"),
        ("International Village", "88 W Pender St", "Food court with diverse Asian cuisine. T&T Supermarket for groceries too.", "https://www.google.com/maps/search/International+Village+Mall+88+W+Pender+Vancouver"),
        ("Budget Sushi Spots", "Various downtown", "Look for lunch specials ~$12-15. Sushi Garden, Samurai, and more.", nil),
        ("Dollar Slice Pizza", "Granville St", "Fresh Slice and others offer slices from $3-4. Quick grab-and-go option.", nil),
        ("Loblaws City Market", "Robson & Cambie", "Full hot meal & lunch selection ready to go. Great for groceries too - PC Optimum points add up!", "https://www.google.com/maps/search/Loblaws+City+Market+Robson+Vancouver"),
        ("Tim Hortons", "Multiple downtown", "Affordable coffee, breakfast wraps, and soups. Student budget staple.", "https://www.google.com/maps/search/Tim+Hortons+downtown+Vancouver"),
    ]
}

struct FinancialPlanningView: View {
    @Environment(\.openURL) private var openURL
    @State private var tab: Tab = .budget

    private enum Tab: String, CaseIterable, Identifiable {
        case budget = "Monthly Budget"
        case housing = "Housing Costs"
        case saving = "Smart Saving"
        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHero(
                    lead: "Financial",
                    accent: "Planning",
                    accentColor: .pageTeal,
                    detail: "A realistic guide to living costs in Vancouver. Plan ahead to enjoy your time at VFS stress-free."
                )

                GuidePills(options: Array(Tab.allCases), title: { $0.rawValue }, selection: $tab)
                    .accessibilityIdentifier("planning-tabs")

                switch tab {
                case .budget:
                    budget
                case .housing:
                    housing
                case .saving:
                    saving
                }

                NavigationLink(value: WelcomeRoute.schoolInfo) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Student Discounts")
                            .font(.headline)
                        Text("Save money with your VFS Student ID")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.stoneInk)
            }
            .padding(20)
        }
        .deskPage(tint: .pageTeal)
        .navigationTitle("Financial Planning")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var budget: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Estimated Monthly Living Costs")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.stoneMuted)
                Text(PlanningCatalog.monthlyRange)
                    .font(.system(.title, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                    .accessibilityIdentifier("planning-monthly")
                Text("This range covers housing, food, transit, and personal expenses.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                Text(PlanningCatalog.tuitionNote)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.stoneInk)
            }
            .guideCard()

            ForEach(PlanningCatalog.costs, id: \.name) { cost in
                card(cost.name) {
                    Text(cost.range)
                        .font(.headline)
                        .foregroundStyle(Color.stoneInk)
                    Text(cost.detail)
                }
            }

            card("How to Create Your Budget") {
                Text("A simple guide to managing your money")
                Text("The 50/30/20 Rule").font(.headline)
                Text("50% Needs — Rent, groceries, transit, utilities")
                Text("30% Wants — Entertainment, dining out, hobbies")
                Text("20% Savings — Emergency fund, future goals")
                ForEach(Array(PlanningCatalog.steps.enumerated()), id: \.offset) { index, step in
                    Text("\(index + 1). \(step.title)")
                        .font(.subheadline.weight(.semibold))
                    Text(step.detail)
                }
                Text("Free Budgeting Tools").font(.headline)
                link("Mint — Auto-tracking", "https://www.mint.com")
                link("YNAB — Zero-based", "https://www.ynab.com")
                Text("Google Sheets — DIY & free")
                Text("Notes App — Simple list")
                Text("Pro tip: Even a simple spreadsheet or notes app works great. The best budget is the one you'll actually use!")
            }
        }
    }

    private var housing: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(PlanningCatalog.homes, id: \.name) { home in
                card(home.name) {
                    Text("\(home.price)/mo")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.stoneInk)
                    Text(home.badge)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.welcomeRed)
                    ForEach(home.points, id: \.self) { point in
                        Text(point)
                    }
                }
            }
            Text("Looking for a place? Check the VFS Housing Portal.")
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
            if let url = WelcomeFormCatalog.downloadURL(path: "/welcome/housing", base: APIConfiguration.baseURL) {
                Button("VFS Housing Portal") { openURL(url) }
                    .tint(Color.welcomeRed)
            }
        }
    }

    private var saving: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(PlanningCatalog.saves, id: \.title) { tip in
                card(tip.title) {
                    Text(tip.detail)
                }
            }
            card("Budget-Friendly Eats Near Campus") {
                Text("Cheap & good spots within walking distance of VFS")
                ForEach(PlanningCatalog.eats, id: \.name) { spot in
                    VStack(alignment: .leading, spacing: 2) {
                        if let address = spot.url {
                            link(spot.name, address)
                        } else {
                            Text(spot.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.stoneInk)
                        }
                        Text(spot.place)
                        Text(spot.detail)
                    }
                    .padding(.top, 6)
                }
                Text("Pro tip: Download the \"Too Good To Go\" app to grab discounted meals from local restaurants at closing time!")
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
