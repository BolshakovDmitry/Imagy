import UIKit
import WebKit
@preconcurrency import Kingfisher


public protocol ProfileViewPresenterProtocol: AnyObject {
    var controller: ProfileViewControllerProtocol? { get set }
    func logout()
    func updateAvatar()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var controller: ProfileViewControllerProtocol?
    private let storage = Storage.shared
 
    func logout() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
        ProfileService.shared.cleanProfile()
        ProfileImageService.shared.clean()
        ImagesListService.shared.clean()
        storage.clear()
    }
    
    func updateAvatar() {
            guard let profileImageURL = ProfileImageService.shared.avatarUrl else { return }
            
            if let url = URL(string: profileImageURL) {
                KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                    guard let self = self else { return } // Слабая ссылка на self
                    switch result { 
                    case .success(let imageResult):
                        let imageSize = imageResult.image.size
                        let cornerRadius = imageSize.width * 0.5 // 50% от ширины изображения
                        
                        let processor = RoundCornerImageProcessor(cornerRadius: cornerRadius)
                            self.controller?.didReceiveProfileImageURL(with: url, processor: processor)
                    case .failure(let error):
                        print("Ошибка загрузки изображения: \(error.localizedDescription)")
                    }
                }
            }
        }
}
