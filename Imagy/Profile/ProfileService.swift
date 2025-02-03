
import Foundation

final class ProfileService{
    
    static let shared = ProfileService()
    private init(){}
        
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
    
        networkClient.fetch(urlrequest: request, handler: { result in
            
                    switch result {
                    case .success(let data):
                        do {
                            let decodedData = try JSONDecoder().decode(ProfileResult.self, from: data)
                            let profile = Profile(username: decodedData.userName, firstName: decodedData.firstName, lastName: decodedData.lastName, bio: decodedData.bio)
                            completion(.success(profile))
                        } catch {
                            print("Ошибка декодирования: $error)")
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        print("Ошибка : $error)")
                        print(error.localizedDescription)
                    
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
    
    

