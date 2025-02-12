import Foundation

final class TranslateViewModel {
    
    // MARK: - Properties
    private let openAIService: OpenAIServiceProtocol
    
    private(set) var sourceLanguage: Language
    private(set) var targetLanguage: Language
    private(set) var inputText: String = "" {
        didSet {
            onTextChanged?(inputText)
        }
    }
    private(set) var translatedText: String = "" {
        didSet {
            onTranslationChanged?(translatedText)
        }
    }
    
    var onTextChanged: ((String) -> Void)?
    var onTranslationChanged: ((String) -> Void)?
    var onLanguagesSwapped: (() -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onErrorOccurred: ((String) -> Void)?
    
    // MARK: - Init
    init(openAIService: OpenAIServiceProtocol,
         defaultSource: Language = .init(name: "English", code: "en", flag: "britishFlag"),
         defaultTarget: Language = .init(name: "French", code: "fr", flag: "frenchFlag")) {
        self.openAIService = openAIService
        self.sourceLanguage = defaultSource
        self.targetLanguage = defaultTarget
    }
    
    // MARK: - Methods
    
    func updateInputText(_ text: String) {
        guard text.count <= 1000 else { return }
        inputText = text
    }
    
    func swapLanguages() {
        (sourceLanguage, targetLanguage) = (targetLanguage, sourceLanguage)
        onLanguagesSwapped?()
    }
    
    func translate() {
        guard !inputText.isEmpty else {
            translatedText = ""
            return
        }
        
        onLoadingStateChanged?(true)
        
        openAIService.translateText(
            inputText,
            from: sourceLanguage.code,
            to: targetLanguage.code
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingStateChanged?(false)
                
                switch result {
                case .success(let translated):
                    self?.translatedText = translated
                case .failure(let error as OpenAIError):
                    let errorMessage = "Translation failed: \(error.localizedDescription)"
                    self?.onErrorOccurred?(errorMessage)
                case .failure(let error):
                    self?.onErrorOccurred?("Unexpected error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func updateLanguage(isSource: Bool, newLanguage: Language) {
        if isSource {
            sourceLanguage = newLanguage
        } else {
            targetLanguage = newLanguage
        }
    }
}
