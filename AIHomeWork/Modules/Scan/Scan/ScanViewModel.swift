import AVFoundation
import UIKit
import Photos


class ScanViewModel: NSObject {
    
    private let captureSession = AVCaptureSession()
    private var capturePhotoOutput: AVCapturePhotoOutput?
    private let cameraService = CameraService()

    
    var onPhotoCaptured: ((UIImage) -> Void)?
    var onCameraPermissionDenied: (() -> Void)?
    var onCameraReady: (() -> Void)?
    var onImageSelected: ((UIImage) -> Void)?
    
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
            
            self.captureSession.beginConfiguration()
            
            self.captureSession.sessionPreset = .high
            
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
                guard let capturePhotoOutput else { return }
                if self.captureSession.canAddOutput(capturePhotoOutput) {
                    self.captureSession.addOutput(capturePhotoOutput)
                }
                
                self.captureSession.commitConfiguration()
                self.captureSession.startRunning()
                
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
        guard let capturePhotoOutput else { return }
        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func toggleFlash(button: UIButton) {
        cameraService.toggleFlash { isFlashOn in
            let icon = isFlashOn ? "bolt.fill" : "bolt.slash"
            button.setImage(UIImage(systemName: icon), for: .normal)
        }
    }
    
    func imageSelected(_ image: UIImage) {
            onImageSelected?(image)
        }
    
    func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        default:
            completion(false)
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
