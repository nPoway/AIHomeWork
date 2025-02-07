import UIKit

class HistoryCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {}
    
    func finish() {}
    
    func makeHistoryViewController() -> UIViewController {
        let vc = HistoryViewController()
        return vc
    }
}
