import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    var presenter: ProfilePresenterProtocol?

    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let statusLabel = UILabel()
    private let logoutButton = UIButton()

    private var animationLayers = Set<CALayer>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.ypBlack

        setupAvatar()
        setupNameLabel()
        setupUsernameLabel()
        setupStatusLabel()
        setupLogoutButton()

        presenter?.viewDidLoad()
        stopShimmerAnimation()
    }

    private func setupAvatar() {
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func setupNameLabel() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .ypWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.accessibilityIdentifier = "nameLabel"
        view.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }

    private func setupUsernameLabel() {
        usernameLabel.font = UIFont.systemFont(ofSize: 13)
        usernameLabel.textColor = .ypGray
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.accessibilityIdentifier = "usernameLabel"
        view.addSubview(usernameLabel)

        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }

    private func setupStatusLabel() {
        statusLabel.font = UIFont.systemFont(ofSize: 13)
        statusLabel.textColor = .ypWhite
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.accessibilityIdentifier = "statusLabel"
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }

    private func setupLogoutButton() {
        logoutButton.setImage(UIImage(named: "Logout"), for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.accessibilityIdentifier = "logoutButton"
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func didTapLogout() {
        presenter?.didTapLogout()
    }
}

extension ProfileViewController: ProfileViewProtocol {
    func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        usernameLabel.text = profile.loginName
        statusLabel.text = profile.bio?.isEmpty == false ? profile.bio : "Bio Placeholder"
    }

    func updateAvatar(url: URL?) {
        for layer in animationLayers {
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()

        guard let url else { return }
        
        UIBlockingProgressHUD.show()
        avatarImageView.kf.setImage(with: url) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    break
                case .failure:
                    let gradient = self.makeAvatarGradient()
                    self.avatarImageView.layer.addSublayer(gradient)
                    self.animationLayers.insert(gradient)
                }
            }
        }
    }

    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Выход",
            message: "Точно выйти из аккаунта?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { _ in
            OAuth2TokenStorage.shared.token = nil
            ProfileLogoutService.shared.logout()

            if let window = UIApplication.shared.windows.first {
                window.rootViewController = SplashViewController()
                window.makeKeyAndVisible()
            }
        })
        present(alert, animated: true)
    }

    func showShimmerAnimation() {
        let gradient = makeAvatarGradient()
        avatarImageView.layer.addSublayer(gradient)
        animationLayers.insert(gradient)
    }

    func stopShimmerAnimation() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }

    private func makeAvatarGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 35
        gradient.masksToBounds = true

        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        gradient.add(animation, forKey: "locationsChange")

        return gradient
    }
}
