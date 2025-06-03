import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            switch (data, response, error) {
            case let (data?, response as HTTPURLResponse, _) where 200..<300 ~= response.statusCode:
                fulfillCompletionOnTheMainThread(.success(data))
            case let (_, response as HTTPURLResponse, _):
                print("Ошибка от Unsplash: HTTP статус \(response.statusCode)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(response.statusCode)))
            case let (_, _, error?):
                print("Ошибка при запросе:", error)
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            default:
                print("Ошибка: ни data, ни error не получено")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
}
