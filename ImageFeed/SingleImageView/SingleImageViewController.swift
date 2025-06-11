import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageURL: URL? {
        didSet {
            guard isViewLoaded else { return }
            updateImage()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        updateImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let image = imageView.image {
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if let image = imageView.image {
            centerImage(image: image, animated: true)
        }
    }
    
    private func updateImage() {
        guard let url = imageURL else { return }
        imageView.kf.indicatorType = .activity
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            
            switch result {
            case .success(let value):
                self.imageView.translatesAutoresizingMaskIntoConstraints = true
                self.imageView.frame.size = value.image.size
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        scrollView.layoutIfNeeded()
        
        let visibleSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleSize.width / imageSize.width
        let vScale = visibleSize.height / imageSize.height
        let minScale = scrollView.minimumZoomScale
        let maxScale = scrollView.maximumZoomScale
        let scale = min(maxScale, max(minScale, max(hScale, vScale)))
        
        
        scrollView.setZoomScale(scale, animated: false)
        
        imageView.frame.size = CGSize(width: imageSize.width * scale,
                                      height: imageSize.height * scale)
        
        scrollView.contentSize = imageView.frame.size
        
        let offsetX = max(0, (imageView.frame.size.width - scrollView.bounds.size.width) / 2)
        let offsetY = max(0, (imageView.frame.size.height - scrollView.bounds.size.height) / 2)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
        
        centerImage(image: image, animated: false)
        
    }
    
    private func centerImage(image: UIImage, animated: Bool) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalInset = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        let horizontalInset = max(0, (scrollViewSize.width - imageViewSize.width) / 2)
        
        let insets = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.scrollView.contentInset = insets
                self.scrollView.layoutIfNeeded()
            }
        } else {
            scrollView.contentInset = insets
        }
    }
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ок", style: .default) { [weak self] _ in
            self?.updateImage()
        })
        
        present(alert, animated: true)
    }
}
