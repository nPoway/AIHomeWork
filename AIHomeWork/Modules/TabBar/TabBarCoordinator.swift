import UIKit
import RevenueCat
import RevenueCatUI

final class TabBarCoordinator: Coordinator {
    var navigationController: UINavigationController
    let homeCoordinator: HomeCoordinator
    let historyCoordinator: HistoryCoordinator
    
    private var tabBarController: MainTabBarController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.homeCoordinator = HomeCoordinator(navigationController: navigationController)
        self.historyCoordinator = HistoryCoordinator(navigationController: navigationController)
    }
    
    func start() {
        let tabBarController = MainTabBarController(coordinator: self)
        
        let homeVC = homeCoordinator.makeHomeViewController()
        let historyVC = historyCoordinator.makeHistoryViewController()
        
        tabBarController.setupViewControllers(viewControllers: [homeVC,historyVC])
        
        navigationController.viewControllers = [tabBarController]
        navigationController.navigationBar.isHidden = true
    }
    
    
    func finish() {}
    
    func pushScanViewController() {
        if PaywallService.shared.isPaywallNeeded() {
            showPaywall()
        }
        else {
            let scanCoordinator = ScanCoordinator(navigationController: navigationController)
            scanCoordinator.start()
        }
    }
    
    func showPaywall() {
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
