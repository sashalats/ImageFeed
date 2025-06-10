import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    private var isAuthenticating = false
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let profileService = ProfileService.shared
    
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.ypBlack
        
        let logoImageView = UIImageView(image: UIImage(named: "splash_screen_logo"))
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
            if let token = oauth2TokenStorage.token {
                UIBlockingProgressHUD.show()
                fetchProfile(token)
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let navController = storyboard.instantiateViewController(withIdentifier: "AuthNavigationController") as? UINavigationController,
                  let viewController = navController.viewControllers.first as? AuthViewController else {
                assertionFailure("Не удалось найти AuthNavigationController или AuthViewController")
                return
            }
            viewController.delegate = self
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure(
                "Неправильная конфигурация приложения: нет окна"
            )
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        guard !self.isAuthenticating else { return }
        self.isAuthenticating = true
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
            if let token = self.oauth2TokenStorage.token {
                UIBlockingProgressHUD.show()
                self.fetchProfile(token)
            }
        }
    }
    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.isAuthenticating = false
                self.switchToTabBarController()
            case .failure(let error):
                self.isAuthenticating = false
                print("Ошибка получения токена: \(error.localizedDescription)")
                break
            }
        }
    }
}

extension SplashViewController {
    private func fetchProfile(_ token: String) {
        profileService.fetchProfile { result in
            switch result {
            case .success(let profile):
                print("Профиль загружен: \(profile)")
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                print("Ошибка загрузки профиля: \(error.localizedDescription)")
                debugPrint("Подробности ошибки:", error)
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}
