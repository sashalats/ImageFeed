import Foundation

enum OAuth2Error: Error {
    case invalidRequest
    case cancelledByAnotherRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let decoder = JSONDecoder()
    
    private var currentTask: URLSessionTask?
    private var currentCode: String?
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: Constants.unsplashTokenURLString)
        else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        
        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let currentCode = currentCode {
            if currentCode == code {
                currentTask?.cancel()
                print("[OAuth2Service]: Отменен предыдущий запрос с тем же кодом")
            } else {
                print("[OAuth2Service]: Запрос с другим кодом уже выполняется. Прерывание.")
                completion(.failure(OAuth2Error.cancelledByAnotherRequest))
                return
            }
        }
        self.currentCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service]: Invalid request - не удалось создать URLRequest")
            completion(.failure(OAuth2Error.invalidRequest))
            currentTask = nil
            currentCode = nil
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            defer {
                self.currentTask = nil
                self.currentCode = nil
            }
            
            switch result {
            case .success(let response):
                self.oauth2TokenStorage.token = response.accessToken
                completion(.success(response.accessToken))
            case .failure(let error):
                print("[OAuth2Service]: Failure - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        self.currentTask = task
        task.resume()
    }
}
