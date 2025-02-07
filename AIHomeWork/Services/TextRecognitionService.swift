import UIKit
import Vision

// MARK: - TextRecognitionService

final class TextRecognitionService {
    
    @discardableResult
    func recognizeText(
        in image: UIImage,
        languages: [String] = ["en-US","ru-RU"]
    ) async throws -> String {
        
        guard let cgImage = image.cgImage else {
            throw TextRecognitionError.invalidImage
        }
        return try await withCheckedThrowingContinuation { continuation in
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let observations = request.results as? [VNRecognizedTextObservation],
                      !observations.isEmpty else {
                    continuation.resume(throwing: TextRecognitionError.noTextFound)
                    return
                }
                let sortedObservations = observations.sorted {
                    $0.boundingBox.minY > $1.boundingBox.minY
                }
                
                var formattedText = ""
                var previousMaxY: CGFloat = 1.0
                
                for observation in sortedObservations {
                    guard let topCandidate = observation.topCandidates(1).first else { continue }
                    let verticalSpacing = previousMaxY - observation.boundingBox.maxY
                    if verticalSpacing > 0.05 {
                        let numberOfNewLines = Int(verticalSpacing / 0.05)
                        formattedText += String(repeating: "\n\n", count: numberOfNewLines)
                    }
                    
                    let indentationCount = Int(observation.boundingBox.minX * 20)
                    let indentation = String(repeating: " ", count: max(0, indentationCount))
                    formattedText += indentation + topCandidate.string
                    
                    previousMaxY = observation.boundingBox.minY
                }
                
                continuation.resume(returning: formattedText)
            }
            
            request.recognitionLanguages = languages
            request.usesLanguageCorrection = true
            request.recognitionLevel = .accurate
           
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try requestHandler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - TextRecognitionError

enum TextRecognitionError: Error {
    case invalidImage
    case noTextFound
}
