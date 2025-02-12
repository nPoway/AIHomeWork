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
        let chatVC = ChatViewController(viewModel: viewModel)
        navigationController.pushViewController(chatVC, animated: true)
    }
}
