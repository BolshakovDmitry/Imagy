import Foundation
import UIKit

func fetchPhotosNextPage() {
     assert(Thread.isMainThread)
     guard task == nil else { return }
     
     let nextPage = (lastLoadedPage ?? 0) + 1
         
     guard
         let request = makePhotosNextPageURLRequest(nextPage)
     else {
         let error = NetworkError.invalidRequest
         error.log(object: self)
         return
     }
     
     let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], any Error>) in
         guard let self else { return }
         
         switch result {
         case .success(let photoResult):
             do {
                 let photos = try photoResult.map { try Photo(from: $0) }
                 let newPhotos = photos.filter { photo in
                     !self.photos.contains(where: { $0.id == photo.id })
                 }
                 self.photos.append(contentsOf: newPhotos)
                 self.lastLoadedPage = nextPage
                 NotificationCenter.default
                     .post(
                         name: ImagesListService.didChangeNotification,
                         object: self
                     )
             } catch {
                 self.notifyPhotoLoadingError(error)
             }
         case .failure(let error):
             self.notifyPhotoLoadingError(error)
         }
         
         self.task = nil
     }
     self.task = task
     task.resume()
 }
