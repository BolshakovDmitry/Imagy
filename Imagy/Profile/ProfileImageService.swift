
import Foundation

final class ProfileImageService{
    
    private (set) var avatarURL: String?
    private let networkClient = NetworkClient()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    
    static let shared = ProfileImageService()
    private init(){}
 
    func fetchProfileImageURL(token: String, _ completion: @escaping (Result<String, Error>) -> Void){
        
        guard let request = makeRequestWithToken(with: token) else { return }
    
        networkClient.fetch(urlrequest: request, handler: { result in
            
                    switch result {
                    case .success(let data):
                        do {
                            let decodedData = try JSONDecoder().decode(UserImage.self, from: data)
                            let avatarURL = decodedData.profileImage.small
                            self.avatarURL = avatarURL
                            completion(.success(avatarURL))
                            
                            NotificationCenter.default                                     // 1
                                .post(                                                     // 2
                                    name: ProfileImageService.didChangeNotification,       // 3
                                    object: self,                                          // 4
                                    userInfo: ["URL": avatarURL])
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
