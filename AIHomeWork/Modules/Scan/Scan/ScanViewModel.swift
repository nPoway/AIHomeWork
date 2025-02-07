import AVFoundation
import UIKit

class ScanViewModel: NSObject {
    
    private let captureSession = AVCaptureSession()
    private var capturePhotoOutput: AVCapturePhotoOutput!
    private let cameraService = CameraService()
    
    var onPhotoCaptured: ((UIImage) -> Void)?
    var onCameraPermissionDenied: (() -> Void)?
    var onCameraReady: (() -> Void)?
    
    override init() {
        super.init()
        checkCameraPermission()
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            setupCamera()
        case .notDetermined:
            requestCameraAccess()
        case .denied, .restricted:
            onCameraPermissionDenied?()
        @unknown default:
            onCameraPermissionDenied?()
        }
    }
    
    /// Запрашиваем доступ к камере
    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.setupCamera()
                } else {
                    self?.onCameraPermissionDenied?()
                }
            }
        }
    }
    
    private func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession.beginConfiguration() // Start session setup
            
            self.captureSession.sessionPreset = .high // Faster setup than .photo
            
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("Error: No back camera found")
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: backCamera)
                if self.captureSession.canAddInput(input) {
                    self.captureSession.addInput(input)
                }
                
                self.capturePhotoOutput = AVCapturePhotoOutput()
                if self.captureSession.canAddOutput(self.capturePhotoOutput) {
                    self.captureSession.addOutput(self.capturePhotoOutput)
                }
                
                self.captureSession.commitConfiguration() // Commit changes before starting session
                self.captureSession.startRunning() // Start session
                
                DispatchQueue.main.async {
                    self.onCameraReady?()
                }
                
            } catch {
                print("Error setting up camera: \(error)")
            }
        }
    }



    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func toggleFlash(button: UIButton) {
        cameraService.toggleFlash { isFlashOn in
            let icon = isFlashOn ? "bolt.fill" : "bolt.slash"
            button.setImage(UIImage(systemName: icon), for: .normal)
        }
    }
}

extension ScanViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        onPhotoCaptured?(image)
    }
}
