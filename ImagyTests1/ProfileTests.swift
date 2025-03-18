@testable import Imagy
import XCTest
import Kingfisher

final class StorageStub: StorageProtocol {
    var token: String? = "Key"
    
    func clear() {
        token = nil
    }
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var storage: StorageProtocol = StorageStub()
    weak var controller: ProfileViewControllerProtocol?
    
    var isLogoutCalled = false
    var isUpdateAvatarCalled = false
    
    func logout() {
        isLogoutCalled = true
        storage.clear()
    }
    
    func updateAvatar() {
        isUpdateAvatarCalled = true
        let url = URL(string: "https://example.com/avatar.jpg")!
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        controller?.didReceiveProfileImageURL(with: url, processor: processor)
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    var storage = Storage.shared
    var updateAvatarCalled = false
    
    func logout(){
        presenter?.logout()
    }
    
    func updateAvatar(){
        presenter?.updateAvatar()
    }
    
    var isDidReceiveProfileImageURLCalled = false
    var receivedURL: URL?
    var receivedProcessor: ImageProcessor?
    
    func didReceiveProfileImageURL(with url: URL, processor: ImageProcessor) {
        isDidReceiveProfileImageURLCalled = true
        receivedURL = url
        receivedProcessor = processor
    }
}

final class ProfileTests: XCTestCase {
    
    func testLogout() {
        // Given
        let presenter = ProfileViewPresenterSpy()
        let controller = ProfileViewControllerSpy()
        controller.presenter = presenter
        presenter.controller = controller
        
        // When
        controller.logout()
        
        // Then
        XCTAssertTrue(presenter.storage.token == nil)
        XCTAssertTrue(presenter.isLogoutCalled == true)
    }
    
    func testUpdateAvatarCalled() {
        // Given
        let presenter = ProfileViewPresenterSpy()
        let controller = ProfileViewControllerSpy()
        controller.presenter = presenter
        presenter.controller = controller
        
        // When
        controller.updateAvatar() 
        
        // Then
        XCTAssertTrue(presenter.isUpdateAvatarCalled == true)
        XCTAssertNotNil(controller.receivedURL)
        XCTAssertNotNil(controller.receivedProcessor)
    }
}
