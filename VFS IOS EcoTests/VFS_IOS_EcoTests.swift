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
            WelcomeRoute(card: WelcomeCard(title: "Campus Tour", description: "Campus map & locations", path: "/welcome/campus-tour")),
            .summary(title: "Campus Tour", description: "Campus map & locations")
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
        let url = SchoolInfoCatalog.scheduleURL(
            file: "MKD_Sample Schedule_T1_Sep_2025.pdf",
            base: URL(string: "https://welcome.vfs.com")!
        )
        XCTAssertEqual(url?.absoluteString, "https://welcome.vfs.com/schedules/MKD_Sample%20Schedule_T1_Sep_2025.pdf")
    }

    func testSignInLinkReadsTheTokenFromTheUniversalLink() {
        let url = URL(string: "https://welcome.vfs.com/auth/app/magic-link/abcdefghijklmnopqrstuvwxyz012345")!
        XCTAssertEqual(SignInLink.token(from: url), "abcdefghijklmnopqrstuvwxyz012345")
        XCTAssertNil(SignInLink.token(from: URL(string: "https://welcome.vfs.com/welcome")!))
    }
}
