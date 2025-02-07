import UIKit
import StoreKit

final class SettingsViewModel {
    
    struct SettingsOption {
        let title: String
        let icon: UIImage?
        let action: () -> Void
    }
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    lazy var settingsOptions: [SettingsOption] = [
        SettingsOption(title: "Terms of Use", icon: UIImage.termsIcon, action: openTermsOfUse),
        SettingsOption(title: "Privacy Policy", icon: UIImage.privacyIcon, action: openPrivacyPolicy),
        SettingsOption(title: "Rate Us", icon: UIImage.rateIcon, action: rateApp),
        SettingsOption(title: "Share App", icon: UIImage.shareIcon, action: shareApp)
    ]
    
    private func openTermsOfUse() {
        if let url = URL(string: "https://policies.google.com/terms") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://policies.google.com/privacy") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func shareApp() {
        let text = "🚀 AI Homework – Your smart study buddy! 📚✨ Ace your assignments with AI-powered help. Try it now!"
        let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID")!
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)

        viewController?.present(activityVC, animated: true)
    }
}
