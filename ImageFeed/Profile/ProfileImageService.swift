import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    private var currentTask: URLSessionTask?
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private(set) var avatarURL: String?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard
            let token = oauth2TokenStorage.token,
            let url = Constants.userProfileURL(for: username)
        else {
            print("[ProfileImageService]: Invalid request - невалидный токен или URL")
            completion(.failure(NSError(domain: "ProfileImageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid token or URL"])))
            return
        }
        if currentTask?.originalRequest?.url != url {
            currentTask?.cancel()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            defer { self.currentTask = nil }
            
            switch result {
            case .success(let result):
                let urlString = result.profileImage.small
                self.avatarURL = urlString
                completion(.success(urlString))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": urlString])
            case .failure(let error):
                print("[ProfileImageService]: Failure - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        currentTask = task
        task.resume()
    }
}

