import Foundation

enum OpenAIError: Error, CustomStringConvertible, Equatable {
    case invalidURL
    case noData
    case emptyResponse
    case decodingFailed
    case requestFailed(String)
    case inappropriateContent

    var description: String {
            switch self {
            case .invalidURL:
                return "Invalid API URL. Please check your request."
            case .noData:
                return "No data received from server. The server might be down."
            case .emptyResponse:
                return "Server returned an empty response. Please try again."
            case .decodingFailed:
                return "Failed to decode server response. Check API response format."
            case .requestFailed(let message):
                return "Request failed: \(message)"
            case .inappropriateContent:
                return "The input text contains inappropriate content. Try another message"
            }
        }
        
        var localizedDescription: String {
            return description
        }
}
