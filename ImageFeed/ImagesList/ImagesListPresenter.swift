import Foundation
import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?

    private var photos: [Photo] = []
    
    #if DEBUG
    func _setPhotos(_ newPhotos: [Photo]) {
        self.photos = newPhotos
    }
    #endif
    
    private let imageListService = ImagesListService.shared
    private var isLoading = false

    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        photos = imageListService.photos
    }

    func viewDidLayoutSubviews() {
        guard !isLoading else { return }
        isLoading = true
        imageListService.fetchPhotosNextPage()
    }

    @objc private func updateTableViewAnimated(notification: Notification) {
        let newPhotos = imageListService.photos
        let oldCount = photos.count
        photos = newPhotos
        let newCount = photos.count

        if newCount > oldCount {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            view?.insertRows(at: indexPaths)
        } else {
            view?.reloadTable()
        }

        if let index = notification.userInfo?["index"] as? Int, index < photos.count {
            view?.reloadRows(at: [IndexPath(row: index, section: 0)])
        }

        isLoading = false
    }

    func numberOfPhotos() -> Int {
        photos.count
    }

    func photo(at index: Int) -> Photo? {
        guard photos.indices.contains(index) else { return nil }
        return photos[index]
    }

    func heightForRow(at index: Int, tableViewWidth: CGFloat) -> CGFloat {
        guard let photo = photo(at: index) else { return 0 }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }

    func didSelectRow(at index: Int) {
        // do nothing
    }

    func willDisplayCell(at index: Int) {
        if index == photos.count - 1 {
            imageListService.fetchPhotosNextPage()
        }
    }

    func toggleLike(at index: Int, completion: @escaping (Bool) -> Void) {
        guard photos.indices.contains(index) else {
            completion(false)
            return
        }

        let photo = photos[index]
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    func formattedDate(for photo: Photo) -> String {
        guard let date = photo.createdAt else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}
