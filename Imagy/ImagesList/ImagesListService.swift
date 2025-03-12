import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    private init(){}
    
    var photos: [Photo] = []
    static let ImagesListServiceDidChange = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var lastLoadedPage = 0
    private var networkClient = NetworkClient()
    private var storage = Storage.shared
    
    func fetchPhotosNextPage(token: String) {
        
        DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
        }
        let nextPage = lastLoadedPage + 1
        
        // Создаем запрос
        guard let request = makeRequestWithToken(with: token, with: String(nextPage), with: Constants.numberOfPicturesPerPage) else {
            print("Failed to create request")
            return
        }
        
        // Выполняем запрос
        networkClient.fetch([PhotoResult].self, urlrequest: request) { [weak self] result in
            // Разворачиваем self
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    let newPhotos = data.map { photoResult in
                        Photo(
                            id: photoResult.id,
                            size: CGSize(width: photoResult.width, height: photoResult.height),
                            createdAt: photoResult.createdAt,
                            welcomeDescription: photoResult.welcomeDescription,
                            thumbImageURL: photoResult.urls.thumbImageURL,
                            largeImageURL: photoResult.urls.largeImageURL,
                            isLiked: photoResult.isLiked
                        )
                    }
                    
                    // Обновляем данные
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    // Отправляем уведомление
                    NotificationCenter.default.post(
                        name: ImagesListService.ImagesListServiceDidChange,
                        object: self
                    )
                }
                
            case .failure(let error):
                error.log(serviceName: "ImagesListService", error: error, additionalInfo: error.localizedDescription)
            }
        }
    }
    
    func clean() {
        photos.removeAll()
        lastLoadedPage = 0
    }
    
    private func makeRequestWithToken(with token: String, with nextPage: String, with perPage: String) -> URLRequest? {
        guard var components = URLComponents(string: Constants.photosURL) else { return nil }
        
        let queryItems = [
            URLQueryItem(name: "page", value: nextPage),
            URLQueryItem(name: "per_page", value: perPage)
        ]
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("Failed to create URL from components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}

struct EmptyResponse: Decodable {} // Пустой структурный тип для пустых ответов

extension ImagesListService {
    
    enum ImagesListServiceError: Error {
        case invalidToken
        case invalidRequest
        case searchPhotoError
    }
    
    func changeLike(photoID: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread, "This code must be executed on the main thread")
        
        guard let token = storage.token else {
            completion(.failure(ImagesListServiceError.invalidToken))
            return
        }
        
        // Создаем запрос
        guard let request = makeLikeRequestWithToken(with: token, for: photoID, set: isLike) else {
            completion(.failure(ImagesListServiceError.invalidRequest))
            return
        }
        
        
        networkClient.fetch(EmptyResponse.self, urlrequest: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                guard let index = self.photos.firstIndex(where: { $0.id == photoID }) else {
                    completion(.failure(ImagesListServiceError.searchPhotoError))
                    return
                }
                // Получаем старую фотографию и инвертируем лайк
                let oldPhoto = self.photos[index]
                let newPhoto = self.invertLike(in: oldPhoto)
                
                // Обновляем фотографию в массиве
                self.photos[index] = newPhoto
                completion(.success(Void()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func makeLikeRequestWithToken(with token: String, for photoID: String, set isLike: Bool) -> URLRequest? {
        // Создаем базовый URL из Constants.photosURL
        guard var components = URLComponents(string: Constants.photosURL) else { return nil }
        
        // Добавляем путь для лайка
        components.path = "/photos/\(photoID)/like"
        
        // Создаем URL
        guard let url = components.url else {
            print("Failed to create URL from components")
            return nil
        }
        var request = URLRequest(url: url)
        
        // Устанавливаем метод HTTP (POST для лайка, DELETE для дизлайка)
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        // Устанавливаем заголовок авторизации
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func invertLike(in photo: Photo) -> Photo {
        Photo (
            id: photo.id,
            size: photo.size,
            createdAt: photo.createdAt,
            welcomeDescription: photo.welcomeDescription,
            thumbImageURL: photo.thumbImageURL,
            largeImageURL: photo.largeImageURL,
            isLiked: !photo.isLiked
        )
    }
}
