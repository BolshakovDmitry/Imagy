
import Foundation
import UIKit

final class SplashViewController: UIViewController {
    
    private let storage = Storage()
    private let showMainFlow = "showMainFlow"
    private let showAuthenticationFlow = "showAuthenticationFlow"
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if storage.token != nil { // проверка наличия токена
            guard let token = storage.token else { return }
            print("token from SplashViewController", storage.token!)
            fetchProfile(token: token)
            fetchProfileImage(token: token)
            performSegue(withIdentifier: showMainFlow, sender: nil)
        } else {
            performSegue(withIdentifier: showAuthenticationFlow, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверим, что переходим на авторизацию
        if segue.identifier == "showAuthenticationFlow" {
            
            // Доберёмся до первого контроллера в навигации.
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \("showAuthenticationFlow")")
                return
            }
            
            // Установим делегатом контроллера наш SplashViewController
            viewController.delegate = self
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func switchToTabBarController() {
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
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
    
    func fetchProfile(token: String){
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
    
    func fetchProfileImage(token: String){
        profileImageService.fetchProfileImageURL(token: token) { [weak self] result in
            switch result {
            case .success(let pictureURL):
                print(pictureURL)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}
