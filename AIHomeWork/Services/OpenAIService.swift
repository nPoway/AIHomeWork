import Foundation

final class OpenAIService: OpenAIServiceProtocol {
    
    // MARK: - Properties
    private let session: URLSession
    private let apiKey: String
    
    
    private let openTopicSubject = #"""
    You are a highly knowledgeable and patient homework assistant. Your task is to provide concise, accurate, and safe answers to homework‑related questions. Use clear, simple language and include step‑by‑step explanations and examples when necessary, but avoid unnecessary elaboration. Always verify the correctness of your response and provide context to enhance understanding. If the question is ambiguous, seek clarification or explain the assumptions you’re making. Your tone should be respectful, supportive, and engaging, ensuring that students at various levels can benefit from your explanation.

    If the user’s question involves mathematics and can be clarified with LaTeX formulas, apply the following rules **strictly**:

    IMPORTANT MARKUP RULES:
    1. Introduce extra blank lines or Markdown code fences **only** when you include a formula.  
        • **Display formulas** must stand alone in their own block, wrapped **exactly** in triple backticks labeled `latex`, with no other text on the same lines:  
        ```latex  
        \int_{0}^{\infty} e^{-x^2}\,dx = \frac{\sqrt{\pi}}{2}  
        ```  
        • **Inline formulas** must appear within a sentence, wrapped in single backticks prefixed by `math:`, with **no spaces** after the colon, e.g. `math:\sin(x)/x`.

    2. **Use formulas only when absolutely necessary.** If the idea is clear in plain words or simple algebra, describe it without any fences.

    3. If your answer contains no formulas, do **not** use backticks, code fences, headings, lists, or other Markdown. Return plain continuous text only.

    4. Do **not** insert unnecessary blank lines, headings, bold/italic markers, or lists—keep prose simple unless a formula block or inline formula is required.

    5. Do **not** use Markdown headings (`#`, `##`), blockquotes (`>`), or any Markdown beyond the exact fences/backticks for formulas.

    6. **Never place punctuation** (period, comma, colon, semicolon) on its own line immediately after a formula block or inline formula. Attach punctuation to the same line or sentence.

    7. **Keep formula blocks and surrounding text “glued” in a single thought.**  
        • Example for a block formula: “Solve for x: ```latex …``` then continue the explanation…”.  
        • Inline formulas remain inside the same sentence without forcing a line break.

    8. **Do not insert explicit newline characters** inside a sentence or between a sentence and its formula. Each sentence (including any inline formula) must be one continuous line unless UI width forces wrapping.

    9. **No lists, numbering, or bullet points** in explanations—use connected prose with conjunctions.

    Follow these instructions **exactly** in every response.
    """#

    
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
                    model: "gpt-4o",
                    messages: messages,
                    temperature: 0.2,
                    maxTokens: 512
                )
                
                self.sendChatRequest(requestBody, subject: getSystemPrompt(for: subject)) { result in
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
                let systemPrompt = openTopicSubject
                
                let messages = [
                    OpenAIChatMessage(role: "system", content: systemPrompt),
                    OpenAIChatMessage(role: "user", content: userQuestion)
                ]
                
                let requestBody = OpenAIChatRequest(
                    model: "gpt-3.5-turbo",
                    messages: messages,
                    temperature: 0.2,
                    maxTokens: 512
                )
                
                self.sendChatRequest(requestBody, subject: systemPrompt) { result in
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

            self?.sendChatRequest(requestBody, subject: systemPrompt) { result in
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

    private func sendChatRequest(
        _ body: OpenAIChatRequest, subject: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard shouldUseVision(for: body.messages) else {
            let json: [String: Any] = [
                "model": body.model,
                "messages": body.messages.map { ["role": $0.role, "content": $0.content] },
                "max_tokens": body.maxTokens,
                "temperature": body.temperature
            ]
            print(json)
            performOpenAIRequest(json, completion: completion)
            return
        }

        guard let imgURL = body.messages.first(where: { $0.imageURL != nil })?.imageURL else {
            completion(.failure(OpenAIError.requestFailed("Image URL not found."))); return
        }

        let ocrPayload = buildVisionOCRPayload(imageURL: imgURL)

        performOpenAIRequest(ocrPayload) { [weak self] ocrResult in
            switch ocrResult {
            case .failure(let err):
                completion(.failure(err))

            case .success(let problemText):
                guard let self else { return }

                let textMessages = [
                    OpenAIChatMessage(role: "system",
                                      content: subject),
                    OpenAIChatMessage(role: "user", content: problemText)
                ]
                let solveJSON: [String: Any] = [
                    "model": "gpt-4o",
                    "messages": textMessages.map { ["role": $0.role, "content": $0.content] },
                    "max_tokens": 1024,
                    "temperature": 0.2
                ]
                self.performOpenAIRequest(solveJSON, completion: completion)
            }
        }
    }
    
    private func performOpenAIRequest(
        _ payload: [String: Any],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: OpenAIEndpoint.chatCompletions) else {
            completion(.failure(OpenAIError.invalidURL)); return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        do { req.httpBody = try JSONSerialization.data(withJSONObject: payload) }
        catch { completion(.failure(error)); return }

        session.dataTask(with: req) { data, _, err in
            if let err = err { completion(.failure(err)); return }
            guard let data else { completion(.failure(OpenAIError.noData)); return }

            do {
                let resp = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
                if let first = resp.choices.first?.message.content {
                    completion(.success(first))
                } else {
                    completion(.failure(OpenAIError.emptyResponse))
                }
            } catch { completion(.failure(OpenAIError.decodingFailed)) }
        }.resume()
    }

    private func buildVisionOCRPayload(imageURL: String) -> [String: Any] {
        [
            "model": "gpt-4o",
            "temperature": 0,
            "max_tokens": 256,
            "messages": [
                [
                    "role": "system",
                    "content": """
                    You are an OCR assistant. Transcribe task or math from the image exactly.
                    Do not solve it or add any commentary.
                    """
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image_url",
                            "image_url": ["url": imageURL, "detail": "high"]
                        ]
                    ]
                ]
            ]
        ]
    }
}

extension OpenAIService {
    
    func sendChat(
        messages: [OpenAIChatMessage],
        subject: Subject?,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard !messages.isEmpty else {
            completion(.failure(OpenAIError.requestFailed("Cannot send an empty message array.")))
            return
        }

        let userMessages = messages.filter { $0.role == "user" }
        let group = DispatchGroup()
        var moderationFailed = false

        for msg in userMessages {
            group.enter()
            moderateContent(msg.content) { isSafe in
                if !isSafe { moderationFailed = true }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard moderationFailed == false else {
                completion(.failure(OpenAIError.inappropriateContent))
                return
            }
            guard let self else { return }

            var enrichedMessages = messages

            let systemPrompt: String = {
                if let subject { return self.getSystemPrompt(for: subject) }
                else            { return self.openTopicSubject }
            }()

            if enrichedMessages.first?.role != "system" {
                let systemMsg = OpenAIChatMessage(role: "system", content: systemPrompt)
                enrichedMessages.insert(systemMsg, at: 0)
            }

            let requestBody = OpenAIChatRequest(
                model: "gpt-3.5-turbo",
                messages: enrichedMessages,
                temperature: 0.7,
                maxTokens: 512
            )

            self.sendChatRequest(requestBody, subject: systemPrompt, completion: completion)
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
    
    func makeSystemPrompt(for subject: Subject) -> String {
        switch subject {
        case .math:
            return #"""
            You are a dedicated math tutor with expertise spanning K-12 through early college. Provide clear, concise, step-by-step explanations in simple, accessible language. Use only short paragraphs (1–3 sentences) and minimal blank lines.

