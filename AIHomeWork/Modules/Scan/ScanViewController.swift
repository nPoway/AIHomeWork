import UIKit
import AVFoundation

class ScanViewController: UIViewController {
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var capturePhotoOutput: AVCapturePhotoOutput!
    
    private let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let flashButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bolt.slash"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No camera available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            capturePhotoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(capturePhotoOutput) {
                captureSession.addOutput(capturePhotoOutput)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.insertSublayer(previewLayer, at: 0)
            
            captureSession.startRunning()
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    private func setupUI() {
        let bottomControlsStack = UIStackView(arrangedSubviews: [galleryButton, captureButton, flashButton])
        bottomControlsStack.axis = .horizontal
        bottomControlsStack.distribution = .equalSpacing
        bottomControlsStack.alignment = .center
        bottomControlsStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bottomControlsStack)
        
        NSLayoutConstraint.activate([
            bottomControlsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomControlsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomControlsStack.widthAnchor.constraint(equalToConstant: 250),
            captureButton.heightAnchor.constraint(equalToConstant: 70),
            captureButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
    }
    
    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = device.torchMode == .on ? .off : .on
            flashButton.setImage(UIImage(systemName: device.torchMode == .on ? "bolt.fill" : "bolt.slash"), for: .normal)
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }
}

extension ScanViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        
        // TODO: Передача изображения в обработку
        print("Photo captured: \(image)")
    }
}
