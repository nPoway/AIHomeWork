import Foundation

struct OpenAIModerationResponse: Codable {
    struct Result: Codable {
        let flagged: Bool
    }
    let results: [Result]
}
