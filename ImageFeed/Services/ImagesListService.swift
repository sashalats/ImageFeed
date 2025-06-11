import UIKit

final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    static let shared = ImagesListService()
    private init() {}
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    private static let dateFormatter: ISO8601DateFormatter = {
        ISO8601DateFormatter()
    }()
    
    func updatePhoto(at index: Int, with photo: Photo) {
        guard photos.indices.contains(index) else { return }
        photos[index] = photo
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
    }
    
    func fetchPhotosNextPage() {
        guard currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let token = oauth2TokenStorage.token else {
            print("[ImagesListService] - Токен не найден")
            return
        }
        print("[ImagesListService] - Токен \(token)")
        var urlComponents = URLComponents(string: Constants.unsplashURLPhotosString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(nextPage)),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        currentTask = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            defer { self.currentTask = nil }
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map {
                    Photo(
                        id: $0.id,
                        size: CGSize(width: $0.width, height: $0.height),
                        createdAt: ImagesListService.dateFormatter.date(from: $0.createdAt ?? ""),
                        welcomeDescription: $0.description,
                        thumbImageURL: $0.urls.thumb,
                        largeImageURL: $0.urls.full,
                        isLiked: $0.likedByUser
                    )
                }
                
                let existingIds = Set(self.photos.map { $0.id })
                let uniqueNewPhotos = newPhotos.filter { !existingIds.contains($0.id) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: uniqueNewPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
                print("[ImagesListService] - Данные получены")
            case .failure(let error):
                print("[ImagesListService] - Ошибка загрузки фото: \(error.localizedDescription)")
            }
        }
        currentTask?.resume()
    }
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = oauth2TokenStorage.token else {
            completion(.failure(NSError(domain: "ImagesListService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No token available"])))
            return
        }
        
        guard let url = Constants.likeImage(for: photoId) else {
            completion(.failure(NSError(domain: "ImagesListService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "ImagesListService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response"])))
                    return
                }
                
                if 200..<300 ~= httpResponse.statusCode {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: isLike
                        )
                        self.photos[index] = newPhoto
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["index": index]
                        )
                    }
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "ImagesListService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error \(httpResponse.statusCode)"])))
                }
            }
        }
        task.resume()
    }
}
