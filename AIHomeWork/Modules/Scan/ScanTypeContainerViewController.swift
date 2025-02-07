import UIKit

final class ScanTypeContainerViewController: UIViewController {
    
    // MARK: - UI
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Scan", "Type"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()
    
    private let containerView = UIView()

    // MARK: - Child View Controllers
    
    private let scanVC: ScanViewController
    private let typeVC: TypeViewController
    
    // MARK: - Lifecycle
    
    init(scanVC: ScanViewController, typeVC: TypeViewController) {
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
        view.backgroundColor = .black
        setupLayout()
        addChildVC(scanVC) // По умолчанию показываем Scan
    }
    
    // MARK: - Segment Action
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            removeChildVC(typeVC)
            addChildVC(scanVC)
        case 1:
            removeChildVC(scanVC)
            addChildVC(typeVC)
        default:
            break
        }
    }
    
    // MARK: - Helpers
    
    private func setupLayout() {
        navigationItem.titleView = segmentedControl
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func addChildVC(_ child: UIViewController) {
        addChild(child)
        containerView.addSubview(child.view)
        child.view.frame = containerView.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        child.didMove(toParent: self)
    }
    
    private func removeChildVC(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
