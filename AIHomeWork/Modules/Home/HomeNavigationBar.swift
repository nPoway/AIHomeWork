import UIKit

final class HomeNavigationBar: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Home"
        label.font = UIFont.plusJakartaSans(.bold, size: 22)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let proButton: UIButton = {
        let button = UIButton()
        let image = UIImage.proLabel.resizeImage(to: CGSize(width: 90, height: 50))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let settingsButton: UIButton = {
        let button = UIButton()
        let image = UIImage.settingsLogo
        button.setImage(image, for: .normal)
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
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(settingsButton)
        addSubview(proButton)
        addSubview(bottomLine)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            settingsButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 28),
            settingsButton.heightAnchor.constraint(equalToConstant: 28),
            
            proButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            proButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            proButton.widthAnchor.constraint(equalToConstant: 85),
            proButton.heightAnchor.constraint(equalToConstant: 45),
            
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchableArea = settingsButton.frame.insetBy(dx: -10, dy: -30)
        return touchableArea.contains(point) ? settingsButton : super.hitTest(point, with: event)
    }
}
