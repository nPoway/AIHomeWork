import Foundation

struct OpenAIChatMessage: Codable {
    let role: String
    var content: String
    
    // Not part of the JSON. We'll set or clear this only in our Swift code.
    var isLoading: Bool = false
    
    // Add CodingKeys to ignore `isLoading` so it won't break decoding:
    private enum CodingKeys: String, CodingKey {
        case role
        case content
        // No isLoading key, so decoding won't expect it.
    }
}


struct OpenAIChatRequest: Codable {
    let model: String
    let messages: [OpenAIChatMessage]
    let temperature: Double
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}
