import UIKit

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
       let translateCoordinator = TranslateCoordinator(navigationController: navigationController)
        translateCoordinator.start()
    }
    
    func openChat(with subject: Subject? = nil) {
        let chatCoordinator = ChatCoordinator(navigationController: navigationController)
        chatCoordinator.start(with: subject)
    }
}
