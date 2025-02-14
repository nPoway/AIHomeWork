import UIKit

final class ScanTypeContainerViewController: UIViewController {
    
    private let containerView = UIView()
    
    private let customNavBar = ScanNavigationBar()

    private let segmentedControl = SegmentButtonsView()
    
    private let scanVC: ScanViewController
    private let typeVC: TypeViewController
    
    private let navController: UINavigationController
    
    init(scanVC: ScanViewController, typeVC: TypeViewController, navigationController: UINavigationController) {
        self.navController = navigationController
        self.scanVC = scanVC
        self.typeVC = typeVC
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navController.isNavigationBarHidden = true
        
        view.backgroundColor = .black
        
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(customNavBar)
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110)
        ])
        
        customNavBar.backgroundColor = UIColor.black
        customNavBar.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
       
        addChildVC(scanVC)
        segmentedControl.delegate = self
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 15),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95),
            segmentedControl.heightAnchor.constraint(equalToConstant: 45)
               ])
        
    }
    
    @objc private func backTapped() {
        navController.popViewController(animated: true)
    }
    
    private func addChildVC(_ child: UIViewController) {
        addChild(child)
        containerView.addSubview(child.view)
        child.view.frame = containerView.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        child.didMove(toParent: self)
    }
    
    private func removeChildVC(_ child: UIViewController) {
        guard child.parent != nil else { return }
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}

extension ScanTypeContainerViewController: SegmentButtonsViewDelegate {
    func didSelectSegment(_ index: Int) {
        switch index {
        case 0:
            removeChildVC(typeVC)
            addChildVC(scanVC)
            customNavBar.changeNavLabelText("Scan")
        case 1:
            removeChildVC(scanVC)
            addChildVC(typeVC)
            customNavBar.changeNavLabelText("Type")
        default:
            break
        }
    }
}
