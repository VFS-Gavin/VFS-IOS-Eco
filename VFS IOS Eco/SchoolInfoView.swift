import SwiftUI

struct SchoolInfoView: View {
    @Environment(\.openURL) private var openURL
    @State private var tab: Tab = .discounts
    @State private var category = "all"
    @State private var calendarTab: CalendarTab = .holidays
    @State private var programCode = ""

    private enum Tab: String, CaseIterable, Identifiable {
        case discounts = "Discounts"
        case merch = "Merch"
        case calendar = "Calendar"
        var id: String { rawValue }
    }

    private enum CalendarTab: String, CaseIterable, Identifiable {
        case holidays = "Holidays"
        case schedules = "Class Schedules"
        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHero(
                    lead: "School",
                    accent: "Information",
                    accentColor: .pagePink,
                    detail: "Access important dates, exclusive discounts, and official VFS merchandise"
                )

                GuidePills(options: Array(Tab.allCases), title: { $0.rawValue }, selection: $tab)
                    .accessibilityIdentifier("school-info-tabs")

                switch tab {
                case .discounts:
                    discounts
                case .merch:
                    merch
                case .calendar:
                    calendar
                }
            }
            .padding(20)
        }
        .deskPage(tint: .pagePink)
        .navigationTitle("School Info")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var discounts: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Pro Tip!")
                    .font(.headline)
                Text("Always show your valid VFS Student ID before paying. Some businesses don't advertise student discounts, so it never hurts to ask!")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
            }
            .guideCard()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SchoolInfoCatalog.categories, id: \.id) { item in
                        Button(item.name) { category = item.id }
                            .buttonStyle(.bordered)
                            .tint(category == item.id ? Color.welcomeRed : Color.stoneMuted)
                    }
                }
            }

            let visible = SchoolInfoCatalog.discounts(in: category)
            ForEach(visible) { discount in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(discount.name)
                            .font(.headline)
                        Spacer()
                        Text(discount.price)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.stoneMuted)
                    }
                    Text(discount.discount)
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.6)
                        .foregroundStyle(Color.welcomeRed)
                    if discount.verified {
                        Text("SHOW ID")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.1)
                            .foregroundStyle(Color.stoneMuted)
                    }
                    Text(discount.address)
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    if let link = discount.link {
                        Button("More Info") { openURL(link) }
                            .font(.subheadline.weight(.semibold))
                            .tint(Color.welcomeRed)
                    }
                }
                .guideCard()
            }
            Text("Showing all \(visible.count) discounts")
                .font(.footnote)
                .foregroundStyle(Color.stoneMuted)
                .frame(maxWidth: .infinity)

            Text("VFS Partners")
                .font(.system(size: 22, weight: .black))
            ForEach(SchoolInfoCatalog.partners) { partner in
                VStack(alignment: .leading, spacing: 8) {
                    Text(partner.name)
                        .font(.headline)
                    Text(partner.description)
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    Button("Learn More") { openURL(partner.link) }
                        .buttonStyle(CrimsonButtonStyle())
                }
                .guideCard()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Price Guide")
                    .font(.headline)
                Text("$  Items around $10")
                Text("$$  Items around $15-25")
                Text("$$$  Premium pricing")
            }
            .font(.subheadline)
            .foregroundStyle(Color.stoneMuted)
            .guideCard()
        }
    }

    private var merch: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(["Hoodies", "T-Shirts", "Headwear", "Accessories"], id: \.self) { name in
                Button(name) { openURL(SchoolInfoCatalog.shopURL) }
                    .buttonStyle(.bordered)
                    .tint(Color.welcomeRed)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Ready to Shop?")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(Color.white)
                Text("Browse the full collection online and get free pickup at campus reception")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                Button("Visit VFS Shop") { openURL(SchoolInfoCatalog.shopURL) }
                    .buttonStyle(CrimsonButtonStyle())
                    .tint(Color.white)
                    .foregroundStyle(Color.stoneInk)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.stoneInk)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var calendar: some View {
        VStack(alignment: .leading, spacing: 16) {
            GuidePills(options: Array(CalendarTab.allCases), title: { $0.rawValue }, selection: $calendarTab)

            switch calendarTab {
            case .holidays:
                holidays
            case .schedules:
                schedules
            }
        }
    }

    private var holidays: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("2026 School Calendar")
                .font(.system(size: 22, weight: .black))
            Text("Breaks & Statutory Holidays")
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
            ForEach(SchoolInfoCatalog.holidays) { holiday in
                VStack(alignment: .leading, spacing: 4) {
                    Text(holiday.name)
                        .font(.headline)
                        .foregroundStyle(holiday.highlight ? Color.welcomeRed : Color.stoneInk)
                    Text(holiday.date)
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    if holiday.highlight {
                        Text("EXTENDED BREAK")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.1)
                            .foregroundStyle(Color.welcomeRed)
                    }
                }
                .guideCard()
            }
            Button("Full Calendar") { openURL(SchoolInfoCatalog.fullCalendarURL) }
                .tint(Color.welcomeRed)
            VStack(alignment: .leading, spacing: 6) {
                Text("Looking for Program Start Dates?")
                    .font(.headline)
                Text("Each program has 3-6 start dates per year")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                Button("View Start Dates") { openURL(SchoolInfoCatalog.startDatesURL) }
                    .tint(Color.welcomeRed)
            }
            .guideCard()
        }
    }

    private var schedules: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Term 1 Class Schedules")
                .font(.system(size: 22, weight: .black))
            Text("View sample schedules for your program")
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
            VStack(alignment: .leading, spacing: 6) {
                Text("Important: Sample Schedules Only")
                    .font(.headline)
                Text("These are SAMPLE SCHEDULES for reference purposes only. Your actual schedule may differ based on your start date, program requirements, and campus availability. Official schedules will be provided by your Admissions Coordinator and instructors.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
            }
            .guideCard()

            Picker("Select Your Program", selection: $programCode) {
                Text("Choose a program").tag("")
                ForEach(SchoolInfoCatalog.programs) { program in
                    Text(program.name).tag(program.code)
                }
            }
            .accessibilityIdentifier("program-schedule-picker")

            if let program = SchoolInfoCatalog.programs.first(where: { $0.code == programCode }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(program.name)
                        .font(.headline)
                    Text("Term 1 Sample Schedule - \(program.term)")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    Button("Open sample schedule") {
                        if let url = SchoolInfoCatalog.scheduleURL(file: program.file, base: APIConfiguration.baseURL) {
                            openURL(url)
                        }
                    }
                    .buttonStyle(CrimsonButtonStyle())
                }
                .guideCard()
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Select a Program")
                        .font(.headline)
                    Text("Choose your program above to view the Term 1 schedule")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                }
                .guideCard()
            }
        }
    }
}
