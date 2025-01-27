
import Foundation

final class OAuth2Service{
    
    static let shared = OAuth2Service()
    private init(){}
    
    private let networkClient = NetworkClient()
    private let storage = Storage()
    private var bearerToken = ""
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        
       let request = makeOAuthTokenRequest(code: code)
        
        networkClient.fetch(urlrequest: request, handler: { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    do {
                        let token = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                        self.bearerToken = token.accessToken
                        self.storage.store(with: self.bearerToken)
                        handler(.success("Success"))
                    } catch {
                        print("Ошибка декодирования: $error)")
                        handler(.failure(error))
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                } 
            }
        })
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest {
         let baseURL = URL(string: "https://unsplash.com")!
        guard let url = URL(
             string: "/oauth/token"
             + "?client_id=\(Constants.accessKey)"         // Используем знак ?, чтобы начать перечисление параметров запроса
             + "&&client_secret=\(Constants.secretKey)"    // Используем &&, чтобы добавить дополнительные параметры
             + "&&redirect_uri=\(Constants.redirectURI)"
             + "&&code=\(code)"
             + "&&grant_type=authorization_code",
             relativeTo: baseURL                           // Опираемся на основной или базовый URL, которые содержат схему и имя хоста
         ) else { fatalError("Could not create URL.") }
        
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         return request
     }
}
