import Foundation

protocol ProfileViewProtocol: AnyObject {
    func updateProfileDetails(profile: Profile)
    func updateAvatar(url: URL?)
    func showLogoutAlert()
    func showShimmerAnimation()
    func stopShimmerAnimation()
}
