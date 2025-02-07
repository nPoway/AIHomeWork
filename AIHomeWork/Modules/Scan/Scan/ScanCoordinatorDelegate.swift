import UIKit

final class ScanCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let scanVC = ScanViewController(coordinator: self)
        let typeVC = TypeViewController()
        
        let containerVC = ScanTypeContainerViewController(scanVC: scanVC, typeVC: typeVC)
        
        navigationController.pushViewController(containerVC, animated: true)
    }
    
    func finish() {
        navigationController.popViewController(animated: true)
    }
    
    func showScanningResult(with image: UIImage) {
            let scanningResultVC = ScanningResultViewController(coordinator: self, image: image)
            scanningResultVC.modalPresentationStyle = .fullScreen
            navigationController.present(scanningResultVC, animated: true)
        }
        
        func dismissScanningResult() {
            navigationController.dismiss(animated: true)
        }
}
