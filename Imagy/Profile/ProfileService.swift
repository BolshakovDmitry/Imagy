
import Foundation

final class ProfileService{
    
    static let shared = ProfileService()
    private init(){}
    
    private(set) var profile: Profile?
        
    enum AuthServiceError: Error {
        case invalidRequest
    }
    
    private let networkClient = NetworkClient()
    private let storage = Storage()
    private lazy var bearerToken = storage.token
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void){
        
        guard let request = makeRequestWithToken(with: token) else { return }
    
        networkClient.fetch(ProfileResult.self, urlrequest: request, handler: { result in
            
                    switch result {
                    case .success(let data):

                            let decodedprofile = Profile(username: data.userName, firstName: data.firstName, lastName: data.lastName, bio: data.bio)
                            self.profile = decodedprofile
                            completion(.success(decodedprofile))
        
                    case .failure(let error):
                        error.log(serviceName: "ProfileService", error: error, additionalInfo: "code: \(String(describing: self.profile))")
                    
                }
            })
        }
         
    private func makeRequestWithToken(with token: String) -> URLRequest? {
        // Создаем URL для эндпоинта /me
        guard let baseURL = URL(string: "https://api.unsplash.com/me") else {
            return nil // Возвращаем nil вместо fatalError
        }
        
        // Создаем запрос
        var request = URLRequest(url: baseURL)
        
        // Устанавливаем метод GET (явно, для ясности)
        request.httpMethod = "GET"
        
        // Добавляем Bearer Token в заголовок Authorization
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Отладочный вывод URL и заголовков
        print("URL: \(request.url?.absoluteString ?? "Invalid URL")")
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        } else {
            print("No headers found")
        }
        
        return request
    }
    
    
    
    
    }
    
    

