import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func didReceiveProfileImageURL(with url: URL, processor: ImageProcessor)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    private var animationLayers = Set<CALayer>() // Множество для хранения слоев с анимациями
    
    // MARK: -   настройка элементов
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder.jpeg")
        imageView.tintColor = .gray
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "nameLabel"
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = UIColor(named: "YP Grey")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "usernameLabel"
        return label
    }()
    
    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton.systemButton(with: UIImage(systemName: "ipad.and.arrow.forward")!, target: self, action: nil)
        button.tintColor = UIColor(named: "YP Red")
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "logout button"
        return button
    }()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    var presenter: ProfileViewPresenterProtocol?
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YP Background")
        setupViews()
        setupConstraints()
        
        // Подписываемся на уведомление
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main,
                using: { [weak self] _ in
                    guard let self else { return }
                    self.removeGradientLayers() // Удаляем градиентные слои
                    presenter?.updateAvatar()
                })
        
        // Добавляем градиентные слои
        addGradientLayer(to: avatarImageView, cornerRadius: 35)
        addGradientLayer(to: nameLabel)
        addGradientLayer(to: usernameLabel)
        addGradientLayer(to: greetingLabel)
        
        presenter?.updateAvatar()
        
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientLayersFrame() // Обновляем размеры градиентных слоев
    }
    
    
    @objc private func logout() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            presenter?.logout()
            self.switchToSplashViewController()
        }
        yesAction.accessibilityIdentifier = AccessibilityConstans.yesActionAccessibilityIdentifier
        
        let noAction = UIAlertAction(title: "Нет", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func switchToSplashViewController() {
        let splashViewController = SplashViewController()
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = splashViewController
    }
    
    func didReceiveProfileImageURL(with url: URL, processor: ImageProcessor) {
        
        DispatchQueue.main.async {
            self.avatarImageView.kf.setImage(
                with: url,
                options: [.processor(processor)]
            )
            self.removeGradientLayers() // Удаляем градиентные слои после загрузки изображения
        }
        
    }
    
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        usernameLabel.text = profile.loginName
        greetingLabel.text = profile.bio
    }
    // MARK: - градиенты
    
    private func addGradientLayer(to view: UIView, cornerRadius: CGFloat? = nil) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        if let cornerRadius = cornerRadius {
            gradient.cornerRadius = cornerRadius
        }
        
        gradient.masksToBounds = true
        
        // Добавляем анимацию
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        view.layer.addSublayer(gradient)
        animationLayers.insert(gradient) // Добавляем слой в множество
    }
    
    private func removeGradientLayers() {
        for layer in animationLayers {
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
    
    private func updateGradientLayersFrame() {
        for layer in animationLayers {
            if let gradientLayer = layer as? CAGradientLayer,
               let superview = gradientLayer.superlayer?.delegate as? UIView {
                gradientLayer.frame = superview.bounds // Обновляем размеры градиента
            }
        }
    }
    
    // MARK: - настройка вью и констрейнты
    
    private func setupViews() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(greetingLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            greetingLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            greetingLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor, constant: 0)
        ])
    }
}
