import UIKit

final class ProfileViewController: UIViewController {
    
    private var label: UILabel?
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let statusLabel = UILabel()
    private let logoutButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.ypBlack
        
        setupAvatar()
        setupNameLabel()
        setupUsernameLabel()
        setupStatusLabel()
        setupLogoutButton()
    }
    
    private func setupAvatar() {
        let avatarImage = UIImage(named: "Avatar") ?? UIImage(systemName: "person.crop.circle.fill")!
        avatarImageView.image = avatarImage
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
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .ypWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupUsernameLabel() {
        usernameLabel.text = "@ekaterina_nov"
        usernameLabel.font = UIFont.systemFont(ofSize: 13)
        usernameLabel.textColor = .ypGray
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupStatusLabel() {
        statusLabel.text = "Hello, world"
        statusLabel.font = UIFont.systemFont(ofSize: 13)
        statusLabel.textColor = .ypWhite
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        //self.label = statusLabel
    }
    
    private func setupLogoutButton() {
        let buttonImage = UIImage(named: "Logout")
        logoutButton.setImage(buttonImage, for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc
    private func didTapButton() {
        label?.removeFromSuperview()
        label = nil
    }
}
