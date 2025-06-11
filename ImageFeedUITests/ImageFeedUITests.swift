import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()

        let webView = app.webViews["WebViewViewController"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10), "WebView did not appear in time")

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        loginTextField.tap()
        loginTextField.typeText("")

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("")

        webView.swipeUp()
        webView.buttons["Login"].tap()

        let cell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        let table = app.tables.element
        XCTAssertTrue(table.waitForExistence(timeout: 5), "Table does not exist")

        table.swipeUp()

        let firstCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "First feed cell does not exist")

        let timeout: TimeInterval = 15
        let startTime = Date()

        while !firstCell.isHittable && Date().timeIntervalSince(startTime) < timeout {
            if table.cells.count == 0 {
                XCTFail("No cells found in table view")
                return
            }
            table.swipeUp()
            sleep(1)
        }

        XCTAssertTrue(firstCell.isHittable, "First cell is not hittable after scrolling")

        let likeButton = firstCell.buttons["likeButton"]
        if likeButton.exists && likeButton.isHittable {
            likeButton.tap()
            sleep(1)
            likeButton.tap()
        }

        firstCell.tap()

        let image = app.scrollViews.images.element(boundBy: 0)
        print(app.debugDescription)
        XCTAssertTrue(image.waitForExistence(timeout: 10), "Full-screen image did not appear")

        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        let backButton = app.buttons["backButton"]
        if backButton.waitForExistence(timeout: 5) {
            backButton.tap()
        }
    }
    
    func testProfile() throws {
        let cell = app.tables.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "Feed cell did not appear within timeout")
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["nameLabel"].exists)
        XCTAssertTrue(app.staticTexts["usernameLabel"].exists)
        XCTAssertTrue(app.staticTexts["statusLabel"].exists)

        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.exists)
        logoutButton.tap()
        
        let alert = app.alerts["Выход"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["Выйти"].tap()
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.exists || authButton.waitForExistence(timeout: 5))
    }
}
