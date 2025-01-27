
import Foundation

final class Storage {
    
    private var userDefaults = UserDefaults.standard
    private enum Keys: String {
        case token
    }
    
    var token: String? {
        get {
            return userDefaults.string(forKey: Keys.token.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.token.rawValue)
        }
    }
    
    func store(with token: String?) {
        self.token = token
    }
    
    func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: Keys.token.rawValue)
    }
}






