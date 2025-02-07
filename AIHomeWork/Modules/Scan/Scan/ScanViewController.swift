import UIKit
import AVFoundation

class ScanViewController: UIViewController {
    
    private let scanView = ScanView()
    private let viewModel = ScanViewModel()
    private let coordinator: ScanCoordinator
    
    
    init(coordinator: ScanCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func loadView() {
        view = scanView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        scanView.captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        scanView.flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        scanView.navigationBar.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        viewModel.onPhotoCaptured = { image in
            print("Captured Image: \(image)")
        }
        
        viewModel.onCameraPermissionDenied = { [weak self] in
            self?.showCameraPermissionAlert()
        }

        viewModel.onCameraReady = { [weak self] in
            guard let self = self else { return }
            let previewLayer = self.viewModel.getPreviewLayer()
            previewLayer.frame = self.view.bounds
            self.view.layer.insertSublayer(previewLayer, at: 0)
        }
    }

    
    @objc
    private func capturePhoto() {
        viewModel.capturePhoto()
    }
    
    @objc
    private func toggleFlash() {
        viewModel.toggleFlash(button: scanView.flashButton)
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
        coordinator.finish()
    }
}
