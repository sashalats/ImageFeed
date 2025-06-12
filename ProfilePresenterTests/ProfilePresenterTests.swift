@testable import ImageFeed
import XCTest

final class ProfilePresenterTests: XCTestCase {
    final class ProfileViewSpy: ProfileViewProtocol {
        var didUpdateProfile = false
        var didUpdateAvatarURL: URL?
        var didShowLogoutAlert = false
        var didStartShimmer = false
        var didStopShimmer = false

        func updateProfileDetails(profile: Profile) {
            didUpdateProfile = true
        }

        func updateAvatar(url: URL?) {
            didUpdateAvatarURL = url
        }

        func showLogoutAlert() {
            didShowLogoutAlert = true
        }

        func showShimmerAnimation() {
            didStartShimmer = true
        }

        func stopShimmerAnimation() {
            didStopShimmer = true
        }
    }

    func testViewDidLoad_PerformsInitialSetup() {
        let view = ProfileViewSpy()
        let presenter = ProfilePresenter()
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertTrue(view.didStartShimmer)
        XCTAssertTrue(view.didUpdateProfile)
        XCTAssertNotNil(view.didUpdateAvatarURL)
    }

    func testDidTapLogout_ShowsLogoutAlert() {
        let view = ProfileViewSpy()
        let presenter = ProfilePresenter()
        presenter.view = view

        presenter.didTapLogout()

        XCTAssertTrue(view.didShowLogoutAlert)
    }

    func testDidReceiveAvatarUpdate_UpdatesAvatar() {
        let view = ProfileViewSpy()
        let presenter = ProfilePresenter()
        presenter.view = view

        presenter.didReceiveAvatarUpdate()

        XCTAssertNotNil(view.didUpdateAvatarURL)
    }
}
