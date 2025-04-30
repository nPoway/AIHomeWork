import UIKit
import RevenueCat
import RevenueCatUI

final class ScanCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    var onImageScanned: ((UIImage) -> Void)?
    
    var isFromChat: Bool
    
    init(navigationController: UINavigationController, fromChat: Bool = false) {
        self.navigationController = navigationController
        self.isFromChat = fromChat
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
        if isFromChat {
            navigationController.popViewController(animated: true)
        }
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
        let explanationModuleViewController = ExplanationModuleViewController(question: text, viewModel: ChatViewModel(openAIService: OpenAIService(), isInitMessageVisible: false), coordinator: self)
        explanationModuleViewController.modalPresentationStyle = .fullScreen
        navigationController.present(explanationModuleViewController, animated: true) {
            self.navigationController.popViewController(animated: false)
        }
    }
    
    func presentPaywall(with controller: UIViewController? = nil) {
        Purchases.shared.getOfferings { [weak self] offerings, error in
            guard let self = self else { return }
            
            if let offering = offerings?.current {
                DispatchQueue.main.async {
                    let paywallVC = PaywallViewController(
                        offering: offering,
                        displayCloseButton: false,
                        shouldBlockTouchEvents: false,
                        dismissRequestedHandler: { controller in
                           controller.dismiss(animated: true)
                        }
                    )
                    paywallVC.modalPresentationStyle = .fullScreen
                    let cont = controller ?? self.navigationController
                    cont.present(paywallVC, animated: true)
                }
            }
        }
    }
}

