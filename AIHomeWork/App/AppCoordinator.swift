import UIKit

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigationController.pushViewController(makeMainViewController(), animated: true)
    }
    
    func finish() {}
    
    func makeMainViewController() -> UIViewController {
        let vc = ViewController()
        return vc
    }
    
}
