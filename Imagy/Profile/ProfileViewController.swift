import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = UIColor(named: "YP Grey")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var shareButton: UIButton = {
        let button = UIButton.systemButton(with: UIImage(systemName: "ipad.and.arrow.forward")!, target: self, action: nil)
        button.tintColor = UIColor(named: "YP Red")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let storage = Storage()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        
        profileImageServiceObserver = NotificationCenter.default    // 2
                    .addObserver(
                        forName: ProfileImageService.didChangeNotification, // 3
                        object: nil,                                        // 4
                        queue: .main                                        // 5
                    ) { [weak self] _ in
                        guard let self = self else { return }
                        self.updateAvatar()                                 // 6
                    }
                updateAvatar()                                              // 7
        
        guard let token = storage.token else { return }
        
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        
        if let imageURL = profileImageService.avatarURL {
            //updateProfilePicture(with: imageURL)
        }
    }
    
    private func updateAvatar() {                                   // 8
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url,
                              placeholder: UIImage(named: "placeholder.jpeg"),
                              options: [.processor(processor)])
    }

    private func updateProfileDetails(profile: Profile){
        self.nameLabel.text = profile.name
        self.usernameLabel.text = profile.loginName
        self.greetingLabel.text = profile.bio
    }
    
    
//    private func updateProfilePicture(with url: String){
//        if let url = URL(string: url) {
//            DispatchQueue.global().async { [weak self] in
//                guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
//                    print("Не удалось загрузить изображение.")
//                    return
//                }
//                
//                DispatchQueue.main.async {
//                    self?.avatarImageView.image = image
//                }
//            }
//        }
//    }
    
    private func setupViews() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(greetingLabel)
        view.addSubview(shareButton)
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
            
            shareButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            shareButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor, constant: 0)
        ])
    }
}
