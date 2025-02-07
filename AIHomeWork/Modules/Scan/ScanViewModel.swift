import AVFoundation
import UIKit

class ScanViewModel: NSObject {
    
    private let captureSession = AVCaptureSession()
    private var capturePhotoOutput: AVCapturePhotoOutput!
    private let cameraService = CameraService()
    
    var onPhotoCaptured: ((UIImage) -> Void)?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = .photo
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            capturePhotoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(capturePhotoOutput) {
                captureSession.addOutput(capturePhotoOutput)
            }
            
            captureSession.startRunning()
        } catch {
            print("Error setting up camera: \(error)")
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
