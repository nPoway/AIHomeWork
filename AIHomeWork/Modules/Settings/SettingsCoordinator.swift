import UIKit

final class SettingsCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let settingsVC = SettingsViewController(coordinator: self)
        navigationController.pushViewController(settingsVC, animated: true)
    }
    
    func finish() {
        navigationController.popViewController(animated: true)
    }
}
