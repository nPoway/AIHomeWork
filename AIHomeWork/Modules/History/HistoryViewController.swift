import UIKit

final class HistoryViewController: BaseViewController {
    
    private let navigationBar = HistoryNavigationBar()
    
    private lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "historyEmpty")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func setupUI() {
        let blurredView = BaseBlurredView(frame: view.frame)
        view = blurredView
        view.backgroundColor = .black
        
        setupNavigationBar()
        setupEmptyState()
    }
    
    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupEmptyState() {
        view.addSubview(emptyImageView)
        
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 280),
            emptyImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}
