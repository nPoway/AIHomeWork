import UIKit

protocol ScanOptionsDelegate: AnyObject {
    func didSelectCameraOption()
    func didSelectGalleryOption()
}

final class ScanOptionsViewController: UIViewController {
    
    weak var delegate: ScanOptionsDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Scan"
        label.textColor = .white
        label.font = UIFont.plusJakartaSans(.semiBold, size: 22)
        label.textAlignment = .center
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        let image = UIImage.customXmark
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let topSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        return view
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan with Camera", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.plusJakartaSans(.semiBold, size: 16)
        let cameraImage = UIImage.cameraIcon.resizeImage(to: CGSize(width: 32, height: 32))
        button.setImage(cameraImage, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 8)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 0)
        button.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose from Gallery", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.plusJakartaSans(.semiBold, size: 16)
        let galleryImage = UIImage.galleryButton.resizeImage(to: CGSize(width: 32, height: 32))
        button.setImage(galleryImage, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 8)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 0)
        button.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let containerView: BlurredGradientView = {
        let view = BlurredGradientView()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        view.addSubview(dimmedView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 230 : 280)
        ])
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        containerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        containerView.addSubview(topSeparator)
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topSeparator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            topSeparator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [cameraButton, galleryButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: 25),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: iphoneWithButton ? -30 : -80)
        ])
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(galleryTapped), for: .touchUpInside)
    }
    
    @objc private func dismissView() {
        dismiss(animated: false)
        triggerHapticFeedback(type: .selection)
    }
    
    @objc private func cameraTapped() {
        dismiss(animated: true) {
            self.delegate?.didSelectCameraOption()
        }
    }
    
    @objc private func galleryTapped() {
        dismiss(animated: true) {
            self.delegate?.didSelectGalleryOption()
        }
    }
}
