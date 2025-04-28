import UIKit
import AVFoundation
import PhotosUI

class ScanViewController: UIViewController {
    
    private let scanView = ScanView()
    private let viewModel = ScanViewModel()
    private let coordinator: ScanCoordinator
    
    private let showCustomNavBar: Bool
    
    init(coordinator: ScanCoordinator, showCustomNavBar: Bool = false) {
        self.coordinator = coordinator
        self.showCustomNavBar = showCustomNavBar
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    
    override func loadView() {
        view = scanView
        if showCustomNavBar {
            scanView.setupNavigationBar()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        scanView.captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        scanView.flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        scanView.galleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        scanView.navigationBar.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        viewModel.onPhotoCaptured = { [weak self] image in
            guard let self = self else { return }
            if showCustomNavBar {
                coordinator.finishWithImage(image)
            }
            else {
                self.coordinator.showScanningResult(with: image)
            }
        }
        
        viewModel.onCameraPermissionDenied = { [weak self] in
            self?.showCameraPermissionAlert()
        }
        
        viewModel.onImageSelected = { [weak self] image in
            guard let self = self else { return }
            if showCustomNavBar {
                coordinator.finishWithImage(image)
            }
            else {
                coordinator.showScanningResult(with: image)
            }
        }
        
        viewModel.onCameraReady = { [weak self] in
            guard let self = self else { return }
            let previewLayer = self.viewModel.getPreviewLayer()
            previewLayer.frame = self.view.bounds
            self.view.layer.insertSublayer(previewLayer, at: 0)
            UIView.animate(withDuration: 0.3) {
                self.scanView.cameraBackground.alpha = 0
                self.scanView.darkOverlay.alpha = 0
            }
        }
    }
    
    
    @objc
    private func capturePhoto() {
        if PaywallService.shared.isPaywallNeeded() {
            coordinator.presentPaywall()
        }
        else {
            triggerHapticFeedback(type: .selection)
            viewModel.capturePhoto()
        }
    }
    
    @objc
    private func toggleFlash() {
        triggerHapticFeedback(type: .selection)
        viewModel.toggleFlash(button: scanView.flashButton)
    }
    
    @objc
    private func openGallery() {
        triggerHapticFeedback(type: .selection)
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Denied",
            message: "Allow camera access in settings to use this feature.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    
    @objc
    private func backTapped() {
        triggerHapticFeedback(type: .selection)
        coordinator.finish()
    }
}

extension ScanViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { image, _ in
            if let selectedImage = image as? UIImage {
                DispatchQueue.main.async {
                    self.viewModel.imageSelected(selectedImage)
                }
            }
        }
    }
}
