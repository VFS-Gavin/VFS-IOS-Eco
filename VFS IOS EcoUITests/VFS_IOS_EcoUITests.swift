import XCTest

final class VFS_IOS_EcoUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSignInShowsEmailAndSendLink() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.textFields["sign-in-email"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["send-sign-in-link"].exists)
    }
}
