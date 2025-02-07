import UIKit

final class ScanningResultViewModel {
    
    private let textRecognitionService: TextRecognitionService
    let capturedImage: UIImage
    
    init(image: UIImage, textRecognitionService: TextRecognitionService = TextRecognitionService()) {
        self.capturedImage = image
        self.textRecognitionService = textRecognitionService
    }
    
    func cropImage(userRect: CGRect, imageViewSize: CGSize) -> UIImage {
        let fixedImage = capturedImage.fixedOrientation()
        let flippedRect = flipRectForUIKit(userRect, imageViewSize: imageViewSize)
        let (scale, xOffset, yOffset) = aspectFitScaleAndOffset(
            for: fixedImage,
            in: imageViewSize
        )
        let adjustedRect = CGRect(
            x: (flippedRect.origin.x - xOffset) / scale,
            y: (flippedRect.origin.y - yOffset) / scale,
            width: flippedRect.width / scale,
            height: flippedRect.height / scale
        )
        
        guard let cgImage = fixedImage.cgImage?.cropping(to: adjustedRect) else {
            return fixedImage
        }
        return UIImage(cgImage: cgImage)
    }

    func recognizeText(from image: UIImage) async throws -> String {
        return try await textRecognitionService.recognizeText(in: image)
    }
    
    private func aspectFitScaleAndOffset(
        for image: UIImage,
        in imageViewSize: CGSize
    ) -> (scale: CGFloat, xOffset: CGFloat, yOffset: CGFloat) {
        
        let imageSize = image.size
        let viewSize = imageViewSize
        
        let imageRatio = imageSize.width / imageSize.height
        let viewRatio = viewSize.width / viewSize.height
        
        var scale: CGFloat
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        if imageRatio > viewRatio {
            scale = viewSize.width / imageSize.width
            let scaledHeight = imageSize.height * scale
            yOffset = (viewSize.height - scaledHeight) * 0.5
        }
        else {
            scale = viewSize.height / imageSize.height
            let scaledWidth = imageSize.width * scale
            xOffset = (viewSize.width - scaledWidth) * 0.5
        }
        
        return (scale, xOffset, yOffset)
    }
    
    private func flipRectForUIKit(_ rect: CGRect, imageViewSize: CGSize) -> CGRect {
        return CGRect(
            x: rect.origin.x,
            y: imageViewSize.height - rect.origin.y - rect.height,
            width: rect.width,
            height: rect.height
        )
    }
}
