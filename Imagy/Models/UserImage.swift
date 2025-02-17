import Foundation

struct UserImage: Codable {
    let profileImage: ProfileImage
    
    struct ProfileImage: Codable {
        let large: String
   
        private enum CodingKeys: String, CodingKey {
            case large = "large"

        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
