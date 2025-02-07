import UIKit

final class ScanningResultViewController: UIViewController {
    
    private let viewModel: ScanningResultViewModel
    private let coordinator: ScanCoordinator


    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Scanning Result"
        label.textColor = .white
        label.font = UIFont.plusJakartaSans(.semiBold, size: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your task has been scanned successfully! To get the solution, tap Solve"
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.font = UIFont.plusJakartaSans(.regular, size: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
   
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        return imageView
    }()
    
    private let cropView: CropView = {
        let cropView = CropView()
        cropView.isHidden = true
        return cropView
    }()
    
    private let cropButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        
        if let icon = UIImage.cropIcon.resizeImage(to: CGSize(width: 24, height: 24)) {
            config.image = icon
            config.imagePadding = 6
            config.baseForegroundColor = .white
            
            var title = AttributedString("Crop")
            title.font = UIFont.plusJakartaSans(.semiBold, size: 18)
            
            config.attributedTitle = title
        }
        
        button.configuration = config
        return button
    }()

    
    private let retakeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retake Photo", for: .normal)
        button.titleLabel?.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        button.setTitleColor(.white, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.customPrimary.cgColor
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.customPrimary
        button.layer.cornerRadius = 25
        return button
    }()
    
    init(coordinator: ScanCoordinator, image: UIImage) {
        self.coordinator = coordinator
        self.viewModel = ScanningResultViewModel(image: image)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = BlurredGradientView()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !cropView.isHidden {
            cropView.cropRect = cropView.bounds.insetBy(dx: 10, dy: 10)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(titleLabel)
        view.addSubview(bottomLine)
        view.addSubview(subtitleLabel)
        view.addSubview(imageView)
        view.addSubview(cropView)
        view.addSubview(cropButton)
        view.addSubview(retakeButton)
        view.addSubview(continueButton)
        
        imageView.image = viewModel.capturedImage
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cropView.translatesAutoresizingMaskIntoConstraints = false
        cropButton.translatesAutoresizingMaskIntoConstraints = false
        retakeButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bottomLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            bottomLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
           
            subtitleLabel.topAnchor.constraint(equalTo: bottomLine.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            imageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35),
            imageView.heightAnchor.constraint(equalToConstant: 450),
            
            cropView.topAnchor.constraint(equalTo: imageView.topAnchor),
            cropView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            cropView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            cropView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            cropButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            cropButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            retakeButton.topAnchor.constraint(equalTo: cropButton.bottomAnchor, constant: 20),
            retakeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            retakeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            retakeButton.heightAnchor.constraint(equalToConstant: 50),
            
            continueButton.topAnchor.constraint(equalTo: retakeButton.bottomAnchor, constant: 12),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        retakeButton.addTarget(self, action: #selector(retakeTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        cropButton.addTarget(self, action: #selector(cropTapped), for: .touchUpInside)
    }
    
    @objc private func retakeTapped() {
        coordinator.dismissScanningResult()
    }
    @objc private func continueTapped() {
            let userRect = cropView.cropRect
            
            let croppedImage = viewModel.cropImage(
                userRect: userRect,
                imageViewSize: imageView.bounds.size
            )
        imageView.image = croppedImage
            
            Task {
                do {
                    let recognizedText = try await viewModel.recognizeText(from: croppedImage)
                    print("Recognized text:\n\(recognizedText)")
                } catch {
                    print("Text recognition failed: \(error)")
                }
            }
        }
    
    @objc private func cropTapped() {
        cropView.isHidden.toggle()
    }
}
