import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    private let login = ""
    private let password = ""
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("testMode")
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["WebViewViewController"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10), "WebView did not appear in time")
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        loginTextField.tap()
        loginTextField.typeText(login)
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText(password)
        
        webView.swipeUp()
        webView.buttons["Login"].tap()
        
        let cell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        // 1. Подождать, пока открывается и загружается экран ленты
        let table = app.tables.element
        XCTAssertTrue(table.waitForExistence(timeout: 10), "Table does not exist")
        
        // 2. Сделать жест «смахивания» вверх по экрану для его скролла
        XCTContext.runActivity(named: "Смахивание вверх по таблице") { _ in
            let start = table.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.9))
            let finish = table.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.2))
            start.press(forDuration: 0.5, thenDragTo: finish)
        }

        // 3. Поставить лайк в ячейке верхней картинки
        let firstCell = table.cells.element(boundBy: 1)
//        var scrollAttempts = 0
//        while (!firstCell.exists || !firstCell.isHittable || firstCell.frame == .zero) && scrollAttempts < 10 {
//            print("Attempt \(scrollAttempts + 1): firstCell.exists=\(firstCell.exists), isHittable=\(firstCell.isHittable), frame=\(firstCell.frame)")
//            table.swipeUp()
//            scrollAttempts += 1
//            sleep(1)
//        }
        XCTAssertTrue(firstCell.exists && firstCell.isHittable, "First cell is not hittable after scrolling")
        
        let likeButton = firstCell.buttons["likeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5), "Like button does not exist")
        XCTAssertTrue(likeButton.isHittable, "Like button is not tappable")
        likeButton.tap()
        
        // 4. Отменить лайк в ячейке верхней картинки
        sleep(1)
        likeButton.tap()
        
        // 5. Нажать на верхнюю ячейку
        firstCell.tap()
        
        // 6. Подождать, пока картинка открывается на весь экран
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 10), "Full-screen image did not appear")
        
        // 7. Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        
        // 8. Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        
        // 9. Вернуться на экран ленты
        let backButton = app.buttons["backButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button did not appear")
        
        backButton.tap()
        
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
