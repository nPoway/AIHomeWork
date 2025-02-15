import UIKit
import StoreKit

final class SettingsViewController: UIViewController {
    
    private let coordinator: SettingsCoordinator
    private let viewModel = SettingsViewModel()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let navigationBar = SettingsNavigationBar()
    private let blurredBackground = BaseBlurredView()
    
    init(coordinator: SettingsCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        setupViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTargets()
    }
    
    private func setupViewModel() {
        viewModel.openURL = { url in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        viewModel.presentActivity = { [weak self] activityVC in
            self?.present(activityVC, animated: true)
        }
        
        viewModel.requestReview = {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
    
    private func setupTargets() {
        navigationBar.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(blurredBackground)
        blurredBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurredBackground.topAnchor.constraint(equalTo: view.topAnchor),
            blurredBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurredBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurredBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 60 : 50)
        ])
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.identifier)
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc
    private func backTapped() {
        coordinator.finish()
        triggerHapticFeedback(type: .light)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.identifier, for: indexPath) as! SettingsCell
        let item = viewModel.settingsOptions[indexPath.row]
        cell.configure(title: item.title, icon: item.icon)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        triggerHapticFeedback(type: .light)
        let action = viewModel.settingsOptions[indexPath.row].action
        action()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}
