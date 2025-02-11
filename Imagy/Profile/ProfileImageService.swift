
import Foundation

final class ProfileImageService{
    
    static let shared = ProfileImageService()
    private init(){}
    
    private (set) var avatarURL: String?
    private let networkClient = NetworkClient()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(token: String, _ completion: @escaping (Result<String, Error>) -> Void){
        
        guard let request = makeRequestWithToken(with: token) else { return }
    
        networkClient.fetch(UserImage.self, urlrequest: request, handler: { result in
            
                    switch result {
                    case .success(let data):
                        do {
                            self.avatarURL = data.profileImage.small
                            completion(.success(self.avatarURL ?? ""))
                            
                            NotificationCenter.default                                     // 1
                                .post(                                                     // 2
                                    name: ProfileImageService.didChangeNotification,       // 3
                                    object: self,                                          // 4
                                    userInfo: ["URL": self.avatarURL])
                        }
                    case .failure(let error):
                        error.log(serviceName: "ProfileImageService", error: error, additionalInfo: self.avatarURL)
                    
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
