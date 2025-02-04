import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    
    func start()
    func finish()
    
    func pop()
    func popToRoot()
}

extension Coordinator {
    func pop() {
        navigationController.popViewController(animated: true)
    }
    
    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}
