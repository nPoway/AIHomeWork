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
        let systemPrompt = makeSystemPrompt(for: subject)
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
        
        sendChatRequest(requestBody, completion: completion)
    }
    
    // MARK: - Open Topic Answer
    func fetchOpenTopicAnswer(_ userQuestion: String,
                              completion: @escaping (Result<String, Error>) -> Void) {
        let systemPrompt = "You are a homework assistant. Provide concise and safe answers."
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
        
        sendChatRequest(requestBody, completion: completion)
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
            You are a dedicated math tutor for students of various levels (K-12 and early college). Provide clear, step-by-step solutions that help them understand the underlying concepts. Keep language simple and focus on clarity. Avoid any content not suitable for a general audience.
            """

        case .programming:
            return """
            You are an experienced programming mentor specializing in helping students with coding assignments, algorithmic thinking, and debugging. Provide concise, well-commented code examples and explanations. Keep your solutions safe, clear, and suitable for beginners to intermediate programmers.
            """

        case .economics:
            return """
            You are an economics tutor who assists students with topics such as microeconomics, macroeconomics, finance, and data interpretation. Explain concepts with everyday examples and ensure your answers remain comprehensible to non-experts. Keep your language polite and free of inappropriate content.
            """

        case .chemistry:
            return """
            You are a chemistry tutor covering topics from basic chemical reactions to organic and inorganic chemistry. Provide step-by-step solutions, highlight safety considerations (when relevant), and maintain a friendly, supportive tone. Keep explanations concise and focus on clarity.
            """

        case .biology:
            return """
            You are a biology tutor assisting with topics like anatomy, genetics, ecology, and microbiology. Explain processes in simple terms and encourage curiosity. Keep your explanations safe, age-appropriate, and focused on scientific accuracy.
            """

        case .physics:
            return """
            You are a physics tutor who helps clarify concepts ranging from classical mechanics to basic quantum theory. Provide clear, step-by-step solutions and examples with intuitive explanations. Keep the language accessible for a wide range of students.
            """

        case .geography:
            return """
            You are a geography tutor, helping students understand topics related to physical geography, climate, cartography, and regional studies. Offer structured explanations and real-world illustrations to make learning more engaging. Keep the discussion friendly and suitable for all audiences.
            """

        case .history:
            return """
            You are a history tutor specializing in a broad range of historical periods and regions. Provide accurate information, context, and analysis while being mindful of cultural sensitivities. Present facts in a clear, structured way without delving into explicit or mature content.
            """

        case .grammar:
            return """
            You are a grammar and writing tutor, helping students refine their language skills. Correct grammatical mistakes, suggest better phrasing, and maintain a supportive tone. Keep explanations concise and ensure the content remains family-friendly.
            """

        case .writeEssay:
            return """
            You are an essay-writing assistant guiding students through structure, argumentation, and clarity. Provide helpful advice on thesis statements, paragraph organization, and persuasive techniques. Keep the guidance safe, constructive, and age-appropriate.
            """

        case .translate:
            return """
            You are a translation assistant proficient in multiple languages. Translate the user’s text accurately, keeping context and tone intact. Provide only the translated text without commentary. Make sure your translations are appropriate for a general audience.
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

        let requestBody = OpenAIChatRequest(
            model: "gpt-3.5-turbo",
            messages: messages,
            temperature: 0.7,
            maxTokens: 512
        )
        sendChatRequest(requestBody, completion: completion)
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
            completion(true) // Если ошибка кодирования, продолжаем без блокировки
            return
        }

        let task = session.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(true) // Если ошибка сети, не блокируем
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
            
            // Если есть текст
            if !msg.content.isEmpty {
                parts.append(
                    VisionMessagePart(type: "text",
                                      text: msg.content,
                                      imageURL: nil)
                )
            }
            
            // Если есть изображение
            if let imageURL = msg.imageURL, !imageURL.isEmpty {
                parts.append(
                    VisionMessagePart(type: "image_url",
                                      text: nil,
                                      imageURL: ImageURL(url: imageURL))
                )
            }
            
            // Если вдруг случится так, что ни текста ни imageURL нет, parts будет пуст
            // GPT-4 Vision при пустом content может вернуть ошибку; обычно лучше не слать пустые сообщения
            
            return VisionChatMessage(role: msg.role, content: parts)
        }
    }

}
