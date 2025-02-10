
import Foundation
import SwiftKeychainWrapper

final class Storage {
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: "Auth token")
        }
        set {
            let token = "<Token пользователя>"
            let isSuccess = KeychainWrapper.standard.set(token, forKey: "Auth token")
            guard isSuccess else {
                print("failed to store the token")
                return
            }
        }
    }
    
    func store(with token: String?) {
        self.token = token
    }
    func clear() {
         // Очищаем Keychain
         KeychainWrapper.standard.removeObject(forKey: "Auth token")
     }

}






