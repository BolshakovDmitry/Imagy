import Foundation

final class ProfileImageService{
    
    static let shared = ProfileImageService()
    private init(){}
    
    
    private(set) var avatarUrl: String?
    private let networkClient = NetworkClient()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(token: String){
        
        guard let request = makeRequestWithToken(with: token) else { return }
        
        networkClient.fetch(UserImage.self, urlrequest: request, handler: { [weak self] result in
            switch result {
            case .success(let data):
                let profileImageURL = data.profileImage.large
                self?.avatarUrl = profileImageURL
                // Отправляем уведомление
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL]
                )
            case .failure(let error):
                error.log(serviceName: "ProfileImageService", error: error, additionalInfo: self?.avatarUrl)
            }
        }
        )
    }
    
    private func makeRequestWithToken(with token: String) -> URLRequest? {
        guard let baseURL = URL(string: Constants.profileURLString) else {
            return nil
        }
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("URL: \(request.url?.absoluteString ?? "failed to build URL from makeRequestWithToken method in ProfileImageService")")
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        } else {
            print("No headers found")
        }
        
        return request
    }
}
