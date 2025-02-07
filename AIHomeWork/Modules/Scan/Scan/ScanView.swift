import UIKit

class ScanView: UIView {
    
    private let scanLabel: UILabel = {
        let label = UILabel()
        label.text = "Scan the assignment to get the solution"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.plusJakartaSans(.regular, size: 15)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.backgroundColor = .customPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cameraBackground: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cameraBackground"))
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.6
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let darkOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()



    
    let navigationBar = ScanNavigationBar()
    
    private let blurredBackground: BaseBlurredView = {
        let view = BaseBlurredView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.captureButton, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.galleryButton, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let flashButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.noFlash, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        addSubview(cameraBackground)
        addSubview(darkOverlay)

        NSLayoutConstraint.activate([
            cameraBackground.topAnchor.constraint(equalTo: topAnchor),
            cameraBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            cameraBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            cameraBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            darkOverlay.topAnchor.constraint(equalTo: topAnchor),
            darkOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            darkOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            darkOverlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addSubview(scanLabel)
        
        addSubview(blurredBackground)
        blurredBackground.layer.cornerRadius = 24
        blurredBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blurredBackground.clipsToBounds = true
        
        
        let bottomControlsStack = UIStackView(arrangedSubviews: [galleryButton, captureButton, flashButton])
        bottomControlsStack.axis = .horizontal
        bottomControlsStack.distribution = .equalSpacing
        bottomControlsStack.alignment = .center
        bottomControlsStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(bottomControlsStack)
        
        NSLayoutConstraint.activate([
            blurredBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurredBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurredBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurredBackground.heightAnchor.constraint(equalToConstant: 130),
            
            bottomControlsStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            bottomControlsStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomControlsStack.widthAnchor.constraint(equalToConstant: 250),
            
            captureButton.heightAnchor.constraint(equalToConstant: 75),
            captureButton.widthAnchor.constraint(equalToConstant: 75),
            
            galleryButton.heightAnchor.constraint(equalToConstant: 32),
            galleryButton.widthAnchor.constraint(equalToConstant: 32),
            
            flashButton.heightAnchor.constraint(equalToConstant: 32),
            flashButton.widthAnchor.constraint(equalToConstant: 32),
            
            scanLabel.bottomAnchor.constraint(equalTo: blurredBackground.topAnchor, constant: -20),
            scanLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            scanLabel.widthAnchor.constraint(equalToConstant: 310),
            scanLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
    
}
