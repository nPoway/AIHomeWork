import UIKit

final class AIChatSectionView: BaseView {
    
    let chatButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(white: 0.1, alpha: 1)
        button.layer.cornerRadius = 15
        button.setTitle("", for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ask the AI a Question"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    private let iconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right.fill"))
        imageView.tintColor = .blue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Type a question or task to get quick answers"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.right.circle.fill"))
        imageView.tintColor = .gray
        return imageView
    }()
    
    override func setupUI() {
        addSubview(titleLabel)
        addSubview(chatButton)
        
        chatButton.addSubview(iconView)
        chatButton.addSubview(textLabel)
        chatButton.addSubview(arrowImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            chatButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            chatButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            chatButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            chatButton.heightAnchor.constraint(equalToConstant: 60),
            
            iconView.leadingAnchor.constraint(equalTo: chatButton.leadingAnchor, constant: 15),
            iconView.centerYAnchor.constraint(equalTo: chatButton.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            textLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            textLabel.centerYAnchor.constraint(equalTo: chatButton.centerYAnchor),
            
            arrowImageView.trailingAnchor.constraint(equalTo: chatButton.trailingAnchor, constant: -15),
            arrowImageView.centerYAnchor.constraint(equalTo: chatButton.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 24),
            arrowImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
