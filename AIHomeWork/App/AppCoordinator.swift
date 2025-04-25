import UIKit
import SwiftUI
import RevenueCat
import RevenueCatUI

class AppCoordinator: Coordinator {
    var navigationController = UINavigationController()
    private let window: UIWindow

    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    private var onboardingCoordinator: OnboardingCoordinator?

    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let into = IntroScreenController()
        window.rootViewController = into
        window.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            self?.startAfterLaunch()
        })
    }
    
    func startAfterLaunch() {
        if isFirstLaunch {
            showOnboarding()
        } else {
            pushTabBar()
        }
    }

    func finish() {}

    private func showOnboarding() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        self.onboardingCoordinator = onboardingCoordinator
        onboardingCoordinator.start()
        navigationController = onboardingCoordinator.navigationController
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        onboardingCoordinator.onFinish = { [weak self] in
            self?.pushTabBar()
            self?.isFirstLaunch = false
            self?.onboardingCoordinator = nil
        }
    }

    private func pushTabBar() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        
        tabBarCoordinator.start()
        
        navigationController = tabBarCoordinator.navigationController
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
}


extension AppCoordinator {
    func showPaywall() {
        if !isFirstLaunch && !PaywallService.shared.isPremium {
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
}
