import UIKit
import Kingfisher

final class ImagesList: UIViewController {
    @IBOutlet private var tableView: UITableView!
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    var presenter: ImagesListPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        presenter?.view = self
        presenter?.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        presenter?.viewDidLayoutSubviews()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let vc = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath,
           let photo = presenter?.photo(at: indexPath.row),
           let url = URL(string: photo.largeImageURL) {
            vc.imageURL = url
        }
    }

    private func configCell(_ cell: ImagesListCell, for indexPath: IndexPath) {
        guard let photo = presenter?.photo(at: indexPath.row) else { return }

        cell.backgroundGradient.clipsToBounds = true
        cell.backgroundGradient.layer.cornerRadius = 16
        cell.backgroundGradient.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        cell.cellImage.kf.indicatorType = .activity
        if let url = URL(string: photo.thumbImageURL) {
            let placeholder = UIImage(named: "Stub")
            cell.cellImage.kf.setImage(with: url, placeholder: placeholder) { _ in
                cell.gradientLayer?.removeFromSuperlayer()
                cell.gradientLayer = nil
                cell.setNeedsLayout()
            }
        }

        cell.dateLabel.text = presenter?.formattedDate(for: photo)
        cell.setIsLiked(photo.isLiked)
    }
}

// MARK: - ImagesListViewProtocol

extension ImagesList: ImagesListViewProtocol {
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func reloadRows(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .none)
    }

    func reloadTable() {
        tableView.reloadData()
    }
}

// MARK: - UITableView

extension ImagesList: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfPhotos() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(imageListCell, for: indexPath)
        return imageListCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if ProcessInfo.processInfo.arguments.contains("testMode"){
            return
        }
        presenter?.willDisplayCell(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter?.heightForRow(at: indexPath.row, tableViewWidth: tableView.bounds.width) ?? 0
    }
}

// MARK: - Like Action

extension ImagesList: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        UIBlockingProgressHUD.show()
        presenter?.toggleLike(at: indexPath.row) { [weak self] success in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            if success {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            } else {
                let alert = UIAlertController(title: "Ошибка", message: "Не удалось изменить статус лайка.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
