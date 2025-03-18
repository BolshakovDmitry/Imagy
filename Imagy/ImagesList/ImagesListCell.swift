import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: UITableViewCell?)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    private let imagesListService = ImagesListService.shared
    private var animationLayers = Set<CALayer>()
    weak var delegate: ImagesListCellDelegate?
    
    override func layoutSubviews() {
         super.layoutSubviews()
         updateGradientLayersFrame() // Обновляем размеры градиентных слоев
     }
    
    private func updateGradientLayersFrame() {
        for layer in animationLayers {
            if let gradientLayer = layer as? CAGradientLayer,
               let superview = gradientLayer.superlayer?.delegate as? UIView {
                gradientLayer.frame = superview.bounds // Обновляем размеры градиента
            }
        }
    }

    // MARK: - @IBOutlet properties
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradientAnimation()
        likeButton.accessibilityIdentifier = "LikeOff"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        removeGradientLayers()
    }
    

    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self as UITableViewCell)
    }
   
    func configure(with photo: Photo, dateFormatter: DateFormatter) {
        // Настройка изображения
        if let photoURL = URL(string: photo.thumbImageURL) {
            let placeholder = UIImage(named: "placeholder")
            cellImage.kf.indicatorType = .activity
            cellImage.kf.setImage(with: photoURL, placeholder: placeholder) { result in
                switch result {
                case .success:
                    self.cellImage.kf.indicatorType = .none
                case .failure(let error):
                    print("Failed to load image: \(error.localizedDescription)")
                }
            }
        }
        
        // Настройка даты
        if let date = photo.createdAt {
            dateLabel.text = dateFormatter.string(from: date)
        } else {
            dateLabel.text = ""
        }
        
        // Настройка кнопки лайка
        let likeImage = photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    // MARK: - установка сердечка

    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
        likeButton.accessibilityIdentifier = isLiked ? "LikeOn" : "LikeOff"
    }
    
    // MARK: - анимации
    
    private func setupGradientAnimation() {
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true
    }
    
    private func addGradientLayer(to view: UIView, cornerRadius: CGFloat? = nil) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
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
        
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        view.layer.addSublayer(gradient)
        animationLayers.insert(gradient)
    }
    
    private func removeGradientLayers() {
        for layer in animationLayers {
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
}
