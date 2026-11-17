import XCTest
@testable import VFS_IOS_Eco

final class VFS_IOS_EcoTests: XCTestCase {
    func testAccountDecodesStoredRoleAndFrontDoor() throws {
        let data = """
        {"home":"welcome","welcome_hub":true,"creative":"full","set_up_portfolio":true,"user":{"id":4,"name":"Ada","email":"ada@gmail.com","role":"pending"}}
        """.data(using: .utf8)!

        let account = try JSONDecoder().decode(Account.self, from: data)

        XCTAssertEqual(account.user.role, "pending")
        XCTAssertEqual(account.home, "welcome")
        XCTAssertTrue(account.welcomeHub)
        XCTAssertTrue(account.setUpPortfolio)
    }

    func testWelcomeGroupsKeepSchoolInfoAsOneCard() throws {
        let data = """
        {"accent":"#8B1A1A","set_up_portfolio":false,"groups":[{"id":"getting-ready","title":"Getting Ready","cards":[{"title":"School Info","description":"Calendar, days off & VFS gear","path":"/welcome/school-info"}]}]}
        """.data(using: .utf8)!

        let home = try JSONDecoder().decode(WelcomeHome.self, from: data)

        XCTAssertEqual(home.accent, "#8B1A1A")
        XCTAssertEqual(home.groups.first?.cards.first?.title, "School Info")
        XCTAssertEqual(home.groups.first?.cards.count, 1)
    }

    func testWelcomeCardsOpenSchoolInfoODayAndCoordinator() {
        XCTAssertEqual(WelcomeRoute(card: WelcomeCard(title: "School Info", description: "Calendar, days off & VFS gear", path: "/welcome/school-info")), .schoolInfo)
        XCTAssertEqual(WelcomeRoute(card: WelcomeCard(title: "O-Day Reminder", description: "Orientation schedule and details", path: "/welcome/o-day")), .oDay)
        XCTAssertEqual(WelcomeRoute(card: WelcomeCard(title: "Contact Coordinator", description: "Get in touch with your admissions coordinator", path: "/welcome/coordinator")), .coordinator)
        XCTAssertEqual(
            WelcomeRoute(card: WelcomeCard(title: "Housing", description: "Find a place to live", path: "/welcome/housing")),
            .summary(title: "Housing", description: "Find a place to live")
        )
    }

    func testODayKeepsTheNextUpcomingDate() throws {
        let data = """
        {"schedules":[
          {"id":1,"orientation_date":"2020-01-06","start_date":"2020-01-08","time":"9:00 AM","location":"Production Centre","address":"200","notes":null,"is_past":true},
          {"id":2,"orientation_date":"2026-12-10","start_date":"2026-12-14","time":"10:00 AM","location":"VFS","address":"198 W Hastings St","notes":"Bring ID","is_past":false}
        ]}
        """.data(using: .utf8)!

        let feed = try JSONDecoder().decode(ODayFeed.self, from: data)
        let next = feed.schedules.first(where: \.upcoming)

        XCTAssertEqual(next?.id, 2)
        XCTAssertEqual(next?.place, "VFS")
        XCTAssertEqual(WelcomeDates.longWeekday("2026-12-10"), "Thursday, December 10, 2026")
        let now = ISO8601DateFormatter().date(from: "2026-11-17T15:00:00Z")!
        XCTAssertEqual(WelcomeDates.daysUntil("2026-12-10", now: now), 23)
        XCTAssertEqual(feed.schedules.filter(\.upcoming).count, 1)
    }

