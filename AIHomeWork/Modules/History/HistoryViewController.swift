import UIKit

final class HistoryViewController: BaseViewController {
    
    private let navigationBar = HistoryNavigationBar()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.tableFooterView = UIView()
        return tableView
    }()
   
    private let viewModel: HistoryViewModel
    
    private lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.historyEmpty.resizeImage(to: CGSize(width: 280, height: 200))
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let coordinator: HistoryCoordinator
    
    init(viewModel: HistoryViewModel, coordinator: HistoryCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.loadHistory()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadHistory()
    }
    
    override func setupUI() {
        let blurredView = BaseBlurredView(frame: view.frame)
        view = blurredView
        view.backgroundColor = .black
        tableView.backgroundColor = .clear
        setupNavigationBar()
        setupEmptyView()
        setupTableView()
        bindViewModel()
    }
    
    private func setupEmptyView() {
        view.addSubview(emptyImageView)
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        if viewModel.sessions.isEmpty {
           emptyImageView.isHidden = false
        }
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
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90)
        ])
    }
    
    override func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if self.viewModel.sessions.isEmpty {
                    self.emptyImageView.isHidden = false
                }
                else {
                    self.emptyImageView.isHidden = true
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension HistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryTableViewCell else {
                return UITableViewCell()
            }
            
            let session = viewModel.sessions[indexPath.row]
            let subject = Subject(title: session.subject)
            cell.configure(with: session, subject: subject)
            return cell
        }
}

// MARK: - UITableViewDelegate

extension HistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let session = viewModel.sessions[indexPath.row]
        if session.subject == "Translate" {
            coordinator.showTranslate(with: session)
            viewModel.deleteSession(at: indexPath.row)
        }
        else {
            coordinator.showChat(with: session)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteSession(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
