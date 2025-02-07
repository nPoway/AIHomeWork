import UIKit

class ScanView: UIView {
    
    let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let flashButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bolt.slash"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let bottomControlsStack = UIStackView(arrangedSubviews: [galleryButton, captureButton, flashButton])
        bottomControlsStack.axis = .horizontal
        bottomControlsStack.distribution = .equalSpacing
        bottomControlsStack.alignment = .center
        bottomControlsStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomControlsStack)
        
        NSLayoutConstraint.activate([
            bottomControlsStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomControlsStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomControlsStack.widthAnchor.constraint(equalToConstant: 250),
            captureButton.heightAnchor.constraint(equalToConstant: 70),
            captureButton.widthAnchor.constraint(equalToConstant: 70)
        ])
    }
}
