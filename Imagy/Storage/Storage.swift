import Foundation
import SwiftKeychainWrapper

final class Storage {
    
    static let shared = Storage()
    private init(){}
    
    enum Keys: String {
        case authToken = "Auth token"
    }
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: Keys.authToken.rawValue)
        }
        set {
            guard let newValue = newValue else {
                clear()
                return
            }
            let isSuccess = KeychainWrapper.standard.set(newValue, forKey: Keys.authToken.rawValue)
            guard isSuccess else {
                print("Failed to store the token")
                return
            }
        }
    }
    
    func store(with token: String?) {
        self.token = token
    }
    
    func clear() {
        KeychainWrapper.standard.removeObject(forKey: Keys.authToken.rawValue)
    }
}






