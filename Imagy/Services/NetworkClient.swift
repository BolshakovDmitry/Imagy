
import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

struct NetworkClient: NetworkRouting {
    
    func fetch(urlrequest: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
       
       let task = URLSession.shared.dataTask(with: urlrequest) { data, response, error in
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
        }
        
        task.resume()
    }
}
