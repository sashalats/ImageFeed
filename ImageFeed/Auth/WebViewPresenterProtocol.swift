import Foundation
import WebKit

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
    func shouldAllow(navigationAction: WKNavigationAction) -> (code: String?, allow: Bool)
    
    func shouldHideProgress(for value: Float) -> Bool
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    private enum progressConstants {
        static let progressCompletionThreshold: CGFloat = 0.0001
    }
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let progress = Float(newValue)
        view?.setProgressValue(progress)
        view?.setProgressHidden(abs(progress - 1.0) <= 0.0001)
    }

    func code(from url: URL) -> String? {
        return authHelper.code(from: url)
    }

    func shouldAllow(navigationAction: WKNavigationAction) -> (code: String?, allow: Bool) {
        if let url = navigationAction.request.url,
           let code = code(from: url) {
            return (code, false)
        }
        return (nil, true)
    }
    func shouldHideProgress(for value: Float) -> Bool {
        return value >= 1.0
    }
}
