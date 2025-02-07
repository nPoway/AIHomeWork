import UIKit

final class SubjectCell: UICollectionViewCell {
    
    static let identifier = "SubjectCell"
    
    private let image = UIImageView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .plusJakartaSans(.semiBold, size: 16)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .plusJakartaSans(.medium, size: 12)
        label.numberOfLines = 0
        label.textColor = .gray
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.arrowUp)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        
        contentView.layer.borderColor = UIColor(white: 1.0, alpha: 0.1).cgColor
        contentView.layer.borderWidth = 1
        
        [image, titleLabel, subtitleLabel, arrowImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 50),
            image.heightAnchor.constraint(equalToConstant: 50),
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: image.leadingAnchor, constant: 5),
            titleLabel.widthAnchor.constraint(equalToConstant: 130)
        ])
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: image.leadingAnchor, constant: 5),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
        ])
        
        NSLayoutConstraint.activate([
            arrowImageView.topAnchor.constraint(equalTo: image.topAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            arrowImageView.widthAnchor.constraint(equalToConstant: 32),
            arrowImageView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(with item: Subject) {
        titleLabel.text = item.title
        subtitleLabel.text = item.description
        setupImage(with: item)
    }
    
    private func setupImage(with item: Subject) {
        let imageName = item.imageName
        image.image = UIImage(named: imageName)
    }

}
