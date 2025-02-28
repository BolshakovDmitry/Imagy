import Foundation
// Обязательный импорт
import WebKit

final class ProfileLogoutService {
   static let shared = ProfileLogoutService()
    private let storage = Storage()
  
   private init() { }

   func logout() {
      cleanCookies()
       ProfileService.shared.cleanProfile()
       ProfileImageService.shared.clean()
       ImagesListService.shared.clean()
       storage.clear()
   }

   private func cleanCookies() {
      // Очищаем все куки из хранилища
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      // Запрашиваем все данные из локального хранилища
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         // Массив полученных записей удаляем из хранилища
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
   }
}
