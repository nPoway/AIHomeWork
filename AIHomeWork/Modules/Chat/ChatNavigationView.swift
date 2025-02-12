import UIKit

final class ChatNavigationView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI Chat"
        label.textColor = .white
        label.font = UIFont.plusJakartaSans(.bold, size: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.leftArrow, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        addSubview(backButton)
        addSubview(bottomLine)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func changeTitle(_ title: String) {
        self.titleLabel.text = title
    }
}

