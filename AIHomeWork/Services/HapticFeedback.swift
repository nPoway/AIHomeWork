import UIKit

enum HapticFeedbackType {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case selection
}

func triggerHapticFeedback(type: HapticFeedbackType) {
    switch type {
    case .light:
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    case .medium:
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    case .heavy:
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    case .success:
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    case .warning:
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    case .error:
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    case .selection:
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
