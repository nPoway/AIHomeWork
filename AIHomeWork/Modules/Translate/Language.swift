import Foundation

struct Language {
    let name: String
    let code: String
    let flag: String

    static let supportedLanguages: [Language] = [
        Language(name: "English", code: "en", flag: "britishFlag"),
        Language(name: "Spanish", code: "es", flag: "spanishFlag"),
        Language(name: "German", code: "de", flag: "germanyFlag"),
        Language(name: "French", code: "fr", flag: "frenchFlag"),
        Language(name: "Italian", code: "it", flag: "italyFlag"),
        Language(name: "Other", code: "other", flag: "otherFlag")
    ]
}
