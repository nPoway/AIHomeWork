import UIKit

class TranslateCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = makeViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func finish() {
        navigationController.popViewController(animated: true)
    }
    
    func makeViewController() -> UIViewController {
        let vc = TranslateViewController(coordinator: self)
        return vc
    }
    
    
}
