import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileImage = UIImage(named: "avatar")
        let imageView = UIImageView(image: profileImage)
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold) // SF Pro Bold, Size 23
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        
        
        let label2 = UILabel()
        label2.text = "@ekaterina_nov"
        label2.textColor = UIColor(named: "YP Grey")
        label2.font = UIFont.systemFont(ofSize: 13, weight: .regular) // SF Pro Bold, Size 23
        label2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label2)
        label2.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8).isActive = true
        label2.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
        
        let label3 = UILabel()
        label3.text = "Hello, world!"
        label3.textColor = .white
        label3.font = UIFont.systemFont(ofSize: 13, weight: .regular) // SF Pro Bold, Size 23
        label3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label3)
        label3.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 8).isActive = true
        label3.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
        
        let button = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: nil
        )
        button.tintColor = UIColor(named: "YP Red")
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 0).isActive = true
        
    }
}


