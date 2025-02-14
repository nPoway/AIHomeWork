import UIKit

class HistoryCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {}
    
    func finish() {}
    
    func makeHistoryViewController() -> UIViewController {
        let vc = HistoryViewController(viewModel: HistoryViewModel(), coordinator: self)
        return vc
    }
    
    func showChat(with session: RealmChatSession) {
        let chatCoordinator = ChatCoordinator(navigationController: navigationController)
        chatCoordinator.startWithSession(with: session)
    }
}
