import UIKit

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
        let scanCoordinator = ScanCoordinator(navigationController: navigationController)
        scanCoordinator.start()
    }
    
}
