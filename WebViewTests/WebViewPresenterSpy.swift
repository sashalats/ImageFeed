import ImageFeed
import WebKit
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    func shouldHideProgress(for value: Float) -> Bool {
        return abs(value - 1.0) <= 0.0001
    }
    
    func shouldAllow(navigationAction: WKNavigationAction) -> (code: String?, allow: Bool) {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return (codeItem.value, false)
        } else {
            return (nil, true)
        }
    }
    
    var viewDidLoadCalled = false
    var view: WebViewViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) { }

    func code(from url: URL) -> String? { nil }
}
