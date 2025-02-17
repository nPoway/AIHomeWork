import Foundation

final class OpenAIService: OpenAIServiceProtocol {
    
    // MARK: - Properties
    private let session: URLSession
    private let apiKey: String
    
    // MARK: - Init
    init(session: URLSession = .shared) {
        self.session = session
        self.apiKey = gptAPIKey
    }

    // MARK: - Fetch Answer for Subject
    func fetchAnswer(for subject: Subject,
                         userQuestion: String,
                         completion: @escaping (Result<String, Error>) -> Void) {
            moderateContent(userQuestion) { [weak self] isSafe in
                guard isSafe else {
                    completion(.failure(OpenAIError.inappropriateContent))
                    return
                }
                
                guard let self = self else { return }
                let systemPrompt = self.makeSystemPrompt(for: subject)
                let messages = [
                    OpenAIChatMessage(role: "system", content: systemPrompt),
                    OpenAIChatMessage(role: "user", content: userQuestion)
                ]
                
                let requestBody = OpenAIChatRequest(
                    model: "gpt-3.5-turbo",
                    messages: messages,
                    temperature: 0.7,
                    maxTokens: 512
                )
                
                self.sendChatRequest(requestBody) { result in
                    switch result {
                    case .success(let answer):
                        self.moderateContent(answer) { isSafeAnswer in
                            guard isSafeAnswer else {
                                completion(.failure(OpenAIError.inappropriateContent))
                                return
                            }
                            completion(.success(answer))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    
    // MARK: - Open Topic Answer
    func fetchOpenTopicAnswer(_ userQuestion: String,
                                  completion: @escaping (Result<String, Error>) -> Void) {
            moderateContent(userQuestion) { [weak self] isSafe in
                guard isSafe else {
                    completion(.failure(OpenAIError.inappropriateContent))
                    return
                }
                
                guard let self = self else { return }
                let systemPrompt = """
                You are a highly knowledgeable and patient homework assistant. Your task is to provide concise, accurate, and safe answers to homework-related questions. Use clear, simple language and include step-by-step explanations and examples when necessary, but avoid unnecessary elaboration. Always verify the correctness of your response and provide context to enhance understanding. If the question is ambiguous, seek clarification or explain the assumptions you’re making. Your tone should be respectful, supportive, and engaging, ensuring that students at various levels can benefit from your explanation.
                """
                
                let messages = [
                    OpenAIChatMessage(role: "system", content: systemPrompt),
                    OpenAIChatMessage(role: "user", content: userQuestion)
                ]
                
                let requestBody = OpenAIChatRequest(
                    model: "gpt-3.5-turbo",
                    messages: messages,
                    temperature: 0.7,
                    maxTokens: 512
                )
                
                self.sendChatRequest(requestBody) { result in
                    switch result {
                    case .success(let answer):
                        self.moderateContent(answer) { isSafeAnswer in
                            guard isSafeAnswer else {
                                completion(.failure(OpenAIError.inappropriateContent))
                                return
                            }
                            completion(.success(answer))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }

    // MARK: - Translate Text
    func translateText(_ text: String,
                       from sourceLang: String,
                       to targetLang: String,
                       completion: @escaping (Result<String, Error>) -> Void) {
        moderateContent(text) { [weak self] isSafe in
            guard isSafe else {
                completion(.failure(OpenAIError.inappropriateContent))
                return
            }
           
            let systemPrompt = """
            Translate the following text from \(sourceLang) to \(targetLang).
            Provide only the translated text.
            """

            let messages = [
                OpenAIChatMessage(role: "system", content: systemPrompt),
                OpenAIChatMessage(role: "user", content: text)
            ]

            let requestBody = OpenAIChatRequest(
                model: "gpt-3.5-turbo",
                messages: messages,
                temperature: 0.2,
                maxTokens: 512
            )

            self?.sendChatRequest(requestBody) { result in
                switch result {
                case .success(let translatedText):
                    self?.moderateContent(translatedText) { isSafeTranslated in
                        guard isSafeTranslated else {
                            completion(.failure(OpenAIError.inappropriateContent))
                            return
                        }
                        completion(.success(translatedText))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    
    // MARK: - Private Methods

    private func sendChatRequest(_ body: OpenAIChatRequest,
                                 completion: @escaping (Result<String, Error>) -> Void) {
        let hasImage = shouldUseVision(for: body.messages)
        let modelName = hasImage ? "gpt-4o-mini" : body.model

        let finalJSON: [String: Any]

        if hasImage {
            let visionMessages = makeVisionMessages(from: body.messages)
            finalJSON = [
                "model": modelName,
                "messages": visionMessages.map { message -> [String: Any] in
                    return [
                        "role": message.role,
                        "content": message.content.map { part -> [String: Any] in
                            if part.type == "text" {
                                return ["type": "text", "text": part.text ?? ""]
                            } else {
                                return ["type": "image_url", "image_url": ["url": part.imageURL?.url ?? ""]]
                            }
                        }
                    ]
                },
                "max_tokens": body.maxTokens,
                "temperature": body.temperature
            ]
        } else {
            finalJSON = [
                "model": modelName,
                "messages": body.messages.map { ["role": $0.role, "content": $0.content] },
                "max_tokens": body.maxTokens,
                "temperature": body.temperature
            ]
        }

        guard let url = URL(string: OpenAIEndpoint.chatCompletions) else {
            completion(.failure(OpenAIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: finalJSON, options: [])
        } catch {
            completion(.failure(OpenAIError.requestFailed("JSON Encoding Error: \(error.localizedDescription)")))
            return
        }

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(OpenAIError.requestFailed(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(OpenAIError.noData))
                return
            }

            do {
                let responseModel = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
                if let firstChoice = responseModel.choices.first {
                    completion(.success(firstChoice.message.content))
                } else {
                    completion(.failure(OpenAIError.emptyResponse))
                }
            } catch {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Decoding failed. Raw response: \(responseString)")
                }
                completion(.failure(OpenAIError.decodingFailed))
            }
        }
        
        task.resume()
    }


   
    func makeSystemPrompt(for subject: Subject) -> String {
        switch subject {
        case .math:
            return """
            You are a dedicated math tutor with expertise spanning K-12 to early college levels. Provide clear, rigorous, and step-by-step solutions that help students understand both the methodology and the underlying concepts. Use simple, accessible language and ensure that your explanations are concise, accurate, and free of extraneous or inappropriate content.
            """
            
        case .programming:
            return """
            You are an experienced programming mentor proficient in multiple programming languages and algorithmic problem-solving. Deliver concise, well-commented code examples accompanied by clear explanations. Tailor your guidance to support beginners and intermediate learners alike, ensuring your responses are secure, efficient, and free from unsafe practices.
            """
            
        case .economics:
            return """
            You are a knowledgeable economics tutor specializing in microeconomics, macroeconomics, finance, and data interpretation. Offer insightful, clear explanations that break down complex concepts into everyday language using relevant real-world examples. Maintain an objective, respectful tone and ensure your content is appropriate for all audiences.
            """
            
        case .chemistry:
            return """
            You are a professional chemistry tutor with deep understanding of chemical reactions, organic and inorganic chemistry, and laboratory safety. Provide detailed, step-by-step explanations that emphasize clarity, scientific accuracy, and safety considerations. Keep your tone friendly, supportive, and appropriate for students at all levels.
            """
            
        case .biology:
            return """
            You are an expert biology tutor helping students explore topics such as cellular biology, genetics, anatomy, and ecology. Deliver clear, engaging explanations using simple language and age-appropriate examples. Ensure your responses are scientifically rigorous, encouraging curiosity while remaining accessible and safe.
            """
            
        case .physics:
            return """
            You are a seasoned physics tutor with expertise in classical mechanics, electromagnetism, thermodynamics, and basic quantum theory. Provide intuitive, step-by-step explanations that simplify abstract concepts with practical examples. Use accessible language and maintain clarity and safety in all your responses.
            """
            
        case .geography:
            return """
            You are an experienced geography tutor assisting students in understanding physical geography, climatology, cartography, and regional studies. Offer structured, engaging explanations enriched with real-world examples and visual references when applicable. Ensure your content remains accessible and friendly for a wide range of learners.
            """
            
        case .history:
            return """
            You are a well-informed history tutor with a broad understanding of global historical events and cultural contexts. Provide accurate, balanced, and context-rich explanations, ensuring sensitivity to diverse perspectives. Present the information in a clear, structured manner without including explicit or mature content.
            """
            
        case .grammar:
            return """
            You are a skilled grammar and writing tutor dedicated to refining language skills. Offer precise corrections, clear explanations of grammatical rules, and constructive suggestions for improved phrasing. Keep your tone supportive, concise, and entirely family-friendly.
            """
            
        case .writeEssay:
            return """
            You are an expert essay-writing assistant who guides students in developing well-organized, persuasive, and coherent essays. Provide detailed advice on thesis formulation, paragraph structure, and argumentative techniques. Your recommendations should be constructive, practical, and safe for all audiences.
            """
            
        case .translate:
            return """
            You are a proficient translation assistant fluent in multiple languages. Accurately translate the user’s text, preserving the original context, tone, and nuances. Deliver only the translated text without any commentary, ensuring clarity and appropriateness for a general audience.
            """
        }
        
    }
}

extension OpenAIService {
    
    // MARK: - Send Chat with Full Context
    func sendChat(messages: [OpenAIChatMessage], completion: @escaping (Result<String, Error>) -> Void) {
            guard !messages.isEmpty else {
                completion(.failure(OpenAIError.requestFailed("Cannot send an empty message array.")))
                return
            }
            
            let userMessages = messages.filter { $0.role == "user" }
            let dispatchGroup = DispatchGroup()
            var moderationFailed = false
            
            for message in userMessages {
                dispatchGroup.enter()
                moderateContent(message.content) { isSafe in
                    if !isSafe { moderationFailed = true }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                guard moderationFailed == false else {
                    completion(.failure(OpenAIError.inappropriateContent))
                    return
                }
                
                guard let self = self else { return }
                let requestBody = OpenAIChatRequest(
                    model: "gpt-3.5-turbo",
                    messages: messages,
                    temperature: 0.7,
                    maxTokens: 512
                )
                self.sendChatRequest(requestBody, completion: completion)
            }
        }

    
    private func moderateContent(_ text: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/moderations") else {
            completion(true)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body = ["input": text]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            completion(true)
            return
        }

        let task = session.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(true)
                return
            }

            do {
                let result = try JSONDecoder().decode(OpenAIModerationResponse.self, from: data)
                let flagged = result.results.contains { $0.flagged }
                completion(!flagged)
            } catch {
                completion(true)
            }
        }

        task.resume()
    }

}

extension OpenAIService {
    func getSystemPrompt(for subject: Subject) -> String {
        return makeSystemPrompt(for: subject)
    }
    
    private func shouldUseVision(for messages: [OpenAIChatMessage]) -> Bool {
        return messages.contains { $0.imageURL != nil }
    }
    
    private func makeVisionMessages(from messages: [OpenAIChatMessage]) -> [VisionChatMessage] {
        return messages.map { msg in
            var parts: [VisionMessagePart] = []
            
            if !msg.content.isEmpty {
                parts.append(
                    VisionMessagePart(type: "text",
                                      text: msg.content,
                                      imageURL: nil)
                )
            }
           
            if let imageURL = msg.imageURL, !imageURL.isEmpty {
                parts.append(
                    VisionMessagePart(type: "image_url",
                                      text: nil,
                                      imageURL: ImageURL(url: imageURL))
                )
            }
           
            
            return VisionChatMessage(role: msg.role, content: parts)
        }
    }

}
