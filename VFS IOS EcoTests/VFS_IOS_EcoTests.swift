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

    func testSignInLinkReadsTheTokenFromTheUniversalLink() {
        let url = URL(string: "https://welcome.vfs.com/auth/app/magic-link/abcdefghijklmnopqrstuvwxyz012345")!
        XCTAssertEqual(SignInLink.token(from: url), "abcdefghijklmnopqrstuvwxyz012345")
        XCTAssertNil(SignInLink.token(from: URL(string: "https://welcome.vfs.com/welcome")!))
    }
}
