import Foundation

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let welcomeDescription: String?
    let isLiked: Bool
    let urls: UrlsResult
    
    struct UrlsResult: Codable {
        let largeImageURL: String
        let thumbImageURL: String
   
        private enum CodingKeys: String, CodingKey {
            case largeImageURL = "full"
            case thumbImageURL = "thumb"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case width = "width"
        case height = "height"
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case isLiked = "liked_by_user"
        case urls = "urls"
    }
}
