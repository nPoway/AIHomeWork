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
        if let url = URL(string: "https://www.freeprivacypolicy.com/live/3800f35a-2ef3-48e5-a7d9-f6974d7eff2a") {
            openURL?(url)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://www.freeprivacypolicy.com/live/5fdd7d4a-ee18-4460-a13f-cd7d06eab6a9") {
            openURL?(url)
        }
    }
    
    private func rateApp() {
        requestReview?()
    }
    
    private func shareApp() {
        let text = "🚀 AI Homework – Your smart study buddy! 📚✨ Ace your assignments with AI-powered help. Try it now!"
        let url = URL(string: "https://apps.apple.com/app/id6745099629")!
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        presentActivity?(activityVC)
    }
}
