import UIKit

protocol CropViewControllerDelegate: AnyObject {
    func cropViewControllerDidFinish(image: UIImage)
}

final class CropViewController: UIViewController {
    
    // MARK: - Properties
    
    private let coordinator: Coordinator
    private let viewModel = CropViewModel()
    
    private let imageView = UIImageView()
    private let cropView = CropView()
    
    private var image: UIImage
    weak var delegate: CropViewControllerDelegate?
    private let navigationBar = CropNavigationView()
    
    // MARK: - Init
    
    init(image: UIImage, coordinator: Coordinator) {
        self.coordinator = coordinator
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .black
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        view.addSubview(imageView)
        view.addSubview(cropView)
        setupNavigationBar()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cropView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8),
            
            cropView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            cropView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            cropView.widthAnchor.constraint(equalTo: imageView.widthAnchor),
            cropView.heightAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
        
        setupToolbar()
    }
    
    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110)
        ])
        
        navigationBar.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
        triggerHapticFeedback(type: .selection)
    }
    
    private func setupToolbar() {
        let toolbar = BlurredGradientView()
        toolbar.layer.cornerRadius = 10
        view.addSubview(toolbar)
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        let cancelButton = createToolbarButton(title: "Cancel", action: #selector(cancelTapped))
        let rotateLeftButton = createToolbarButton(image: UIImage.flipLeft, action: #selector(rotateLeftTapped))
        let flipVerticalButton = createToolbarButton(image: UIImage.rotate, action: #selector(flipVerticalTapped))
        let cropRatioButton = createToolbarButton(image: UIImage.ratio, action: #selector(cropRatioTapped))
        let rotateRightButton = createToolbarButton(image: UIImage.flipRight, action: #selector(rotateRightTapped))
        let doneButton = createToolbarButton(title: "Done", action: #selector(doneTapped))
        
        let stackView = UIStackView(arrangedSubviews: [
            cancelButton,
            rotateLeftButton,
            flipVerticalButton,
            cropRatioButton,
            rotateRightButton,
            doneButton
        ])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 20
        
        toolbar.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: toolbar.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor, constant: -10),
            stackView.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -20)
        ])
    }
    
    private func createToolbarButton(title: String? = nil,
                                     image: UIImage? = nil,
                                     action: Selector?) -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .white
        
        if let title = title {
            if title == "Cancel" {
                button.setTitleColor(.systemBlue, for: .normal)
            } else {
                button.setTitleColor(.yellow, for: .normal)
            }
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        } else if let image = image {
            let resizedImage = image
                .withRenderingMode(.alwaysTemplate)
                .resizeImage(to: CGSize(width: 24, height: 24))
            button.setImage(resizedImage, for: .normal)
        }
        
        if let action = action {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        
        return button
    }
    
    // MARK: - Gestures
    
    private func setupGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed || gesture.state == .ended {
            let scale = gesture.scale
            imageView.transform = imageView.transform.scaledBy(x: scale, y: scale)
            gesture.scale = 1.0
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        if gesture.state == .changed || gesture.state == .ended {
            imageView.transform = imageView.transform.translatedBy(x: translation.x, y: translation.y)
            gesture.setTranslation(.zero, in: view)
        }
    }
    
    // MARK: - Toolbar Button Actions
    
    @objc private func rotateLeftTapped() {
        triggerHapticFeedback(type: .light)
        guard let currentImage = imageView.image else { return }
        let rotatedImage = viewModel.rotateImageBy90(currentImage, clockwise: true)
        image = rotatedImage
        imageView.image = rotatedImage
        imageView.transform = .identity
        applyTransformAnimated()
        
    }
    
    @objc private func rotateRightTapped() {
        triggerHapticFeedback(type: .light)
        guard let currentImage = imageView.image else { return }
        let rotatedImage = viewModel.rotateImageBy90(currentImage, clockwise: false)
        image = rotatedImage
        imageView.image = rotatedImage
        imageView.transform = .identity
        applyTransformAnimated()
    }
    
    @objc private func flipVerticalTapped() {
        triggerHapticFeedback(type: .light)
        guard let currentImage = imageView.image else { return }
        let rotated180 = viewModel.rotateImage180(currentImage)
        image = rotated180
        imageView.image = rotated180
        imageView.transform = .identity
        applyTransformAnimated()
    }
    
    @objc private func cropRatioTapped() {
        triggerHapticFeedback(type: .light)
        let alertController = UIAlertController(title: "Select Aspect Ratio",
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        let ratios: [(String, CGFloat)] = [
            ("Original", 0),
            ("Square", 1.0),
            ("2:3", 2.0/3.0),
            ("3:5", 3.0/5.0),
            ("3:4", 3.0/4.0),
            ("4:5", 4.0/5.0),
            ("5:7", 5.0/7.0),
            ("9:16", 9.0/16.0)
        ]
        
        for (name, ratio) in ratios {
            let action = UIAlertAction(title: name, style: .default) { _ in
                let newRect = self.viewModel.computeCropRect(for: ratio, in: self.cropView.bounds)
                self.cropView.cropRect = newRect
                triggerHapticFeedback(type: .success)
            }
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    private func applyTransformAnimated() {
        UIView.animate(withDuration: 0.2) {
            self.imageView.transform = self.viewModel.currentTransform()
            self.adjustAfterTransform()
        }
    }
    
    private func adjustAfterTransform() {
        let boundingRect = imageView.bounds.applying(imageView.transform)
        let screenSize = view.bounds.size
        let widthRatio = screenSize.width / boundingRect.width
        let heightRatio = screenSize.height / boundingRect.height
        let minRatio = min(widthRatio, heightRatio)
        
        if minRatio < 1 {
            imageView.transform = imageView.transform.scaledBy(x: minRatio, y: minRatio)
        }
        
        imageView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
        triggerHapticFeedback(type: .light)
    }
    
    @objc private func doneTapped() {
        triggerHapticFeedback(type: .success)
        let userRect = cropView.cropRect
        let rectInView = cropView.convert(userRect, to: view)
        
        var totalTransform = CGAffineTransform(translationX: -imageView.frame.origin.x, y: -imageView.frame.origin.y)
        totalTransform = totalTransform.concatenating(imageView.transform.inverted())
        let rectInImageViewCoords = rectInView.applying(totalTransform)
        
        let (scale, xOffset, yOffset) = viewModel.aspectFitScaleAndOffset(for: image, in: imageView.bounds.size)
        
        let cgCropRect = CGRect(
            x: (rectInImageViewCoords.origin.x - xOffset) / scale,
            y: (rectInImageViewCoords.origin.y - yOffset) / scale,
            width: rectInImageViewCoords.width / scale,
            height: rectInImageViewCoords.height / scale
        )
        
        guard let cgImg = image.cgImage?.cropping(to: cgCropRect) else {
            delegate?.cropViewControllerDidFinish(image: image)
            dismiss(animated: true)
            return
        }
        
        let final = UIImage(cgImage: cgImg, scale: image.scale, orientation: .up)
        delegate?.cropViewControllerDidFinish(image: final)
        dismiss(animated: true)
    }
}
