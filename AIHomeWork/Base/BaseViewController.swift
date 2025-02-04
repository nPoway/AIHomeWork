import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
    }

    private func setupView() {
        setupUI()
        setupConstraints()
        setupTargets()
    }
    
    func setupUI() {}

    func setupConstraints() {}

    func setupTargets() {}

    func bindViewModel() {}

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Oops, something happend", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}
