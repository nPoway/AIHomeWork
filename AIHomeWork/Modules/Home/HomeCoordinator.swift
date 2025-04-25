import UIKit
import RevenueCat
import RevenueCatUI

class HomeCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigationController.pushViewController(makeHomeViewController(), animated: false)
    }
    
    func finish() {}
    
    func makeHomeViewController() -> UIViewController {
        let viewController = HomeViewController(coordinator: self)
        return viewController
    }
    
    func openSettings() {
        let settingsCoordinator = SettingsCoordinator(navigationController: navigationController)
        settingsCoordinator.start()
    }
    
    func openTranslate() {
        if PaywallService.shared.isPaywallNeeded() {
            presentPaywall()
        }
        else {
            let translateCoordinator = TranslateCoordinator(navigationController: navigationController)
            translateCoordinator.start()
        }
    }
    
    func openChat(with subject: Subject? = nil) {
        if PaywallService.shared.isPaywallNeeded() {
            presentPaywall()
        }
        else {
            let chatCoordinator = ChatCoordinator(navigationController: navigationController)
            chatCoordinator.start(with: subject)
        }
    }
    
    func showPaywall() {
        let pw = PaywallTrialController()
        pw.modalPresentationStyle = .overFullScreen
        navigationController.present(pw, animated: true)
    }
    
    func presentPaywall() {
        Purchases.shared.getOfferings { [weak self] offerings, error in
            guard let self = self else { return }
            
            if let offering = offerings?.current {
                DispatchQueue.main.async {
                    let paywallVC = PaywallViewController(
                        offering: offering,
                        displayCloseButton: false,
                        shouldBlockTouchEvents: false,
                        dismissRequestedHandler: { [weak self] controller in
                            self?.navigationController.dismiss(animated: true)
                        }
                    )
                    paywallVC.modalPresentationStyle = .fullScreen
                    self.navigationController.present(paywallVC, animated: true)
                }
            }
        }
    }
    
}
