import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - @IBOutlet properties
    
    @IBOutlet private var tableView: UITableView!
    private let currentDate = Date()
    private let imagesListService = ImagesListService.shared
    private let storage = Storage()
    var photos: [Photo] = []
    private var imageListServiceObserver: NSObjectProtocol?
    
    // MARK: - private properties
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        subscribeToPhotosUpdate()
    }
    
    private func subscribeToPhotosUpdate() {
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.ImagesListServiceDidChange,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateTableViewAnimated()
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSingleImage" {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            // Получаем фото из массива photos
            let photo = photos[indexPath.row]
            // Загружаем изображение
            loadImage(for: photo, at: indexPath, in: viewController)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    // Функция для загрузки изображения
    private func loadImage(for photo: Photo, at indexPath: IndexPath, in viewController: SingleImageViewController) {
        if let imageURL = URL(string: photo.largeImageURL) {
            UIBlockingProgressHUD.show()
            KingfisherManager.shared.retrieveImage(with: imageURL) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                
                switch result {
                case .success(let value):
                    // Передаем загруженное изображение на главном потоке
                    DispatchQueue.main.async {
                        viewController.image = value.image
                    }
                case .failure(let error):
                    print("Failed to load image: \(error.localizedDescription)")
                    // Показываем алерт об ошибке
                    DispatchQueue.main.async {
                        self.showError(for: photo, at: indexPath, in: viewController)
                    }
                }
            }
        }
    }

    // Функция для показа алерта об ошибке
    private func showError(for photo: Photo, at indexPath: IndexPath, in viewController: SingleImageViewController) {
        
        AlertPresenter.showAlert(
            title: "Что-то пошло не так",
            message: "Попробовать еще раз?",
            buttonText: "Ок",
            on: self,
            addYesNoButtons: true) { [weak self] in
                self?.loadImage(for: photo, at: indexPath, in: viewController)
            }
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imagesListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imagesListCell.delegate = self
        
        configCell(for: imagesListCell, with: indexPath)
        
        return imagesListCell
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        let photo = photos[indexPath.row]
        // Преобразуем строку в URL
        guard let photoURL = URL(string: photo.thumbImageURL) else {
            print("Invalid URL: \(photo.thumbImageURL)")
            return
        }
        
        let placeholder = UIImage(named: "placeholder")
        cell.cellImage.kf.indicatorType = .activity
        
        UIBlockingProgressHUD.show()
        // Используем photoURL типа URL
        cell.cellImage.kf.setImage(with: photoURL, placeholder: placeholder) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(_):
                cell.cellImage.kf.indicatorType = .none
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                print("Failed to load image: \(error.localizedDescription)")
            }
        }
        
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        cell.selectionStyle = .none
        
        let isLiked = photo.isLiked
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("pressed the Cell N - ", indexPath.row, "photo array lenght - ", photos.count)
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("WILL display ----- indexPath - ", indexPath.row, imagesListService.photos.count  )
        if indexPath.row + 1 == imagesListService.photos.count{
            imagesListService.fetchPhotosNextPage(token: storage.token ?? "")
            
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        
       let cellImage = cell
    
      guard let indexPath = tableView.indexPath(for: cell) else { return }
      let photo = photos[indexPath.row]
      // Покажем лоадер
     UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoID: photo.id, isLike: !photo.isLiked) { result in
        switch result {
        case .success:
            DispatchQueue.main.async{
                // Синхронизируем массив картинок с сервисом
                self.photos = self.imagesListService.photos
                // Изменим индикацию лайка картинки
                cellImage.setIsLiked(self.photos[indexPath.row].isLiked)
                // Уберём лоадер
                UIBlockingProgressHUD.dismiss()
            }
        case .failure:
           // Уберём лоадер
           UIBlockingProgressHUD.dismiss()
           // Покажем, что что-то пошло не так
            AlertPresenter.showAlert(title: "что-то пошло не так", message: "произошла ошибка", on: self)
           }
        }
    }
    
}
