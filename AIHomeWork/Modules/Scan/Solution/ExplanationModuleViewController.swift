import UIKit

final class ExplanationModuleViewController: UIViewController {
    
    // MARK: - Properties
    private let question: String
    private let viewModel: ChatViewModel
    
    private lazy var customNavigationBar: ChatNavigationView = {
        let bar = ChatNavigationView()
        bar.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return bar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        tableView.register(DateCell.self, forCellReuseIdentifier: "DateCell")
        return tableView
    }()
    
    private var tableViewBottomConstraint: NSLayoutConstraint?
    
    private let getExplanationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Explanation", for: .normal)
        button.titleLabel?.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        button.setTitleColor(.white, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.customPrimary.cgColor
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let nextTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next Task", for: .normal)
        button.titleLabel?.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.customPrimary
        button.layer.cornerRadius = 25
        return button
    }()
    
    // MARK: - Init
    init(question: String, viewModel: ChatViewModel) {
        self.question = question
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        view = BlurredGradientView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        bindViewModel()
        
        viewModel.userDidSendMessage("\(question)")
        viewModel.saveChatSession()
        viewModel.addAssistantLoadingMessage()
        
        customNavigationBar.changeTitle("Solution")
    }
    
    // MARK: - UI Setup
    private func setupViews() {
        view.addSubview(customNavigationBar)
        view.addSubview(tableView)
        view.addSubview(getExplanationButton)
        view.addSubview(nextTaskButton)
        
        tableView.dataSource = self
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        customNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        nextTaskButton.translatesAutoresizingMaskIntoConstraints = false
        getExplanationButton.translatesAutoresizingMaskIntoConstraints = false
        
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: getExplanationButton.topAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            customNavigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110),
            
            nextTaskButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextTaskButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nextTaskButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            nextTaskButton.heightAnchor.constraint(equalToConstant: 50),
            
            getExplanationButton.bottomAnchor.constraint(equalTo: nextTaskButton.topAnchor, constant: -10),
            getExplanationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            getExplanationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            getExplanationButton.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewBottomConstraint!
        ])
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onMessagesUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.scrollToBottom()
            }
        }
        viewModel.onErrorOccurred = { [weak self] errorMessage in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
        
        nextTaskButton.addTarget(self, action: #selector(nextTaskTapped), for: .touchUpInside)
        getExplanationButton.addTarget(self, action: #selector(getExplanationTapped), for: .touchUpInside)
    }
    
    private func scrollToBottom() {
        guard !viewModel.visibleMessages.isEmpty else { return }
        let lastIndex = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: lastIndex, at: .top, animated: true)
    }
    
    // MARK: - Actions
    @objc private func getExplanationTapped() {
        
        triggerHapticFeedback(type: .success)
        
        guard let previousAnswer = viewModel.messages.last(where: { $0.role == "assistant" && !$0.isLoading })?.content else {
            return
        }
        
        viewModel.clearMessagesForExplanation()
        
        
        getExplanationButton.isHidden = true
        nextTaskButton.isHidden = true
        tableViewBottomConstraint?.isActive = false

        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15)
        tableViewBottomConstraint?.isActive = true

        self.view.layoutIfNeeded()
       
        
        let explanationPrompt = "Please give detail explanation of your previous answer: \(previousAnswer)"
        
        viewModel.userDidSendMessage(explanationPrompt, showInChat: false)
        customNavigationBar.changeTitle("Explanation")
        viewModel.addAssistantLoadingMessage()
    }


    
    @objc private func nextTaskTapped() {
        dismiss(animated: true)
        triggerHapticFeedback(type: .success)
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
        triggerHapticFeedback(type: .selection)
    }
}

// MARK: - UITableViewDataSource
extension ExplanationModuleViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.visibleMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let index = viewModel.visibleMessages.count - 1 - indexPath.row
        let message = viewModel.visibleMessages[index]
        
        if message.role == "date" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as? DateCell else {
                return UITableViewCell()
            }
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.configure(dateString: message.content)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as? ChatMessageCell else {
            return UITableViewCell()
        }
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        if message.isLoading {
            cell.configureLoadingBubbleForAssistant()
        } else {
            cell.configure(with: message)
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                        cell.addGestureRecognizer(longPressGesture)
        }
        return cell
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        guard let cell = gesture.view as? ChatMessageCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        let indexInVisible = viewModel.visibleMessages.count - 1 - indexPath.row
        let message = viewModel.visibleMessages[indexInVisible]
        
        if message.role == "date" || message.isLoading { return }
        
        let pasteboard = UIPasteboard.general
        pasteboard.string = message.content
        
        let alert = UIAlertController(title: "Copied", message: "Message copied to clipboard", preferredStyle: .alert)
        triggerHapticFeedback(type: .success)
        self.present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            alert.dismiss(animated: true)
        }
    }

}
