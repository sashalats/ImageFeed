import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}


final class WebViewViewController:UIViewController & WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?

    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    
    
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.accessibilityIdentifier = "WebViewViewController"
        navigationController?.navigationBar.tintColor = UIColor(named: "YP Black")
        webView.scrollView.keyboardDismissMode = .interactive
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.presenter?.didUpdateProgressValue(webView.estimatedProgress)
             })
        
        configureBackButton()
        presenter?.viewDidLoad()
    }
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }

    func load(request: URLRequest) {
        webView.load(request)
    }
    
    private func configureBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(named: "naw_back_button_white"),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        let result = presenter?.shouldAllow(navigationAction: navigationAction)
        if let code = result?.code {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(result?.allow == true ? .allow : .cancel)
        }
    }
}
