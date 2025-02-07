import UIKit

final class AIChatSectionView: UICollectionReusableView {
    
    static let identifier = "AIChatSectionView"
    
    let chatButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(white: 0.1, alpha: 1)
        button.layer.cornerRadius = 15
        button.layer.borderColor = UIColor(white: 1.0, alpha: 0.1).cgColor
        button.layer.borderWidth = 1
        button.setTitle("", for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ask the AI a Question"
        label.font = UIFont.plusJakartaSans(.bold, size: 18)
        label.textColor = .white
        return label
    }()
    
    private let iconView: UIImageView = {
        let imageView = UIImageView(image: UIImage.chatLogo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI Chat"
        label.textColor = .white
        label.font = .plusJakartaSans(.semiBold, size: 16)
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Type a question or task to get quick answers"
        label.font = UIFont.plusJakartaSans(.medium, size: 11)
        label.textColor = .lightGray
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.arrowLeft)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(titleLabel)
        addSubview(chatButton)
        
        chatButton.addSubview(iconView)
        chatButton.addSubview(buttonTitleLabel)
        chatButton.addSubview(textLabel)
        chatButton.addSubview(arrowImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            chatButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            chatButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            chatButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            chatButton.heightAnchor.constraint(equalToConstant: 70),
            
            iconView.leadingAnchor.constraint(equalTo: chatButton.leadingAnchor, constant: 15),
            iconView.centerYAnchor.constraint(equalTo: chatButton.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 45),
            iconView.heightAnchor.constraint(equalToConstant: 45),
            
            buttonTitleLabel.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 5),
            buttonTitleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 7),
            buttonTitleLabel.widthAnchor.constraint(equalToConstant: 200),
            
            textLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 7),
            textLabel.topAnchor.constraint(equalTo: buttonTitleLabel.bottomAnchor, constant: 3),
            textLabel.widthAnchor.constraint(equalToConstant: 280),
            
            arrowImageView.trailingAnchor.constraint(equalTo: chatButton.trailingAnchor, constant: -15),
            arrowImageView.centerYAnchor.constraint(equalTo: chatButton.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 24),
            arrowImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
