import UIKit
import RevenueCat
import RevenueCatUI

class HistoryCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {}
    
    func finish() {}
    
    func makeHistoryViewController() -> UIViewController {
        let vc = HistoryViewController(viewModel: HistoryViewModel(), coordinator: self)
        return vc
    }
    
    func showChat(with session: RealmChatSession) {
        if PaywallService.shared.isPaywallNeeded() {
            presentPaywall()
        }
        else {
            let chatCoordinator = ChatCoordinator(navigationController: navigationController)
            chatCoordinator.startWithSession(with: session)
        }
    }
    
    func showTranslate(with session: RealmChatSession) {
        if PaywallService.shared.isPaywallNeeded() {
            presentPaywall()
        }
        else {
            let translateCoordinator = TranslateCoordinator(navigationController: navigationController)
            translateCoordinator.start(with: session.firstQuestion)
        }
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
