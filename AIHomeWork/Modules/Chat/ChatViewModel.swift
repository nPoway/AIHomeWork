import Foundation

final class ChatViewModel {
    
    private let openAIService: OpenAIServiceProtocol
    private(set) var messages: [OpenAIChatMessage] = []
    let currentSubject: Subject?
    
    var visibleMessages: [OpenAIChatMessage] {
        messages.filter { msg in
            (msg.role == "user" || msg.role == "assistant" || msg.role == "date") && !msg.isHidden
        }
    }

    var onMessagesUpdate: (() -> Void)?
    var onErrorOccurred: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    init(openAIService: OpenAIServiceProtocol, subject: Subject? = nil, isInitMessageVisible: Bool = true) {
        self.openAIService = openAIService
        self.currentSubject = subject
        if isInitMessageVisible {
            setupInitialSystemMessage()
        }
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
        
        let welcomeText: String
        if let subject = currentSubject {
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

    
    func userDidSendMessage(_ text: String, showInChat: Bool = true) {
        guard !text.isEmpty else { return }
        
        var userMessage = OpenAIChatMessage(role: "user", content: text, isLoading: false)
            if !showInChat {
                userMessage.isHidden = true
            }
            messages.append(userMessage)
            if showInChat {
                onMessagesUpdate?()
            }
        
        let filteredMessagesForAPI = messages.filter { msg in
                msg.role == "user" ||
                msg.role == "assistant" ||
                msg.role == "system"
            }
        
        onLoadingStateChanged?(true)
        
        openAIService.sendChat(messages: filteredMessagesForAPI) { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingStateChanged?(false)
                
                switch result {
                case .success(let assistantReply):
                    self?.updateAssistantLoadingMessage(with: assistantReply)
                    
                case .failure(let error):
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

    func addAssistantLoadingMessage() {
        let loadingMessage = OpenAIChatMessage(role: "assistant", content: "", isLoading: true)
        messages.append(loadingMessage)
        onMessagesUpdate?()
    }
    
    func updateAssistantLoadingMessage(with text: String) {
        if let lastIndex = messages.lastIndex(where: { $0.role == "assistant" && $0.isLoading }) {
            messages[lastIndex].content = text
            messages[lastIndex].isLoading = false
            onMessagesUpdate?()
        }
        else {
            let newMessage = OpenAIChatMessage(role: "assistant", content: text, isLoading: false)
            messages.append(newMessage)
            onMessagesUpdate?()
        }
    }
    
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
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            let dayMonth = formatter.string(from: date)
            return "Today, \(dayMonth)"
            
        } else if calendar.isDateInYesterday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            let dayMonth = formatter.string(from: date)
            return "Yesterday, \(dayMonth)"
            
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
    
    func saveChatSession() {
        guard let firstUserMessage = messages.first(where: { $0.role == "user" && !$0.content.isEmpty }) else {
            print("No messages to save")
            return
        }
        let subjectTitle = currentSubject?.title ?? "AI Chat"
        
        let chatSession = RealmChatSession(subject: subjectTitle, firstQuestion: firstUserMessage.content)
        
        do {
            let repository = RealmChatSessionRepository()
            try repository.create(session: chatSession)
            print("Saved succesfully")
        }
        catch {
            print("Error while saving chat session: \(error)")
            onErrorOccurred?("Error while saving chat session: \(error.localizedDescription)")
        }
    }
    
}

extension ChatViewModel {
    func clearMessagesForExplanation() {
        messages.removeAll()
        onMessagesUpdate?()
    }
}
