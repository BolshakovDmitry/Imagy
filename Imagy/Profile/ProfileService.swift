import Foundation

final class ProfileService {
    
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile?
    
    private let networkClient = NetworkClient()
    private let storage = Storage()
    
    enum AuthServiceError: Error {
        case invalidRequest
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = makeRequestWithToken(with: token) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        networkClient.fetch(ProfileResult.self, urlrequest: request) { [weak self] result in
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.userName,
                    firstName: profileResult.firstName,
                    lastName: profileResult.lastName,
                    bio: profileResult.bio
                )
                self?.profile = profile
                completion(.success(profile))
                
            case .failure(let error):
                error.log(serviceName: "ProfileService", error: error, additionalInfo: "token: \(token)")
                completion(.failure(error))
            }
        }
    }
    
    private func makeRequestWithToken(with token: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://api.unsplash.com/me") else { return nil }
        
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Логирование запроса
        logRequest(request: request)
        
        return request
    }
    
    private func logRequest(request: URLRequest) {
        print("URL: \(request.url?.absoluteString ?? "Invalid URL")")
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        } else {
            print("No headers found")
        }
    }
}


