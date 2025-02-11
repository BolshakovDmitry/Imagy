import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    private let storage = Storage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private var splashImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        view.addSubview(splashImageView)
        NSLayoutConstraint.activate([
            splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if storage.token != nil {
            guard let token = storage.token else { return }
            fetchProfile(token: token)
            fetchProfileImage(token: token)
            switchToTabBarController()
        } else {
            presentAuthenticationScreen()
        }
    }

    private func presentAuthenticationScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Failed to instantiate authentication controller")
            return
        }
        
        authVC.modalPresentationStyle = .fullScreen
        authVC.delegate = self
        present(authVC, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dissimiss()
            
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.switchToTabBarController()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchProfileImage(token: String) {
        profileImageService.fetchProfileImageURL(token: token) { result in
            switch result {
            case .success(let pictureURL):
                print(pictureURL)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = storage.token else { return }
        fetchProfile(token: token)
        fetchProfileImage(token: token)
        switchToTabBarController()
    }
}
