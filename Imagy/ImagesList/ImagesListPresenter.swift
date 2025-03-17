import UIKit
import Kingfisher

public protocol ImagesListViewPresenterProtocol: AnyObject {
    var controller: ImagesListViewControllerProtocol? { get set }
    func didGetPhotos()
    func loadImageForSingleImageVC(for photo: Photo, at indexPath: IndexPath, in viewController: UIViewController, handler: @escaping (Result<UIImage, Error>) -> Void)
    func changeLikeOnPhoto(for cell: UITableViewCell?, with indexPath: IndexPath, handler: @escaping (Result<Data, Error>) -> Void)
}


final class ImagesListPresenter: ImagesListViewPresenterProtocol {
    weak var controller: ImagesListViewControllerProtocol?
    var imagesListService = ImagesListService.shared
    var imagesListServiceMock: ImagesListServiceProtocol?
    var imagesListServiceForTests: ImagesListServiceProtocol?
    var photos: [Photo] = []
    
    func didGetPhotos() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        guard oldCount != newCount else { return }
        controller?.updateTableViewAnimated(indexes: oldCount..<newCount, photos: photos)
    }
    
    func loadImageForSingleImageVC(for photo: Photo, at indexPath: IndexPath, in viewController: UIViewController, handler: @escaping (Result<UIImage, Error>) -> Void) {
        let viewController = viewController as? SingleImageViewController
        if let imageURL = URL(string: photo.largeImageURL) {
            KingfisherManager.shared.retrieveImage(with: imageURL) { result in
                DispatchQueue.main.async {
                    viewController?.showLoadingSpinner()
                }
                switch result {
                case .success(let value):
                    // Передаем загруженное изображение на главном потоке
                    DispatchQueue.main.async {
                        viewController?.hideLoadingSpinner()
                        let image = value.image
                        handler(.success(image))
                    }
                case .failure(let error):
                    print("Failed to load image: \(error.localizedDescription)")
                    // Показываем алерт об ошибке
                    DispatchQueue.main.async {
                        viewController?.hideLoadingSpinner()
                        handler(.failure(error.localizedDescription as! Error))
                    }
                }
            }
        }
    }
    
    func changeLikeOnPhoto(for cell: UITableViewCell?, with indexPath: IndexPath, handler: @escaping (Result<Data, Error>) -> Void) {
        
        enum LikeError: Error {
            case failedToChangeLike
        }
        
        guard let cellImage = cell as? ImagesListCell else { return }
        let photo = photos[indexPath.row]
        // Покажем лоадер
        DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
        }
        imagesListService.changeLike(photoID: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async{
                    // Синхронизируем массив картинок с сервисом
                    self.photos = self.imagesListService.photos
                    // Изменим индикацию лайка картинки
                    cellImage.setIsLiked(self.photos[indexPath.row].isLiked)
                    // Уберём лоадер
                    UIBlockingProgressHUD.dismiss()
                }
            case .failure:
                // Уберём лоадер
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                }
                handler(.failure(LikeError.failedToChangeLike))
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
