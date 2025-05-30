import Foundation

enum OAuth2Error: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let decoder = JSONDecoder()
    
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
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Ошибка создания URLRequest")
            completion(.failure(OAuth2Error.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.oauth2TokenStorage.token = response.accessToken
                    completion(.success(response.accessToken))
                } catch {
                    print("Ошибка декодирования ответа: \(error)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("Сетевая ошибка: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
