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
        backgroundColor = .black
        addSubview(titleLabel)
        addSubview(settingsButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            settingsButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 28),
            settingsButton.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchableArea = settingsButton.frame.insetBy(dx: -10, dy: -30)
        return touchableArea.contains(point) ? settingsButton : super.hitTest(point, with: event)
    }
}