    func testSchoolInfoAndCoordinatorsMatchTheWebsiteLists() {
        XCTAssertEqual(SchoolInfoCatalog.discounts.count, 56)
        XCTAssertEqual(SchoolInfoCatalog.holidays.count, 16)
        XCTAssertEqual(SchoolInfoCatalog.programs.count, 13)
        XCTAssertEqual(SchoolInfoCatalog.discounts(in: "food").count, 32)
        XCTAssertEqual(SchoolInfoCatalog.discounts.first { $0.name == "Waves Coffee House" }?.discount, "10% off")
        XCTAssertEqual(CoordinatorCatalog.people.count, 5)
        XCTAssertEqual(CoordinatorCatalog.people.first?.email, "kihal@vfs.com")
        XCTAssertEqual(MentalHealthCatalog.crisis.resources.first?.phone, "988")
        XCTAssertEqual(MentalHealthCatalog.students.resources.first?.name, "Here2Talk")
        XCTAssertEqual(MentalHealthCatalog.sections.count, 9)
        XCTAssertEqual(AcceptanceCatalog.programs.filter(\.isReady).count, 10)
        XCTAssertEqual(AcceptanceCatalog.programs.first { $0.name == "Sound Design" }?.slug, "sound-design")
        XCTAssertEqual(MakeupFilms.titles.count, 37)
        XCTAssertTrue(MentalHealthCatalog.disclaimer.contains("VFS is not affiliated"))
        XCTAssertEqual(
            WelcomeRoute(card: WelcomeCard(title: "Mental Health Resources", description: "Wellness tools and support", path: "/welcome/mental-health")),
            .mentalHealth
        )
        XCTAssertEqual(
            WelcomeRoute(card: WelcomeCard(title: "Study Permit Guide", description: "Step-by-step visa application process", path: "/welcome/study-permit")),
            .studyPermit
        )
        XCTAssertEqual(
            WelcomeRoute(card: WelcomeCard(title: "Instructors", description: "Meet the VFS faculty", path: "/welcome/instructors")),
            .instructors
        )
        XCTAssertEqual(
            WelcomeRoute(card: WelcomeCard(title: "Payment Methods", description: "How to pay your tuition and fees", path: "/welcome/payment-methods")),
            .paymentMethods
        )
        XCTAssertEqual(PaymentCatalog.provinces.count, 13)
        XCTAssertEqual(PaymentCatalog.receivables, "receivables@vfs.com")
        XCTAssertEqual(PaymentCatalog.swift, "BOFMCAM2")
        XCTAssertEqual(PaymentCatalog.accountNumber, "1823-417")
        XCTAssertTrue(PaymentCatalog.cardFee.contains("3.5%"))
        XCTAssertEqual(
            WelcomeRoute(card: WelcomeCard(title: "Campus Tour", description: "Find your way around VFS", path: "/welcome/campus-tour")),
            .campusTour
        )
        XCTAssertEqual(CampusCatalog.campuses.count, 4)
        XCTAssertEqual(CampusCatalog.campuses.first?.name, "198 West Hastings")
        XCTAssertEqual(CampusCatalog.campuses.first?.mapLink, "https://maps.app.goo.gl/c57Q5kETbgk1Uguv6")
        XCTAssertEqual(CampusCatalog.campuses.first { $0.id == 3 }?.programs.count, 8)
        XCTAssertTrue(CampusCatalog.mapNote.contains("five VFS locations"))
        XCTAssertEqual(
            WelcomeRoute(card: WelcomeCard(title: "Setup Accounts", description: "Banking, phone, and transit", path: "/welcome/setting-up-accounts")),
            .settingUpAccounts
        )
        XCTAssertEqual(AccountsCatalog.banks.count, 5)
        XCTAssertEqual(AccountsCatalog.banks.first?.url, "https://www.td.com/ca/en/personal-banking")
        XCTAssertTrue(AccountsCatalog.noUPass.contains("NOT part of the UPass"))
        XCTAssertEqual(AccountsCatalog.cardDeposit, "$6 deposit")
        XCTAssertEqual(AccountsCatalog.studentPlan, "$35 - $55 CAD / month")
        XCTAssertEqual(
            WelcomeRoute(card: WelcomeCard(title: "Financial Planning", description: "Budget for life in Vancouver", path: "/welcome/financial-planning")),
            .financialPlanning
        )
        XCTAssertEqual(PlanningCatalog.monthlyRange, "$1,500 - $2,500 CAD")
        XCTAssertEqual(PlanningCatalog.tuitionNote, "Tuition is not included.")
        XCTAssertEqual(PlanningCatalog.costs.first?.range, "$800 - $1,500")
        XCTAssertEqual(PlanningCatalog.homes.first { $0.name == "Studio Apt" }?.price, "$1,800+")
        XCTAssertTrue(PlanningCatalog.saves.contains { $0.detail.contains("$800+") })
        XCTAssertEqual(PlanningCatalog.eats.first { $0.name == "Costco Food Court" }?.place, "605 Expo Blvd")
        let url = SchoolInfoCatalog.scheduleURL(
            file: "MKD_Sample Schedule_T1_Sep_2025.pdf",
            base: URL(string: "https://welcome.vfs.com")!
        )
        XCTAssertEqual(url?.absoluteString, "https://welcome.vfs.com/schedules/MKD_Sample%20Schedule_T1_Sep_2025.pdf")
    }

