import Foundation

final class ChatViewModel {
    
    private let openAIService: OpenAIServiceProtocol
    private(set) var messages: [OpenAIChatMessage] = []
    let currentSubject: Subject?
    
    var visibleMessages: [OpenAIChatMessage] {
        messages.filter { msg in
            msg.role == "user" ||
            msg.role == "assistant" ||
            msg.role == "date"
        }
    }

    
    // Callbacks for ViewController
    var onMessagesUpdate: (() -> Void)?
    var onErrorOccurred: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    init(openAIService: OpenAIServiceProtocol, subject: Subject? = nil) {
        self.openAIService = openAIService
        self.currentSubject = subject
        setupInitialSystemMessage()
    }
    
    private func setupInitialSystemMessage() {
        let now = Date()
        let dateString = formattedDateString(from: now)
        let dateMessage = OpenAIChatMessage(role: "date", content: dateString, isLoading: false)
        messages.append(dateMessage)
        
        let systemContent: String
        if let subject = currentSubject {
            systemContent = openAIService.getSystemPrompt(for: subject)
        } else {
            systemContent = "You are a helpful homework assistant. Provide concise and safe answers."
        }
        let systemMessage = OpenAIChatMessage(role: "system", content: systemContent, isLoading: false)
        messages.append(systemMessage)
        
        // 3) Add a *visible* assistant "welcome" message the user sees
        let welcomeText: String
        if let subject = currentSubject {
            // Example: incorporate subject title
            welcomeText = """
            Hello! I'm your \(subject.title) Tutor!
            Let me know the topic you'd like assistance with, and I'll be happy to help.
            """
        } else {
            welcomeText = """
            Hello! I'm your AI Tutor!
            Let me know the subject and topic you'd like assistance with, and I'll be happy to help.
            """
        }
        let welcomeMessage = OpenAIChatMessage(role: "assistant", content: welcomeText, isLoading: false)
        messages.append(welcomeMessage)
    }

    
    func userDidSendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        // Add user's message
        let userMessage = OpenAIChatMessage(role: "user", content: text, isLoading: false)
        messages.append(userMessage)
        onMessagesUpdate?()
        
        let filteredMessagesForAPI = messages.filter { msg in
                msg.role == "user" ||
                msg.role == "assistant" ||
                msg.role == "system"
            }
        
        // Start requesting assistant’s response
        onLoadingStateChanged?(true)
        
        openAIService.sendChat(messages: filteredMessagesForAPI) { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingStateChanged?(false)
                
                switch result {
                case .success(let assistantReply):
                    // Replace the last "loading" bubble with final text
                    self?.updateAssistantLoadingMessage(with: assistantReply)
                    
                case .failure(let error):
                    // Remove the loading bubble or show an error
                    self?.removeAssistantLoadingMessage()
                    self?.onErrorOccurred?(error.localizedDescription)
                }
            }
        }
    }
    
    func userDidSendImageAndText(imageURL: String, text: String) {
        let userMessage = OpenAIChatMessage(
            role: "user",
            content: text,
            imageURL: imageURL,
            isLoading: false
        )
        messages.append(userMessage)
        onMessagesUpdate?()
        
        let filteredMessagesForAPI = messages.filter {
            $0.role == "user" || $0.role == "assistant" || $0.role == "system"
        }
        
        onLoadingStateChanged?(true)
        
        openAIService.sendChat(messages: filteredMessagesForAPI) { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingStateChanged?(false)
                
                switch result {
                case .success(let assistantReply):
                    self?.updateAssistantLoadingMessage(with: assistantReply)
                case .failure(let error):
                    print("Chat API Error: \(error.localizedDescription)")
                    self?.removeAssistantLoadingMessage()
                    self?.onErrorOccurred?(error.localizedDescription)
                }
            }
        }

    }


    
    /// Insert an “assistant loading” message as soon as the user sends a message
    func addAssistantLoadingMessage() {
        let loadingMessage = OpenAIChatMessage(role: "assistant", content: "", isLoading: true)
        messages.append(loadingMessage)
        onMessagesUpdate?()
    }
    
    /// Once the assistant’s result arrives, replace the loading bubble’s content
    func updateAssistantLoadingMessage(with text: String) {
        // Find the last loading message from the assistant
        if let lastIndex = messages.lastIndex(where: { $0.role == "assistant" && $0.isLoading }) {
            messages[lastIndex].content = text
            messages[lastIndex].isLoading = false
            onMessagesUpdate?()
        } else {
            // If for some reason we didn't find it, just append a new one
            let newMessage = OpenAIChatMessage(role: "assistant", content: text, isLoading: false)
            messages.append(newMessage)
            onMessagesUpdate?()
        }
    }
    
    /// If an error occurs, remove the loading bubble
    func removeAssistantLoadingMessage() {
        if let lastIndex = messages.lastIndex(where: { $0.role == "assistant" && $0.isLoading }) {
            messages.remove(at: lastIndex)
            onMessagesUpdate?()
        }
    }
    
    func clearChat() {
        messages.removeAll()
        setupInitialSystemMessage()
        onMessagesUpdate?()
    }
    
    private func formattedDateString(from date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            // e.g. "Today, January 10"
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d" // "January 10"
            let dayMonth = formatter.string(from: date)
            return "Today, \(dayMonth)"
            
        } else if calendar.isDateInYesterday(date) {
            // e.g. "Yesterday, January 9"
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d" // "January 9"
            let dayMonth = formatter.string(from: date)
            return "Yesterday, \(dayMonth)"
            
        } else {
            // e.g. "January 8, 2025"
            let formatter = DateFormatter()
            formatter.dateStyle = .medium  // "Jan 8, 2025" in US locale
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }

}
