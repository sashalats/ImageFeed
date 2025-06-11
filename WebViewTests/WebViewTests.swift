@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsLoadRequest() {
        // given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        presenter.view = viewController

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertTrue(viewController.loadRequestCalled)
    }

    func testProgressVisibleWhenLessThenOne() {
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        XCTAssertFalse(presenter.shouldHideProgress(for: 0.6))
    }

    func testProgressHiddenWhenOne() {
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        XCTAssertTrue(presenter.shouldHideProgress(for: 1.0))
    }

    func testAuthHelperAuthURL() {
        let configuration = AuthConfiguration.standard
        let helper = AuthHelper(configuration: configuration)

        guard let urlString = helper.authURL()?.absoluteString else {
            XCTFail("URL is nil")
            return
        }

        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
        XCTAssertTrue(urlString.contains("code"))
    }

    func testCodeFromURL() {
        var components = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        components.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = components.url!

        let helper = AuthHelper()
        let code = helper.code(from: url)

        XCTAssertEqual(code, "test code")
    }
}
