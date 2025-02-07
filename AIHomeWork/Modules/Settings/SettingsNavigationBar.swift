import UIKit


final class SettingsNavigationBar: BaseBlurredView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
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
    
    private let proButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.proLabel, for: .normal)
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
    
    override func setupUI() {
        addSubview(titleLabel)
        addSubview(backButton)
        addSubview(proButton)
        addSubview(bottomLine)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            proButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            proButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            proButton.widthAnchor.constraint(equalToConstant: 75),
            proButton.heightAnchor.constraint(equalToConstant: 40),
            
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
