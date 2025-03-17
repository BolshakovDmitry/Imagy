import UIKit
import Kingfisher

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol { get set }
    func updateTableViewAnimated(indexes: Range<Int>, photos: [Photo])
    func configure(presenter: ImagesListViewPresenterProtocol)
    func subscribeToPhotosUpdateTESTS()
    func imageListCellDidTapLike(_ cell: UITableViewCell?)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    var presenter: ImagesListViewPresenterProtocol = ImagesListPresenter()
    @IBOutlet private var tableView: UITableView!
    private let currentDate = Date()
    private let imagesListService = ImagesListService.shared
    private let storage = Storage.shared
    var photos: [Photo] = []
    private var imageListServiceObserver: NSObjectProtocol?
    private let token = Storage.shared.token
    
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
        self.presenter.controller = self
    }
    
    func configure(presenter: ImagesListViewPresenterProtocol){
        self.presenter = presenter
        self.presenter.controller = self
    }
    
    // MARK: - переход на страницу с увеличенным изображением
    
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
            presenter.loadImageForSingleImageVC(for: photo, at: indexPath, in: viewController) { result in
                switch result {
                case .success(let image):
                    viewController.image = image
                case .failure(let error):
                    print(error.localizedDescription)
                    self.showError(for: photo, at: indexPath, in: viewController)
                }
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func showError(for photo: Photo, at indexPath: IndexPath, in viewController: SingleImageViewController) {
        AlertPresenter.showAlert(
            title: "Что-то пошло не так",
            message: "Попробовать еще раз?",
            buttonText: "Ок",
            on: self,
            addYesNoButtons: true
        ) { [weak self] in
            // Повторная попытка загрузить изображение
            self?.presenter.loadImageForSingleImageVC(for: photo, at: indexPath, in: viewController) { result in
                switch result {
                case .success(let image):
                    viewController.image = image
                case .failure(_):
                    // Проверяем, что self существует
                    guard let self = self else { return }
                    AlertPresenter.showAlert(title: "Что-то пошло не так", message: "Попробуйте чуть позже", on: self)
                }
            }
        }
    }
    
    
    
    // MARK: - подписка на обновление массива с фотками
    
     func subscribeToPhotosUpdate() {
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.ImagesListServiceDidChange,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.presenter.didGetPhotos()
            }
    }
    
    func subscribeToPhotosUpdateTESTS(){
        self.presenter.didGetPhotos()
        guard let token = token else { return }
        ImagesListService.shared.fetchPhotosNextPage(token: token)
    }
    
    func updateTableViewAnimated(indexes: Range<Int>, photos: [Photo]) {
        self.photos = photos
        tableView.performBatchUpdates {
            let indexPaths = indexes.map { index in
                IndexPath(row: index, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
}

// MARK: - таблица

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
        
        imagesListCell.selectionStyle = .none
        imagesListCell.delegate = self
        
        // Настройка ячейки с использованием метода configure
        let photo = photos[indexPath.row]
        imagesListCell.configure(with: photo, dateFormatter: dateFormatter)
        
        return imagesListCell
    }
}


// MARK: - переход на SingleImageVC и расчет высоты ячеек

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("pressed the Cell N - ", indexPath.row+1, "photo array length - ", photos.count)
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
    
    // MARK: - запрос след партии фото
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("WILL display ----- indexPath - ", indexPath.row+1, imagesListService.photos.count  )
        if indexPath.row + 1 == imagesListService.photos.count{
            imagesListService.fetchPhotosNextPage(token: storage.token ?? "")
        }
    }
}

// MARK: - функционал отображения лайков

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: UITableViewCell?) {
        guard let imagesListCell = cell as? ImagesListCell,
              let indexPath = tableView.indexPath(for: imagesListCell)
        else { return }
        presenter.changeLikeOnPhoto(for: cell, with: indexPath){ [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                print("")
            case.failure(_):
                AlertPresenter.showAlert(title: "что-то пошло не так", message: "произошла ошибка", on: self)
            }
        }
    }
    
    
}
