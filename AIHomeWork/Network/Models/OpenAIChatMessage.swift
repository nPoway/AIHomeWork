import Foundation

struct OpenAIChatMessage: Codable {
    let role: String
    var content: String
    
    var imageURL: String?
    
    var isLoading: Bool = false
    
    var isHidden: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case role, content, imageURL
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

struct VisionMessagePart: Encodable {
    let type: String
    let text: String?
    let imageURL: ImageURL?

    enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageURL = "image_url"
    }
}

struct ImageURL: Encodable {
    let url: String
}

struct VisionChatMessage: Encodable {
    let role: String
    let content: [VisionMessagePart]
}
