import Foundation

final class ProfilePresenter {
    weak var view: ProfileViewProtocol?
    private let profileService = ProfileService.shared
    private let imageService = ProfileImageService.shared
    
    private var avatarObserver: NSObjectProtocol?
    
    deinit {
        if let observer = avatarObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

extension ProfilePresenter: ProfilePresenterProtocol {
    func viewDidLoad() {
        view?.showShimmerAnimation()
        
        if let profile = profileService.profile {
            view?.updateProfileDetails(profile: profile)
        }
        
        if let avatar = imageService.avatarURL,
           let url = URL(string: avatar) {
            view?.updateAvatar(url: url)
        }
        
        avatarObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.didReceiveAvatarUpdate()
        }
    }
    
    func didTapLogout() {
        view?.showLogoutAlert()
    }
    
    func didReceiveAvatarUpdate() {
        guard let avatar = imageService.avatarURL,
              let url = URL(string: avatar)
        else {
            view?.updateAvatar(url: nil)
            return
        }
        view?.updateAvatar(url: url)
    }
}
