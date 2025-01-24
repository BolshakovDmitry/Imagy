import UIKit

final class AuthViewController: UIViewController {
    
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button") // 1
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button") // 2
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 3
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black") // 4
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard
                let webViewController = segue.destination as? WebViewController
                    
            else {
                assertionFailure("Failed to prepare for \(ShowWebViewSegueIdentifier)")
                return
            }
            print("we are in the webViewController - ", webViewController)
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        print("AuthViewController View mounted")
    }
}

extension AuthViewController: WebViewControllerDelegate {
    func webViewViewController(_ vc: WebViewController, didAuthenticateWithCode code: String) {
        oauth2Service.fetchOAuthToken(code: code)
        
        
    }

    func webViewViewControllerDidCancel(_ vc: WebViewController) {
        vc.dismiss(animated: true)
        print("dismissed")
    }
}
