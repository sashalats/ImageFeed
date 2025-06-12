import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesList else {
            assertionFailure("Не удалось инициализировать ImagesListViewController")
            return
        }
        let imagesListPresenter = ImagesListPresenter()
        imagesListPresenter.view = imagesListViewController
        imagesListViewController.presenter = imagesListPresenter

        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profilePresenter.view = profileViewController
        profileViewController.presenter = profilePresenter

        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
