import Foundation

protocol OpenAIServiceProtocol {
    func fetchAnswer(for subject: Subject, userQuestion: String, completion: @escaping (Result<String, Error>) -> Void)
    func fetchOpenTopicAnswer(_ userQuestion: String, completion: @escaping (Result<String, Error>) -> Void)
    func translateText(_ text: String, from sourceLang: String, to targetLang: String, completion: @escaping (Result<String, Error>) -> Void)
    func sendChat(messages: [OpenAIChatMessage], subject: Subject?, completion: @escaping (Result<String, Error>) -> Void)
    func getSystemPrompt(for subject: Subject) -> String
}

