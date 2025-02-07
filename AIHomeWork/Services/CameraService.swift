import AVFoundation

class CameraService {
    
    func toggleFlash(completion: @escaping (Bool) -> Void) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = device.torchMode == .on ? .off : .on
            completion(device.torchMode == .on)
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }
}
