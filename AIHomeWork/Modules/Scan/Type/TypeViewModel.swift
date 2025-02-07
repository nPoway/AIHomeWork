import UIKit

final class TypeViewModel {
    var inputText: String = "" {
        didSet {
            onTextChanged?(inputText)
        }
    }
    
    var onTextChanged: ((String) -> Void)?
    var onButtonStateChanged: ((Bool) -> Void)?
    
    let maxCharacters = 1000
    
    func validateInput() {
        let isEnabled = !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        onButtonStateChanged?(isEnabled)
    }
}
