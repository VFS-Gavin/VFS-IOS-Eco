import XCTest

final class VFS_IOS_EcoUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSignInShowsEmailAndSendLink() throws {
        let app = XCUIApplication()
        app.launch()
        signOutIfNeeded(app)

        XCTAssertTrue(app.textFields["sign-in-email"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["send-sign-in-link"].exists)
        XCTAssertTrue(app.buttons["dev-sign-in-student"].exists)
    }

    @MainActor
    func testDevSignInOpensTheRightScreen() throws {
        let app = XCUIApplication()
        app.launch()
        signOutIfNeeded(app)

        openDevAccount("alumni", in: app)
        XCTAssertTrue(app.navigationBars["Portfolio"].waitForExistence(timeout: 15))
        app.buttons["Sign out"].tap()

        openDevAccount("industry", in: app)
        XCTAssertTrue(app.staticTexts["Portfolio, collabs, and jobs"].waitForExistence(timeout: 15))
        app.buttons["Sign out"].tap()

        openDevAccount("pending", in: app)
        XCTAssertTrue(app.navigationBars["Welcome Hub"].waitForExistence(timeout: 15))
        app.buttons["Sign out"].tap()

        openDevAccount("student", in: app)
        XCTAssertTrue(app.navigationBars["Welcome Hub"].waitForExistence(timeout: 15))
    }

    @MainActor
    private func signOutIfNeeded(_ app: XCUIApplication) {
        let signOut = app.buttons["Sign out"]
        if signOut.waitForExistence(timeout: 3) {
            signOut.tap()
        }
    }

    @MainActor
    private func openDevAccount(_ role: String, in app: XCUIApplication) {
        let button = app.buttons["dev-sign-in-\(role)"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()
    }
}
