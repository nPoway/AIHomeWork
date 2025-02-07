import UIKit

class OnboardingCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var onFinish: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {}
    
    func finish() {
        onFinish?()
    }
}
