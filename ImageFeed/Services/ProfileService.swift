
import UIKit

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    let email: String?

    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
        case email
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from result: ProfileResult) {
        self.username = result.username
        let first = result.firstName ?? ""
        let last = result.lastName ?? ""
        self.name = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        self.loginName = "@\(result.username)"
        self.bio = result.bio
    }
}

final class ProfileService {
    private var currentTask: URLSessionTask?
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile?
}

extension ProfileService {
    private func makeProfileRequest() -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me"),
              let token = oauth2TokenStorage.token else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    public func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void){
        currentTask?.cancel()
        guard let request = makeProfileRequest(),
              let token = oauth2TokenStorage.token else {
            print("[ProfileService]: Invalid request - токен или URL невалидны")
            completion(.failure(NSError(domain: "ProfileService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            defer { self.currentTask = nil }

            switch result {
            case .success(let profileResult):
                let profile = Profile(from: profileResult)
                self.profile = profile
                completion(.success(profile))

                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { result in
                    switch result {
                    case .success(let url):
                        print("[ProfileService]: Получен URL аватара — \(url)")
                    case .failure(let error):
                        print("[ProfileService]: Ошибка при получении URL аватара — \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("[ProfileService]: Failure - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        currentTask = task
        task.resume()
    }
}
