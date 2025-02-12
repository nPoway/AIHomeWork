import UIKit

final class ScanningResultViewModel {
    
    private let textRecognitionService: TextRecognitionService
    let capturedImage: UIImage
    
    init(image: UIImage, textRecognitionService: TextRecognitionService = TextRecognitionService()) {
        let fixedImage = image.fixedOrientation()
        self.capturedImage = fixedImage
        self.textRecognitionService = textRecognitionService
    }

    func recognizeText(from image: UIImage) async throws -> String {
        return try await textRecognitionService.recognizeText(in: image)
    }
    
}
