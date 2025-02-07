import UIKit
import SwiftUI

class AppCoordinator: Coordinator {
    var navigationController = UINavigationController()
    private let window: UIWindow

    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = false

    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        if isFirstLaunch {
            showOnboarding()
        } else {
            pushTabBar()
        }
    }

    func finish() {}

    private func showOnboarding() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        onboardingCoordinator.start()
        navigationController = onboardingCoordinator.navigationController
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        onboardingCoordinator.onFinish = { [weak self] in
            self?.pushTabBar()
        }

        isFirstLaunch = false
    }

    private func pushTabBar() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        
        tabBarCoordinator.start()
        
        navigationController = tabBarCoordinator.navigationController
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
}
