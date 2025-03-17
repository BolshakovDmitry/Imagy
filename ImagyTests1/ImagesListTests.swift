@testable import Imagy
import XCTest
import Kingfisher

import XCTest
@testable import Imagy

final class ImagesListPresenterSpy: ImagesListViewPresenterProtocol {
    weak var controller: ImagesListViewControllerProtocol?
    
    var isDidGetPhotosCalled = false
    var isLoadImageForSingleImageVCCalled = false
    var isChangeLikeOnPhotoCalled = false
    
    func didGetPhotos() {
        isDidGetPhotosCalled = true
    }
    
    func loadImageForSingleImageVC(for photo: Photo, at indexPath: IndexPath, in viewController: UIViewController, handler: @escaping (Result<UIImage, Error>) -> Void) {
        isLoadImageForSingleImageVCCalled = true
    }
    
    func changeLikeOnPhoto(for cell: UITableViewCell?, with indexPath: IndexPath, handler: @escaping (Result<Data, Error>) -> Void) {
        isChangeLikeOnPhotoCalled = true
    }
}
final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListViewPresenterProtocol?
    
    var isUpdateTableViewAnimatedCalled = false
    var receivedIndexes: Range<Int>?
    var receivedPhotos: [Photo]?
    
    func updateTableViewAnimated(indexes: Range<Int>, photos: [Photo]) {
        isUpdateTableViewAnimatedCalled = true
        receivedIndexes = indexes
        receivedPhotos = photos
    }
}

final class ImagesListViewControllerTests: XCTestCase {
    
    func testViewDidLoadCallsDidGetPhotos() {
        // Given
        let presenterSpy = ImagesListPresenterSpy()
        let viewController = ImagesListViewController()
        viewController.presenter = presenterSpy
        
        // When
        _ = viewController.view // Имитируем вызов viewDidLoad
        
        // Then
        XCTAssertTrue(presenterSpy.isDidGetPhotosCalled)
    }
    
    func testUpdateTableViewAnimated() {
        // Given
        let viewController = ImagesListViewController()
        let indexes = 0..<5
        let photos = [
            Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "Test", thumbImageURL: "https://example.com/thumb.jpg", largeImageURL: "https://example.com/large.jpg", isLiked: false)
        ]
        
        // When
        viewController.updateTableViewAnimated(indexes: indexes, photos: photos)
        
        // Then
        XCTAssertEqual(viewController.photos.count, photos.count)
    }
    
    func testImageListCellDidTapLike() {
        // Given
        let presenterSpy = ImagesListPresenterSpy()
        let viewController = ImagesListViewController()
        viewController.presenter = presenterSpy
        
        let cell = UITableViewCell()
        let indexPath = IndexPath(row: 0, section: 0)
        
        // When
        viewController.imageListCellDidTapLike(cell)
        
        // Then
        XCTAssertTrue(presenterSpy.isChangeLikeOnPhotoCalled)
    }
}
