
import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

enum AuthServiceError: Error {
    case invalidRequest
}

class NetworkClient: NetworkRouting {
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetch(urlrequest: URLRequest, requiresCodeCheck: Bool? = nil, handler: @escaping (Result<Data, Error>) -> Void) {
        
        assert(Thread.isMainThread)                         // 4
        
        if let requiresCodeCheck{
            guard let code = urlrequest.extractCode() else {
                handler(.failure(AuthServiceError.invalidRequest))
                return
            }
            
            guard lastCode != code else {                               // 1
                handler(.failure(AuthServiceError.invalidRequest))
                return
            }
            
            task?.cancel()                                      // 2
            lastCode = code
        }
       
       let task = URLSession.shared.dataTask(with: urlrequest) { [weak self] data, response, error in
           
            // Проверяем, пришла ли ошибка
            if let error = error {
                handler(.failure(NetworkError.urlRequestError(error)))
                print("Fetch method error")
                return
            }
            
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.httpStatusCode(response.statusCode)))
                print(response.statusCode)
                guard let data else { return }
                print(String(data: data, encoding: .utf8) as Any)
                return
            }
            
            // Возвращаем данные
            guard let resultData = data else { return }
           
           handler(.success(resultData))
           
           self?.task = nil                            // 14
           self?.lastCode = nil
        }
        self.task = task                                // 15
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