            IMPORTANT MARKUP RULES:
            1. Only introduce extra blank lines or Markdown code fences when you include a formula.
               - **Display formulas** must stand alone in their own block, wrapped **exactly** in triple backticks labeled `latex`, without any surrounding text on the same lines.
                 ```latex
                 \int_{0}^{\infty} e^{-x^2}\,dx = \frac{\sqrt{\pi}}{2}
                 ```
               - **Inline formulas** must appear inline within a sentence, wrapped in single backticks prefixed by `math:`, with **no spaces** before or after the colon, e.g. `math:\sin(x)/x`
            

            2. **Use formulas only when absolutely necessary.** If a concept can be conveyed clearly in plain words or simple algebraic notation, keep it in prose without any fences.

            3. If your answer contains no formulas, do **not** use any backticks, code fences, headings (`#`, `##`, etc.), lists, or other Markdown. Return plain, continuous text with normal sentence breaks only.

            4. Do **not** insert unnecessary blank lines, headings, bold/italic markers (`**`, `*`), or lists—keep the format as simple continuous prose unless a formula block or inline formula is required.

            5. Do **not** use Markdown headings (`#`, `##`), blockquotes (`>`), or any other Markdown beyond exactly the code fences/backticks for formulas.

            6. **Never place punctuation** (period, comma, colon, semicolon) **on its own line** immediately after a formula block or inline formula. Always attach punctuation to the end of the same line or sentence that contains the formula.

            7. **Keep formula blocks and surrounding text “glued” in a single thought.**
               - If you introduce a block formula, write for example:
                 “Solve for x: ```latex …``` then continue the explanation…”
               - Inline formulas must remain inside the same sentence without forcing a line break.

            8. **Do not insert explicit newline characters inside a sentence or between a sentence and its formula.**
               - Each sentence, including any inline formula, must be output as one continuous line (unless it exceeds UI width).
               - Do not start a new paragraph or list item just to print a formula or its explanation.

            9. **No lists, numbering, or bullet points in explanations**—use connected prose with conjunctions.

            Follow these instructions **exactly** in every response.
            """#


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

    /// Отправляет готовый JSON‑словарь; возвращает `content` первого choice.
    func performRawJSON(
        _ payload: [String: Any],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: OpenAIEndpoint.chatCompletions) else {
            completion(.failure(OpenAIError.invalidURL)); return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        do { req.httpBody = try JSONSerialization.data(withJSONObject: payload) }
        catch { completion(.failure(error)); return }

        session.dataTask(with: req) { data, _, err in
            if let err = err { completion(.failure(err)); return }
            guard let data else { completion(.failure(OpenAIError.noData)); return }

            do {
                let resp = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
                if let text = resp.choices.first?.message.content {
                    completion(.success(text))
                } else {
                    completion(.failure(OpenAIError.emptyResponse))
                }
            } catch { completion(.failure(OpenAIError.decodingFailed)) }
        }.resume()
    }
}
