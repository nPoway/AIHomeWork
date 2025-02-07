import UIKit
import Vision

// MARK: - TextRecognitionService

final class TextRecognitionService {
    
    /// Recognizes text from the provided UIImage using Apple's Vision framework.
    /// - Parameter image: The UIImage to be recognized.
    /// - Parameter languages: An optional list of language codes (e.g., ["en-US", "ru-RU"]).
    /// - Throws: An error if recognition fails or if the request could not be performed.
    /// - Returns: A concatenated string containing all recognized text, separated by line breaks.
    @discardableResult
    func recognizeText(in image: UIImage,
                       languages: [String] = ["en-US"]) async throws -> String {
        
        // 1. Convert UIImage to CGImage
        guard let cgImage = image.cgImage else {
            throw TextRecognitionError.invalidImage
        }
        
        // 2. Create and configure the text recognition request
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = languages
        
        // (Set a specific revision if needed; defaults to latest if not set)
        // request.revision = VNRecognizeTextRequestRevision2
        
        // 3. Create the image request handler
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // 4. Perform the request
        try requestHandler.perform([request])
        
        // 5. Gather and parse results
        guard let observations = request.results as? [VNRecognizedTextObservation],
              !observations.isEmpty else {
            throw TextRecognitionError.noTextFound
        }
        
        // 6. Build the final recognized text string
        var recognizedStrings: [String] = []
        for observation in observations {
            // Get the top recognized candidate per observation
            if let topCandidate = observation.topCandidates(1).first {
                recognizedStrings.append(topCandidate.string)
            }
        }
        
        let finalText = recognizedStrings.joined(separator: "\n")
        return finalText
    }
}

// MARK: - TextRecognitionError

enum TextRecognitionError: Error {
    case invalidImage
    case noTextFound
}

// MARK: - Example Usage

/// An example of how you might call the service in an async/await context:
func exampleUsage(of service: TextRecognitionService, with image: UIImage) {
    Task {
        do {
            let recognizedText = try await service.recognizeText(in: image, languages: ["en-US", "ru-RU"])
            print("Recognized text:\n\(recognizedText)")
        } catch {
            print("Text recognition failed with error: \(error)")
        }
    }
}
