import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}


final class ImagesListCell: UITableViewCell {
    
    private var imagesListViewController = ImagesListViewController()
    weak var delegate: ImagesListCellDelegate? 
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - @IBOutlet properties
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    // Слабая ссылка на таблицу
        weak var tableView: UITableView?
    
    @IBAction private func likeButtonClicked() {
        
        delegate?.imageListCellDidTapLike(self)

            }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    func setIsLiked(_ isLiked: Bool) {
            let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
            likeButton.setImage(likeImage, for: .normal)
            likeButton.accessibilityIdentifier = isLiked ? "LikeOn" : "LikeOff"
        }
    
}
