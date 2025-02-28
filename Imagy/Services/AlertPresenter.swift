import UIKit

final class AlertPresenter {
    
    /// Показывает алерт с заданными параметрами.
    ///
    /// - Parameters:
    ///   - title: Заголовок алерта.
    ///   - message: Сообщение алерта.
    ///   - buttonText: Текст для кнопки по умолчанию (по умолчанию "Ок").
    ///   - viewController: Контроллер, на котором будет показан алерт.
    ///   - addYesNoButtons: Если `true`, добавляет кнопки "Да" и "Нет".
    ///   - completion: Замыкание, которое выполняется при нажатии на кнопку по умолчанию.
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
        
        // Добавляем кнопки "Да" и "Нет", если требуется
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