    func testFormsListOpensTheFiveRequests() {
        XCTAssertEqual(
            WelcomeRoute(card: WelcomeCard(title: "Forms, Documents, & Requests", description: "Submit forms, update contacts, and request documents", path: "/welcome/forms")),
            .forms
        )
        let links = WelcomeFormCatalog.groups.flatMap(\.items).compactMap(\.link)
        XCTAssertEqual(links, [.survey, .parentConsent, .contact, .confidential, .t2202])
    }

    func testParentConsentOmitsBlankContactsAndSendsTheDeclaration() {
        let body = FormDrafts.parentConsent(
            person1Name: "Pat",
            person1Relationship: "",
            person1Phone: "",
            person1Email: "",
            person2Name: "",
            person2Relationship: "",
            person2Phone: "",
            person2Email: "",
            studentName: "Ada",
            studentSignature: "Ada",
            date: "2026-11-17",
            consent: true
        )

        XCTAssertEqual(body["student_name"] as? String, "Ada")
        XCTAssertEqual(body["consent_acknowledged"] as? Bool, true)
        XCTAssertEqual(body["person1_name"] as? String, "Pat")
        XCTAssertNil(body["person1_email"])
        XCTAssertNil(body["person2_name"])
    }

    func testQuestionnairePayloadUsesOptionKeys() throws {
        let data = """
        {"already_submitted":false,"questions":[{"id":"q1_why_vfs","prompt":"Why did you choose VFS?","hint":"pick top 3","kind":"multi","min":1,"max":3,"required":true,"options":[{"key":"reputation","label":"VFS' reputation and recognition"}]}]}
        """.data(using: .utf8)!
        let form = try JSONDecoder().decode(SurveyForm.self, from: data)
        XCTAssertEqual(form.questions.first?.options?.first?.key, "reputation")
        XCTAssertFalse(form.alreadySubmitted)

        var draft = QuestionnaireDraft()
        draft.selections["q1_why_vfs"] = ["reputation", "alumni"]
        draft.ranks = ["1": "talent", "2": "luck", "3": "other"]
        draft.agreements = ["prefer_challenge": 4]
        let payload = draft.payload()
        XCTAssertEqual(payload["q1_why_vfs"] as? [String], ["reputation", "alumni"])
        let ranks = payload["q6_success_factors"] as? [String: String]
        XCTAssertEqual(ranks?["1"], "talent")
        let agreements = payload["q17_agreement_rankings"] as? [String: Int]
        XCTAssertEqual(agreements?["prefer_challenge"], 4)
    }

    func testSignInLinkReadsTheTokenFromTheUniversalLink() {
        let url = URL(string: "https://welcome.vfs.com/auth/app/magic-link/abcdefghijklmnopqrstuvwxyz012345")!
        XCTAssertEqual(SignInLink.token(from: url), "abcdefghijklmnopqrstuvwxyz012345")
        let appLink = URL(string: "vfseco://auth/app/magic-link/abcdefghijklmnopqrstuvwxyz012345")!
        XCTAssertEqual(SignInLink.token(from: appLink), "abcdefghijklmnopqrstuvwxyz012345")
        XCTAssertNil(SignInLink.token(from: URL(string: "https://welcome.vfs.com/welcome")!))
    }

    func testInstructorsDecodeAnEmptyListAndAProgramGroup() throws {
        let empty = try JSONDecoder().decode(InstructorDirectory.self, from: Data("{\"faculty\":[],\"programs\":[]}".utf8))
        XCTAssertTrue(empty.everyone.isEmpty)
        XCTAssertTrue(empty.programs.isEmpty)

        let data = """
        {"faculty":{"film-production":[
          {"id":1,"name":"First Listed","title":"Head Instructor","bio":"Teaches cameras.","photo_url":"https://example.test/first.jpg","imdb_url":"https://www.imdb.com/name/nm0000001/","program":"Film Production","program_slug":"film-production","sort_order":1},
          {"id":2,"name":"Second Listed","title":"Instructor","bio":null,"program":"Film Production","program_slug":"film-production","sort_order":2}
        ],"3d-animation-visual-effects":[
          {"id":3,"name":"Animation Lead","title":"Instructor","bio":null,"program":"3D Animation & Visual Effects","program_slug":"3d-animation-visual-effects","sort_order":1}
        ]},"programs":[
          {"program":"3D Animation & Visual Effects","program_slug":"3d-animation-visual-effects"},
          {"program":"Film Production","program_slug":"film-production"}
        ]}
        """.data(using: .utf8)!
        let directory = try JSONDecoder().decode(InstructorDirectory.self, from: data)
        XCTAssertEqual(directory.programs.map(\.program), ["3D Animation & Visual Effects", "Film Production"])
        XCTAssertEqual(directory.everyone.map(\.name), ["Animation Lead", "First Listed", "Second Listed"])
        XCTAssertEqual(directory.members(program: "film-production", role: "Head Instructor", search: "").map(\.name), ["First Listed"])
        XCTAssertEqual(directory.members(program: "all", role: "", search: "cameras").map(\.name), ["First Listed"])
        XCTAssertEqual(directory.roles, ["Head Instructor", "Instructor"])
    }

