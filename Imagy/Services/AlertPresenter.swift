import UIKit

final class AlertPresenter {
    static func showAlert(
        title: String,
        message: String,
        buttonText: String = "Ок",
        on viewController: UIViewController,
        addYesNoButtons: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        if !addYesNoButtons {
            // Добавляем кнопку по умолчанию
            let defaultAction = UIAlertAction(title: buttonText, style: .default) { _ in
                completion?()
            }
            alert.addAction(defaultAction)
        }
        
        // Добавляем кнопки "Повторить" и "Не надо", если требуется
        if addYesNoButtons {
            let yesAction = UIAlertAction(title: "Повторить", style: .default) { _ in
                completion?()
            }
            alert.addAction(yesAction)
            
            let noAction = UIAlertAction(title: "Не надо", style: .cancel) { _ in
                viewController.dismiss(animated: true, completion: nil)
                
            }
            alert.addAction(noAction)
        }
        
        // Показываем алерт на переданном контроллере
        viewController.present(alert, animated: true, completion: nil)
    }
}
