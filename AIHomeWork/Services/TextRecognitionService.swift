import UIKit

final class TextRecognitionService {

    private let openAI = OpenAIService()
    private let ocrSystemPrompt = """
    You are an OCR assistant. Transcribe *exactly* the visible text from the image.
    Preserve math notation; do not add commentary or solve anything.
    """

    @discardableResult
    func recognizeText(in image: UIImage) async throws -> String {
        return try await gptOCR(image)
    }

    private func gptOCR(_ image: UIImage) async throws -> String {
        guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
            throw TextRecognitionError.invalidImage
        }
        let base64 = jpegData.base64EncodedString()

        let payload: [String: Any] = [
            "model": "gpt-4o",
            "temperature": 0,
            "max_tokens": 256,
            "messages": [
                ["role": "system", "content": ocrSystemPrompt],
                ["role": "user",
                 "content": [
                    ["type": "image_url",
                     "image_url": ["url": "data:image/jpeg;base64,\(base64)",
                                   "detail": "high"]]
                 ]]
            ]
        ]

        return try await withCheckedThrowingContinuation { cont in
            openAI.performRawJSON(payload) { result in
                switch result {
                case .success(let text): cont.resume(returning: text)
                case .failure(let err):  cont.resume(throwing: err)
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
