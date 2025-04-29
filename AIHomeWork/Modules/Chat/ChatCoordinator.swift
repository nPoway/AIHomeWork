import UIKit
import RevenueCat
import RevenueCatUI

final class ChatCoordinator: Coordinator {
    func start() {
        
    }
    
    func finish() {
        
    }
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(with subject: Subject? = nil) {
        let viewModel = ChatViewModel(openAIService: OpenAIService(), subject: subject)
        let chatVC = ChatViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(chatVC, animated: true)
    }
    
    func pushCamera(completion: @escaping (UIImage) -> Void) {
            let scanCoordinator = ScanCoordinator(navigationController: navigationController, fromChat: true)
            scanCoordinator.onImageScanned = { image in
                completion(image)
            }
            scanCoordinator.startScanOnlyFlow()
        }
    func startWithSession(with session: RealmChatSession) {
        let viewModel = ChatViewModel(openAIService: OpenAIService(), subject: Subject(title: session.subject))
        let chatVC = ChatViewController(viewModel: viewModel, coordinator: self, session: session)
        navigationController.pushViewController(chatVC, animated: true)
        chatVC.sendSavedMessage()
    }
    
    func presentPaywall() {
        Purchases.shared.getOfferings { [weak self] offerings, error in
            guard let self = self else { return }
            
            if let offering = offerings?.current {
                DispatchQueue.main.async {
                    let paywallVC = PaywallViewController(
                        offering: offering,
                        displayCloseButton: false,
                        shouldBlockTouchEvents: false,
                        dismissRequestedHandler: { [weak self] controller in
                            self?.navigationController.dismiss(animated: true)
                        }
                    )
                    paywallVC.modalPresentationStyle = .fullScreen
                    self.navigationController.present(paywallVC, animated: true)
                }
            }
        }
    }
}
