@testable import Imagy
import XCTest
import Kingfisher
import UIKit

import XCTest
@testable import Imagy

final class ImagesListPresenterSpy: ImagesListViewPresenterProtocol {
    weak var controller: ImagesListViewControllerProtocol?
    
    var photoCountAtStart = 0
    var isDidGetPhotosCalled = false
    var isLoadImageForSingleImageVCCalled = false
    var isChangeLikeOnPhotoCalled = false
    
    func didGetPhotos() {
        isDidGetPhotosCalled = true
        photoCountAtStart = ImagesListService.shared.photos.count
    }
    
    func loadImageForSingleImageVC(for photo: Photo, at indexPath: IndexPath, in viewController: UIViewController, handler: @escaping (Result<UIImage, Error>) -> Void) {
        isLoadImageForSingleImageVCCalled = true
    }
    
    func changeLikeOnPhoto(for cell: UITableViewCell?, with indexPath: IndexPath, handler: @escaping (Result<Data, Error>) -> Void) {
        isChangeLikeOnPhotoCalled = true
    }
}


final class ImagesListViewControllerTests: XCTestCase {
    
    func testViewDidLoadCallsDidGetPhotos() {
        // Given
        let presenterSpy = ImagesListPresenterSpy()
        let imagesListViewController = ImagesListViewController()
        imagesListViewController.configure(presenter: presenterSpy)
        
        
        // When
        imagesListViewController.subscribeToPhotosUpdateTESTS()
        
        // Then
        XCTAssertTrue(presenterSpy.isDidGetPhotosCalled)
    }
}


final class ImagesListPresenterTests: XCTestCase {
    
    var presenter: ImagesListPresenter!
    var imagesListServiceMock: ImagesListServiceMock!
    var controllerMock: ImagesListViewControllerProtocolMock!
    
    override func setUp() {
        super.setUp()
        imagesListServiceMock = ImagesListServiceMock()
        controllerMock = ImagesListViewControllerProtocolMock()
        presenter = ImagesListPresenter()
        presenter.controller = controllerMock
        presenter.imagesListServiceMock = imagesListServiceMock
    }
    
    override func tearDown() {
        presenter = nil
        imagesListServiceMock = nil
        controllerMock = nil
        super.tearDown()
    }
    
    func testChangeLikeOnPhotoSuccess() {
        // Given
        let photo = Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            isLiked: false
        )
        presenter.photos = [photo]
        let cell = ImagesListCell()
        let indexPath = IndexPath(row: 0, section: 0)
        imagesListServiceMock.changeLikeResult = .success(())
        
        // When
        presenter.changeLikeOnPhoto(for: cell, with: indexPath) { result in
            // Then
            switch result {
            case .success:
                XCTAssertTrue(self.imagesListServiceMock.changeLikeCalled)
                XCTAssertTrue(cell.isLiked)
            case .failure:
                XCTFail("Expected success, but got failure")
            }
        }
    }
    
    func testChangeLikeOnPhotoFailure() {
        // Given
        let photo = Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            isLiked: false
        )
        presenter.photos = [photo]
        let cell = ImagesListCell()
        let indexPath = IndexPath(row: 0, section: 0)
        imagesListServiceMock.changeLikeResult = .failure(NSError(domain: "TestError", code: -1, userInfo: nil))
        
        // When
        presenter.changeLikeOnPhoto(for: cell, with: indexPath) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertTrue(self.imagesListServiceMock.changeLikeCalled)
                XCTAssertEqual((error as NSError).code, -1)
            }
        }
    }
}

// MARK: - Mocks

final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    
    var changeLikeCalled = false
    var changeLikeResult: Result<Void, Error> = .success(())
    
    func changeLike(photoID: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(changeLikeResult)
    }
}

final class ImagesListViewControllerProtocolMock: ImagesListViewControllerProtocol {
    var presenter: ImagesListViewPresenterProtocol = ImagesListPresenterSpy()
    
    func updateTableViewAnimated(indexes: Range<Int>, photos: [Photo]) {}
    func configure(presenter: ImagesListViewPresenterProtocol) {}
    func subscribeToPhotosUpdateTESTS() {}
    func imageListCellDidTapLike(_ cell: UITableViewCell?) {}
}

final class ImagesListCell: UITableViewCell {
    var isLiked: Bool = false
    
    func setIsLiked(_ isLiked: Bool) {
        self.isLiked = isLiked
    }
}

