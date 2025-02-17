import UIKit

final class ScanningResultViewController: UIViewController {
    
    private let viewModel: ScanningResultViewModel
    private let coordinator: ScanCoordinator
    
    
    private let navigationBar = ScanningResultNavView()
    
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
        button.layer.borderWidth = 1
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
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    private let recognizedTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        textView.font = UIFont.plusJakartaSans(.regular, size: 15)
        textView.textColor = .white
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.isHidden = true
        textView.returnKeyType = .done
        return textView
    }()
    
    private let editIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage.editIcon)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
   
    private var recognizedText: String?
    
    init(coordinator: ScanCoordinator, image: UIImage) {
        self.coordinator = coordinator
        self.viewModel = ScanningResultViewModel(image: image)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForKeyboardNotifications()
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
    
    
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(subtitleLabel)
        view.addSubview(imageView)
        view.addSubview(cropButton)
        view.addSubview(retakeButton)
        view.addSubview(continueButton)
        view.addSubview(recognizedTextView)
        view.addSubview(editIcon)
        
        imageView.image = viewModel.capturedImage
        
        setupNavigationBar()
       
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cropButton.translatesAutoresizingMaskIntoConstraints = false
        retakeButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        recognizedTextView.translatesAutoresizingMaskIntoConstraints = false
        editIcon.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            imageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35),
            imageView.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 300 : 450),
            
            
            
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            
            retakeButton.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -10),
            retakeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            retakeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            retakeButton.heightAnchor.constraint(equalToConstant: 50),
            
            cropButton.bottomAnchor.constraint(equalTo: retakeButton.topAnchor, constant: -20),
            cropButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cropButton.heightAnchor.constraint(equalToConstant: 30),
            
            
            
            recognizedTextView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            recognizedTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            recognizedTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            recognizedTextView.bottomAnchor.constraint(equalTo: retakeButton.topAnchor, constant: -20),
            editIcon.widthAnchor.constraint(equalToConstant: 20),
            editIcon.heightAnchor.constraint(equalToConstant: 20),
            editIcon.trailingAnchor.constraint(equalTo: recognizedTextView.trailingAnchor, constant: -15),
            editIcon.bottomAnchor.constraint(equalTo: recognizedTextView.bottomAnchor, constant: -15)
        ])
        
        continueButton.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor),
        ])
    }
    
    private func setupActions() {
        retakeButton.addTarget(self, action: #selector(retakeTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        cropButton.addTarget(self, action: #selector(cropTapped), for: .touchUpInside)
        recognizedTextView.delegate = self
    }
    
    @objc private func retakeTapped() {
        triggerHapticFeedback(type: .selection)
        coordinator.dismissScanningResult()
    }
    
    @objc private func backTapped() {
        triggerHapticFeedback(type: .selection)
        coordinator.dismissScanningResult()
    }
    
    @objc private func continueTapped() {
        if let recognizedText = recognizedText {
            coordinator.showSolution(with: recognizedText)
            triggerHapticFeedback(type: .success)
        }
        else {
            startRecognition()
        }
    }
    
    private func startRecognition() {
        continueButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        continueButton.isUserInteractionEnabled = false
        
        guard let image = imageView.image else { return }
        
        Task {
            do {
                let recognizedString = try await viewModel.recognizeText(from: image)
                recognizedText = recognizedString
                displayRecognizedText(recognizedString)
                triggerHapticFeedback(type: .success)
            }
            catch {
                showError("Text recogintion failed - \(error). Try another image.")
            }
            
            activityIndicator.stopAnimating()
            continueButton.setTitle("Continue", for: .normal)
            continueButton.isUserInteractionEnabled = true
        }
    }
    
    private func displayRecognizedText(_ text: String) {
        imageView.isHidden = true
        cropButton.isHidden = true
       
        recognizedTextView.isHidden = false
        recognizedTextView.text = text
        editIcon.isHidden = false
    }
    
    @objc private func cropTapped() {
        triggerHapticFeedback(type: .selection)
        let cropVC = CropViewController(image: imageView.image!, coordinator: coordinator)
        cropVC.delegate = self
        cropVC.modalPresentationStyle = .fullScreen
        present(cropVC, animated: true)
    }
    
    
    func showError(_ message: String) {
        triggerHapticFeedback(type: .error)
        let alert = UIAlertController(title: "Error:", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}

extension ScanningResultViewController: CropViewControllerDelegate {
    func cropViewControllerDidFinish(image: UIImage) {
        imageView.image = image
    }
}


extension ScanningResultViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        triggerHapticFeedback(type: .light)
        editIcon.isHidden = true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        editIcon.isHidden = false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    private func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.removeObserver(self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: 0.3) {
            self.additionalSafeAreaInsets.bottom = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            // Reset bottom safe area when keyboard hides
            self.additionalSafeAreaInsets.bottom = 0
            self.view.layoutIfNeeded()
        }
    }

}

