protocol ScanCoordinatorDelegate: AnyObject {
    func didSelectMode(_ mode: ScanType)
}

class ScanCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let scanVC = ScanViewController(viewModel: ScanViewModel())
        scanVC.coordinator = self
        navigationController.pushViewController(scanVC, animated: true)
    }
    
    func showTypeView() {
        let typeVC = TypeViewController(viewModel: TypeViewModel())
        navigationController.pushViewController(typeVC, animated: true)
    }
}
