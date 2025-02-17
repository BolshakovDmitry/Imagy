import UIKit

final class AlertPresenter {
    
    static func showAlert(
        title: String,
        message: String,
        buttonText: String = "Ок",
        on viewController: UIViewController,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: buttonText, style: .default) { _ in
            completion?()
        }
        
        alert.addAction(action)
        
        // Показываем алерт на переданном контроллере
        viewController.present(alert, animated: true, completion: nil)
    }
}