    func testPortfolioFeedDecodesAProjectAndAStringProgram() throws {
        let data = """
        {"professional_layout":false,"industry_view":false,"projects":{"current_page":1,"data":[
          {"id":9,"title":"The Salvage","slug":"the-salvage","is_professional":true,"is_featured":false,"category":"film_production","cover":"https://example.test/cover.jpg","profile":{"slug":"chris","role":null,"program":["film_production"],"program_label":"Film Production","location":"Vancouver, BC","skills":["DI"],"open_to_work":false,"open_to_collab":true,"projects_count":2},"user":{"id":15,"name":"Chris Andersen","profile_photo_url":null}},
          {"id":10,"title":"One Program","slug":"one-program","is_professional":false,"is_featured":true,"category":null,"cover":null,"profile":{"program":"acting","program_label":"Acting"},"user":{"name":"Pat"}}
        ],"last_page":2,"total":25}}
        """.data(using: .utf8)!
        let feed = try JSONDecoder().decode(PortfolioFeed.self, from: data)
        XCTAssertEqual(feed.projects.total, 25)
        XCTAssertTrue(feed.projects.hasMore)
        XCTAssertEqual(feed.projects.data.first?.title, "The Salvage")
        XCTAssertEqual(feed.projects.data.first?.profile.program, ["film_production"])
        XCTAssertEqual(feed.projects.data.first?.profile.programLabel, "Film Production")
        XCTAssertEqual(feed.projects.data.first?.user.name, "Chris Andersen")
        XCTAssertEqual(feed.projects.data.last?.profile.program, ["acting"])
        XCTAssertNil(feed.projects.data.last?.cover)
    }

    func testAnnouncementsStayOnTheirOwnTabs() throws {
        let welcome = """
        {"student_announcements":[{"title":"Webinar night","date":"November 24, 2026","event_date":"2026-11-24T00:00:00.000000Z","time":"6:00 PM","type":"Webinar","summary":"Join us","location":"Online"}],"notifications":[{"id":4,"title":"Welcome only","body":"Hub news","type":"info","link":"/welcome","link_label":"Open","image_url":null,"published_at":"2026-11-17T00:00:00+00:00","portal":"welcome_hub"}]}
        """.data(using: .utf8)!
        let hub = try JSONDecoder().decode(WelcomeAnnouncements.self, from: welcome)
        XCTAssertEqual(hub.studentAnnouncements.first?.title, "Webinar night")
        XCTAssertEqual(hub.notifications.first?.label, "Announcement")
        XCTAssertEqual(AnnouncementLink.url("/welcome", base: URL(string: "https://welcome.vfs.com")!)?.absoluteString, "https://welcome.vfs.com/welcome")
        XCTAssertEqual(AchievementCatalog.items.count, 8)
        XCTAssertEqual(AchievementCatalog.items.first?.date, "January 14, 2026")

        let creative = """
        {"notifications":[{"id":9,"title":"Creative only","body":"Portfolio news","type":"urgent","link":null,"link_label":null,"image_url":null,"published_at":null}]}
        """.data(using: .utf8)!
        let feed = try JSONDecoder().decode(CreativeAnnouncements.self, from: creative)
        XCTAssertEqual(feed.notifications.first?.label, "Important")
        XCTAssertEqual(
            WelcomeRoute(card: WelcomeCard(title: "Student Announcements", description: "VFS achievements, events and webinars", path: "/welcome/student-announcements")),
            .announcements
        )
        XCTAssertEqual(
            PortfolioProject.coverURL("http://10.129.151.17:8005/storage/https://picsum.photos/seed/salvage-grade/800/600")?.absoluteString,
            "https://picsum.photos/seed/salvage-grade/800/600"
        )
        XCTAssertEqual(
            PortfolioProject.coverURL("https://example.test/cover.jpg")?.absoluteString,
            "https://example.test/cover.jpg"
        )
    }
}
