import Foundation

enum Constants {
    static let accessKey = "GVckYgHxy-t1XuZJDJclVCPdMij6F0wLnZI5ppVzzl4"
    static let secretKey = "jZwZiaFXxNz06WdzQoJM-mZg8nv0HNu5qe3US0uiBVk"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Некорректный URL для API Unsplash")
        }
        return url
    }()
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashTokenURLString = "https://unsplash.com/oauth/token"
    static func userProfileURL(for username: String) -> URL? {
        guard !username.isEmpty else { return nil }
        return defaultBaseURL.appendingPathComponent("users").appendingPathComponent(username)
    }
    static func likeImage(for photoId: String) -> URL? {
        guard !photoId.isEmpty else { return nil }
        return defaultBaseURL.appendingPathComponent("photos").appendingPathComponent(photoId).appendingPathComponent("like")
    }
    static let unsplashURLPhotosString = "https://api.unsplash.com/photos"
    static let unsplashURLMeString = "https://api.unsplash.com/me"
}
