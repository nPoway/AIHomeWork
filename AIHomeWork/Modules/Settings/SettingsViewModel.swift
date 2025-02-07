import UIKit
import StoreKit

final class SettingsViewModel {
    
    struct SettingsOption {
        let title: String
        let icon: UIImage?
        let action: () -> Void
    }
    
    var openURL: ((URL) -> Void)?
    var presentActivity: ((UIActivityViewController) -> Void)?
    var requestReview: (() -> Void)?
    
    lazy var settingsOptions: [SettingsOption] = [
        SettingsOption(title: "Terms of Use", icon: UIImage.termsIcon, action: { [weak self] in self?.openTermsOfUse() }),
        SettingsOption(title: "Privacy Policy", icon: UIImage.privacyIcon, action: { [weak self] in self?.openPrivacyPolicy() }),
        SettingsOption(title: "Rate Us", icon: UIImage.rateIcon, action: { [weak self] in self?.rateApp() }),
        SettingsOption(title: "Share App", icon: UIImage.shareIcon, action: { [weak self] in self?.shareApp() })
    ]
    
    private func openTermsOfUse() {
        if let url = URL(string: "https://policies.google.com/terms") {
            openURL?(url)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://policies.google.com/privacy") {
            openURL?(url)
        }
    }
    
    private func rateApp() {
        requestReview?()
    }
    
    private func shareApp() {
        let text = "🚀 AI Homework – Your smart study buddy! 📚✨ Ace your assignments with AI-powered help. Try it now!"
        let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID")!
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        presentActivity?(activityVC)
    }
}
