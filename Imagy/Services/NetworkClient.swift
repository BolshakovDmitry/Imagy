import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case noData
    case decodeError
}

enum AuthServiceError: Error {
    case invalidRequest
    case repeatedCode
}

final class NetworkClient{
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetch<T: Decodable>(_ type: T.Type, urlrequest: URLRequest, requiresCodeCheck: Bool? = nil, handler: @escaping (Result<T, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        if requiresCodeCheck != nil{
            guard let code = urlrequest.extractCode() else {
                handler(.failure(AuthServiceError.invalidRequest))
                return
            }
            
            guard lastCode != code else {
                handler(.failure(AuthServiceError.repeatedCode))
                return
            }
            
            task?.cancel()
            lastCode = code
        }
        
        guard task == nil else { return } // если уже выполняется запрос - то выходим
        
        let task = URLSession.shared.dataTask(with: urlrequest) { [weak self] data, response, error in
            
            
            if let error = error {
                error.log(serviceName: "NetworkClient", error: error, additionalInfo: "NetworkError.urlRequestError")  // логирование ошибок
                handler(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                let error = NetworkError.httpStatusCode(response.statusCode)
                error.log(serviceName: "NetworkClient", error: error, additionalInfo: "NetworkError.httpStatusCodeError")
                handler(.failure(NetworkError.httpStatusCode(response.statusCode)))
                guard let data else { return }
                print(String(data: data, encoding: .utf8) as Any)
                return
            }
            
            
            guard let data = data else {
                let error = NetworkError.noData
                error.log(serviceName: "NetworkClient", error: error, additionalInfo: "NetworkError.noData")
                handler(.failure(NetworkError.noData))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601 // Указываем формат даты
                let decodedData = try decoder.decode(T.self, from: data)
                handler(.success(decodedData))
            } catch {
                let error = NetworkError.decodeError
                error.log(serviceName: "NetworkClient", error: error, additionalInfo: "NetworkError.decodeError")
                handler(.failure(NetworkError.decodeError))
            }
            
            self?.task = nil
            self?.lastCode = nil
        }
        self.task = task
        task.resume()
    }
}

extension URLRequest {
    func extractCode() -> String? {
        guard let url = self.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        return queryItems.first(where: { $0.name == "code" })?.value
    }
}
