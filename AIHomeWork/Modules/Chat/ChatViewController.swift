import UIKit

final class ChatViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ChatViewModel
    
    private lazy var customNavigationBar: ChatNavigationView = {
        let bar = ChatNavigationView()
        bar.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return bar
    }()
    
    private lazy var chatTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        tableView.register(DateCell.self, forCellReuseIdentifier: "DateCell")
        return tableView
    }()
    
    private lazy var messageInputTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        textField.font = UIFont.plusJakartaSans(.regular, size: 15)
        textField.textColor = .white
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .send
        textField.delegate = self
        
        let placeholderText = "Type here..."
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.plusJakartaSans(.regular, size: 15) // Custom font
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        
        return textField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        let image = UIImage.sendButton.resizeImage(to: CGSize(width: 45, height: 45))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mainActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Init
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = BlurredGradientView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        bindViewModel()
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        if let subject = viewModel.currentSubject {
            customNavigationBar.changeTitle(subject.title)
        }
        
        view.addSubview(customNavigationBar)
        view.addSubview(chatTableView)
        view.addSubview(messageInputTextField)
        view.addSubview(sendButton)
        view.addSubview(mainActivityIndicator)
    }
    
    private func setupConstraints() {
        customNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        chatTableView.translatesAutoresizingMaskIntoConstraints = false
        messageInputTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        mainActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customNavigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationBar.heightAnchor.constraint(equalToConstant: 110),
            
            // TableView
            chatTableView.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // The table’s bottom pinned to the textField top
            chatTableView.bottomAnchor.constraint(equalTo: messageInputTextField.topAnchor, constant: -15),
            
            // Send button
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            sendButton.widthAnchor.constraint(equalToConstant: 45),
            sendButton.heightAnchor.constraint(equalToConstant: 45),
            
            // TextField
            messageInputTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageInputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            messageInputTextField.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            messageInputTextField.heightAnchor.constraint(equalToConstant: 45),
            
            // Activity indicator
            mainActivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainActivityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - ViewModel Bindings
    
    private func bindViewModel() {
        viewModel.onMessagesUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.chatTableView.reloadData()
                self?.scrollToBottom()
            }
        }
        
        viewModel.onErrorOccurred = { [weak self] message in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: message)
            }
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.mainActivityIndicator.startAnimating()
                } else {
                    self?.mainActivityIndicator.stopAnimating()
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sendButtonTapped() {
        guard let text = messageInputTextField.text?.trimmingCharacters(in: .whitespaces),
              !text.isEmpty else { return }
        
        viewModel.userDidSendMessage(text)
        messageInputTextField.text = ""
        viewModel.addAssistantLoadingMessage()
    }
    
    // MARK: - Helpers
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func scrollToBottom() {
        guard !viewModel.visibleMessages.isEmpty else { return }
        let lastRow = IndexPath(row: 0, section: 0)
        chatTableView.scrollToRow(at: lastRow, at: .top, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.visibleMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indexInVisible = viewModel.visibleMessages.count - 1 - indexPath.row
        let message = viewModel.visibleMessages[indexInVisible]
        
        if message.role == "date" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as? DateCell else {
                return UITableViewCell()
            }
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.configure(dateString: message.content)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath)
                as? ChatMessageCell else {
            return UITableViewCell()
        }
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        if message.isLoading {
            cell.configureLoadingBubbleForAssistant()
        } else {
            cell.configure(with: message)
        }
        return cell
    }
}

// MARK: - UITextFieldDelegate

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
}
