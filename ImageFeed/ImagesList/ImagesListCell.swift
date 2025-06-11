import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backgroundGradient: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    var gradientLayer: CAGradientLayer?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
}

extension ImagesListCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 8
        cellImage.layer.addSublayer(gradient)
        gradientLayer = gradient
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        gradient.add(animation, forKey: "locationsChange")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = cellImage.bounds
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(resource: .active) : UIImage(resource: .noActive)
        likeButton.setImage(likeImage, for: .normal)
    }
}
