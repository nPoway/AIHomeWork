import UIKit

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
            let scanCoordinator = ScanCoordinator(navigationController: navigationController)
            scanCoordinator.onImageScanned = { image in
                completion(image)
            }
            scanCoordinator.startScanOnlyFlow()
        }
    
    func pushGallery(completion: @escaping (UIImage) -> Void) {
        
    }
}
