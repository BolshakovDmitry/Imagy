import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    private init(){}
    
    var photos: [Photo] = []
    static let ImagesListServiceDidChange = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var lastLoadePage = 0
    private var networkClient = NetworkClient()
    private var storage = Storage()

    
    func fetchPhotosNextPage(token: String) {
        let nextPage = lastLoadePage + 1
        
        // Создаем запрос
        guard let request = makeRequestWithToken(with: token, with: String(nextPage), with: Constants.numberOfPicturesPerPage) else {
            print("Failed to create request")
            return
        }
        
        // Выполняем запрос
        networkClient.fetch([PhotoResult].self, urlrequest: request) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    // Преобразуем массив PhotoResult в массив Photo
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
                    self?.photos.append(contentsOf: newPhotos)
                    self?.lastLoadePage = nextPage
                    
                    // Отправляем уведомление
                    NotificationCenter.default.post(
                        name: ImagesListService.ImagesListServiceDidChange,
                        object: self
                    )
                }
                
            case .failure(let error):
                // Логируем ошибку
                error.log(serviceName: "ImagesListService", error: error, additionalInfo: error.localizedDescription)
            }
        }
    }
    
    func clean() {
        photos.removeAll()
        lastLoadePage = 0
        //task = nil
        //likeTask = nil
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
        
//        print("URL: \(request.url?.absoluteString ?? "failed to build URL from makeRequestWithToken method in ImagesListService")")
//        if let headers = request.allHTTPHeaderFields {
//            print("Headers: \(headers)")
//        } else {
//            print("No headers found")
//        }
        
        return request
    }
}

struct EmptyResponse: Decodable {} // Пустой структурный тип для пустых ответов

extension ImagesListService {
    
    
    
    func changeLike(photoID: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread, "This code must be executed on the main thread")
        
        guard let token = storage.token else {
            return
        }
        guard let request = makeLikeRequestWithToken(with: token, for: photoID, set: isLike) else { return }
        
        
        // Выполняем запрос
        networkClient.fetch(EmptyResponse.self, urlrequest: request) { [weak self] result in
            switch result {
            case .success(_):
                guard let index = self?.photos.firstIndex(where: { $0.id == photoID }) else {
                    return
                }
                guard let oldPhoto = self?.photos[index] else { return }
                guard let newPhoto = self?.invertLike(in: oldPhoto) else { return }
                self?.photos[index] = newPhoto
                
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
        
        // Создаем запрос
        var request = URLRequest(url: url)
        
        // Устанавливаем метод HTTP (POST для лайка, DELETE для дизлайка)
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        // Устанавливаем заголовок авторизации
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func invertLike(in photo: Photo) -> Photo {
        return Photo (
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
