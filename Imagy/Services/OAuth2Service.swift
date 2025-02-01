
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
        guard var components = URLComponents(string: "https://unsplash.com/oauth/token") else { fatalError("Failed to create base URL") }
        let queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        components.queryItems = queryItems
        guard let url = components.url else { fatalError("Failed to create final URL") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
