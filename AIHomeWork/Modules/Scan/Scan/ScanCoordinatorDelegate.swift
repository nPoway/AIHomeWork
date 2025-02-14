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
        let typeVC = TypeViewController(coordinator: self)
        
        let containerVC = ScanTypeContainerViewController(scanVC: scanVC, typeVC: typeVC, navigationController: navigationController)
        
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
        navigationController.pushViewController(scanningResultVC, animated: true)
    }
    
    func finishWithImage(_ image: UIImage) {
        onImageScanned?(image)
        finish()
    }
    
    func dismissScanningResult() {
        pop()
    }
    
    func showViewController(_ viewController: UIViewController) {
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
    
    func showSolution(with text: String) {
        let explanationModuleViewController = ExplanationModuleViewController(question: text, viewModel: ChatViewModel(openAIService: OpenAIService(), isInitMessageVisible: false))
        explanationModuleViewController.modalPresentationStyle = .fullScreen
        navigationController.present(explanationModuleViewController, animated: true) {
            self.navigationController.popViewController(animated: false)
        }
    }
}

