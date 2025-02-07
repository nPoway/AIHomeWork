import UIKit

final class SettingsCell: UITableViewCell {
    static let identifier = "SettingsCell"
    
    private let containerView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let arrowView = UIImageView(image: UIImage.rightArrow)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none

        backgroundColor = .clear
        
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.plusJakartaSans(.medium, size: 16)
        arrowView.tintColor = .white
        
        contentView.addSubview(containerView)
        [iconView, titleLabel, arrowView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            
            arrowView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            arrowView.widthAnchor.constraint(equalToConstant: 32),
            arrowView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(title: String, icon: UIImage?) {
        titleLabel.text = title
        iconView.image = icon
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }

}
