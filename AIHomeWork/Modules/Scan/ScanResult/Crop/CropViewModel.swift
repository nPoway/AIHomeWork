import UIKit
import CoreGraphics

final class CropViewModel {
    
    var currentRotation: CGFloat = 0
    var isFlippedHorizontally: Bool = false
    
    // MARK: - Rotation
    
    func rotateImage180(_ image: UIImage) -> UIImage {
        let fixed = image.fixedOrientation()
        let newSize = fixed.size
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, fixed.scale)
        guard let context = UIGraphicsGetCurrentContext(),
              let cg = fixed.cgImage else {
            UIGraphicsEndImageContext()
            return fixed
        }
        
        context.translateBy(x: 0, y: newSize.height)
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: .pi)
        context.translateBy(x: -newSize.width / 2, y: -newSize.height / 2)
        context.draw(cg, in: CGRect(origin: .zero, size: newSize))
        
        let rotated = UIGraphicsGetImageFromCurrentImageContext() ?? fixed
        UIGraphicsEndImageContext()
        return rotated
    }
    
    func rotateImageBy90(_ image: UIImage, clockwise: Bool) -> UIImage {
        let fixed = image.fixedOrientation()
        let newSize = CGSize(width: fixed.size.height, height: fixed.size.width)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, fixed.scale)
        guard let context = UIGraphicsGetCurrentContext(),
              let cg = fixed.cgImage else {
            UIGraphicsEndImageContext()
            return fixed
        }
        
        context.translateBy(x: 0, y: newSize.height)
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        let angle: CGFloat = clockwise ? .pi / 2 : -.pi / 2
        context.rotate(by: angle)
        context.translateBy(x: -fixed.size.width / 2, y: -fixed.size.height / 2)
        context.draw(cg, in: CGRect(origin: .zero, size: fixed.size))
        
        let result = UIGraphicsGetImageFromCurrentImageContext() ?? fixed
        UIGraphicsEndImageContext()
        return result
    }
    
    // MARK: - Crop Rect
    
    func computeCropRect(for ratio: CGFloat, in bounds: CGRect) -> CGRect {
        if ratio == 0 {
            return bounds
        } else {
            let width = bounds.width
            let height = width / ratio
            let x = bounds.midX - width / 2
            let y = bounds.midY - height / 2
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    func currentTransform() -> CGAffineTransform {
        var transform = CGAffineTransform(rotationAngle: currentRotation)
        if isFlippedHorizontally {
            transform = transform.scaledBy(x: -1, y: 1)
        }
        return transform
    }
    
    // MARK: - Final Crop
    
    func finalCroppedImage(
        original: UIImage,
        userRect: CGRect,
        imageViewSize: CGSize
    ) -> UIImage {
        if isNoRotationAndNoFlip() {
            return cropImage(original, userRect: userRect, imageViewSize: imageViewSize)
        }
        
        let orientedImage = rotateAndFlipImage(
            original,
            rotation: currentRotation,
            isFlippedHorizontally: isFlippedHorizontally
        )
        let cropped = cropImage(
            orientedImage,
            userRect: userRect,
            imageViewSize: imageViewSize
        )
        return cropped
    }
    
    func aspectFitScaleAndOffset(
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
        } else {
            scale = viewSize.height / imageSize.height
            let scaledWidth = imageSize.width * scale
            xOffset = (viewSize.width - scaledWidth) * 0.5
        }
        
        return (scale, xOffset, yOffset)
    }
    
    // MARK: - Private
    
    private func isNoRotationAndNoFlip() -> Bool {
        let quarterTurns = Int(round(currentRotation / (.pi / 2))) % 4
        return (quarterTurns == 0) && !isFlippedHorizontally
    }
    
    private func rotateAndFlipImage(
        _ image: UIImage,
        rotation: CGFloat,
        isFlippedHorizontally: Bool
    ) -> UIImage {
        let quarterTurns = Int(round(rotation / (.pi / 2)))
        let normalizedQuarterTurns = quarterTurns % 4
        let positiveTurns = (normalizedQuarterTurns + 4) % 4
        
        var rotatedSize = image.size
        if positiveTurns % 2 != 0 {
            rotatedSize = CGSize(width: image.size.height, height: image.size.width)
        }
        
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return image
        }
        
        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context.rotate(by: CGFloat(positiveTurns) * (.pi / 2))
        if isFlippedHorizontally {
            context.scaleBy(x: -1, y: 1)
        }
        
        let drawRect = CGRect(
            x: -image.size.width / 2,
            y: -image.size.height / 2,
            width: image.size.width,
            height: image.size.height
        )
        
        context.draw(image.cgImage!, in: drawRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private func cropImage(
        _ capturedImage: UIImage,
        userRect: CGRect,
        imageViewSize: CGSize
    ) -> UIImage {
        let flippedRect = flipRectForUIKit(userRect, imageViewSize: imageViewSize)
        let (scale, xOffset, yOffset) = aspectFitScaleAndOffset(
            for: capturedImage,
            in: imageViewSize
        )
        
        let adjustedRect = CGRect(
            x: (flippedRect.origin.x - xOffset) / scale,
            y: (flippedRect.origin.y - yOffset) / scale,
            width: flippedRect.width / scale,
            height: flippedRect.height / scale
        )
        
        guard let cgImage = capturedImage.cgImage?.cropping(to: adjustedRect) else {
            return capturedImage
        }
        return UIImage(cgImage: cgImage)
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
