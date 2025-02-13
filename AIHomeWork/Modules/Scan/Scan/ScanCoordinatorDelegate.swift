import UIKit

final class ScanCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    var onImageScanned: ((UIImage) -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let scanVC = ScanViewController(coordinator: self)
        let typeVC = TypeViewController()
        
        let containerVC = ScanTypeContainerViewController(scanVC: scanVC, typeVC: typeVC)
        
        navigationController.pushViewController(containerVC, animated: true)
    }
    
    func startScanOnlyFlow() {
        let scanVC = ScanViewController(coordinator: self, showCustomNavBar: true)
        navigationController.pushViewController(scanVC, animated: true)
    }
    
    func finish() {
        navigationController.popViewController(animated: true)
    }
    
    func showScanningResult(with image: UIImage) {
        let scanningResultVC = ScanningResultViewController(coordinator: self, image: image)
        scanningResultVC.modalPresentationStyle = .fullScreen
        navigationController.present(scanningResultVC, animated: true)
    }
    
    func finishWithImage(_ image: UIImage) {
        onImageScanned?(image)
        finish()
    }
    
    func dismissScanningResult() {
        navigationController.dismiss(animated: true)
    }
    
    func showViewController(_ viewController: UIViewController) {
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
}

