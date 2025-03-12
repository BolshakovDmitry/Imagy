import SwiftKeychainWrapper
import Foundation

final class OAuth2Service{
    
    static let shared = OAuth2Service()
    private init(){}
    
    private let networkClient = NetworkClient()
    private let storage = Storage.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    enum AuthServiceError: Error {
        case invalidRequest
    }
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        
        guard let request = makeOAuthTokenRequest(code: code)
        else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        networkClient.fetch(OAuthTokenResponseBody.self, urlrequest: request, requiresCodeCheck: true, handler: { [weak self] result in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    self.storage.store(with: data.accessToken)
                    handler(.success("Success"))
                    
                case .failure(let error):
                    error.log(serviceName: "OAuth2Service", error: error, additionalInfo: "code: \(code)")
                }
            }
        })
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var components = URLComponents(string: "https://unsplash.com/oauth/token") else { fatalError("Failed to create base URL") }
        let queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        components.queryItems = queryItems
        guard let url = components.url else {  assertionFailure("Failed to create URL")
            return nil  }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
