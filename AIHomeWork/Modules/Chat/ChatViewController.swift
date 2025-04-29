import UIKit
import PhotosUI

 class ChatViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ChatViewModel
    private let coordinator: ChatCoordinator
    private let session: RealmChatSession?
    private var messageInputBottomConstraint: NSLayoutConstraint?
     
    private var isWaitingForAnimation = false
    
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
        textField.returnKeyType = .send
        textField.delegate = self
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
            textField.leftView = paddingView
            textField.leftViewMode = .always
        
        let placeholderText = "Type here..."
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.plusJakartaSans(.regular, size: 15)
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
   
    
    private lazy var attachmentButton: UIButton = {
        let button = UIButton(type: .system)
        let paperclipImage = UIImage.scanChatIcon.resizeImage(to: CGSize(width: 32, height: 32))
        button.setImage(paperclipImage, for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(attachmentButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    init(viewModel: ChatViewModel, coordinator: ChatCoordinator, session: RealmChatSession? = nil) {
        self.session = session
        self.viewModel = viewModel
        self.coordinator = coordinator
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
        
        let spacerView = UIView()
        spacerView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        
        let containerView = UIStackView(arrangedSubviews: [attachmentButton, spacerView])
        containerView.axis = .horizontal
        containerView.alignment = .center
        
        messageInputTextField.rightView = containerView
        messageInputTextField.rightViewMode = .always
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    }
    
    private func setupConstraints() {
        customNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        chatTableView.translatesAutoresizingMaskIntoConstraints = false
        messageInputTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customNavigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110),
            chatTableView.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: messageInputTextField.topAnchor, constant: -15),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            sendButton.widthAnchor.constraint(equalToConstant: 45),
            sendButton.heightAnchor.constraint(equalToConstant: 45),
            messageInputTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageInputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            messageInputTextField.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            messageInputTextField.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        messageInputBottomConstraint = messageInputTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        messageInputBottomConstraint?.isActive = true
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
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        if session == nil {
            DispatchQueue.main.async() {
                self.viewModel.saveChatSession()
            }
        }
        triggerHapticFeedback(type: .selection)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sendButtonTapped() {
        if PaywallService.shared.isPaywallNeeded() {
            coordinator.presentPaywall()
        }
        else {
            guard !isWaitingForAnimation else { return }
            guard let text = messageInputTextField.text?.trimmingCharacters(in: .whitespaces),
                  !text.isEmpty else { return }
            isWaitingForAnimation = true
            self.sendButton.isEnabled = false
            viewModel.userDidSendMessage(text)
            messageInputTextField.text = ""
            messageInputTextField.resignFirstResponder()
            viewModel.addAssistantLoadingMessage()
            triggerHapticFeedback(type: .success)
        }
    }
    
    // MARK: - Helpers
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        triggerHapticFeedback(type: .error)
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as? ChatMessageCell else {
            return UITableViewCell()
        }
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        if message.isLoading {
            cell.configureLoadingBubbleForAssistant()
        }
        else {
            cell.configure(with: message, tableView: self.chatTableView, indexPath: indexPath) {
                self.viewModel.markAnimationFinished(for: message)
                self.sendButton.isEnabled = true
                self.isWaitingForAnimation = false
            }

            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                        cell.addGestureRecognizer(longPressGesture)
        }
        return cell
    }
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        guard let cell = gesture.view as? ChatMessageCell,
              let indexPath = chatTableView.indexPath(for: cell) else { return }
        
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

// MARK: - UITextFieldDelegate

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        let keyboardHeight = keyboardFrame.height
        UIView.animate(withDuration: duration) {
            self.messageInputBottomConstraint?.constant = -keyboardHeight - 10
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            self.messageInputBottomConstraint?.constant = -5
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Attachment Handling

extension ChatViewController {
    @objc private func attachmentButtonTapped() {
        if PaywallService.shared.isPaywallNeeded() {
            coordinator.presentPaywall()
        }
        else {
            guard !isWaitingForAnimation else { return }
            triggerHapticFeedback(type: .light)
            let scanOptionsVC = ScanOptionsViewController()
            scanOptionsVC.delegate = self
            scanOptionsVC.modalPresentationStyle = .overFullScreen
            present(scanOptionsVC, animated: false)
        }
    }
    
}
    

extension ChatViewController: ScanOptionsDelegate {
    func didSelectCameraOption() {
        triggerHapticFeedback(type: .light)
        coordinator.pushCamera { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                let text = self.messageInputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                if let base64 = image.jpegBase64 {
                    self.viewModel.userDidSendImageAndText(imageURL: "data:image/jpeg;base64,\(base64)", text: text)
                    
                    self.messageInputTextField.text = ""
                    self.viewModel.addAssistantLoadingMessage()
                    self.isWaitingForAnimation = true
                }
                else {
                    self.showErrorAlert(message: "Failed to encode image.")
                }
            }
        }
    }
    
    func didSelectGalleryOption() {
        triggerHapticFeedback(type: .light)
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension ChatViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { image, _ in
            if let selectedImage = image as? UIImage {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let text = messageInputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    
                    if let base64 = selectedImage.jpegBase64 {
                        self.viewModel.userDidSendImageAndText(imageURL: "data:image/jpeg;base64,\(base64)", text: text)
                        
                        messageInputTextField.text = ""
                        viewModel.addAssistantLoadingMessage()
                        self.isWaitingForAnimation = true
                        triggerHapticFeedback(type: .success)
                    }
                    else {
                        self.showErrorAlert(message: "Failed to encode image.")
                        triggerHapticFeedback(type: .error)
                    }
                }
            }
        }
    }
}

extension ChatViewController {
    func sendSavedMessage() {
        guard let session else { return }
        viewModel.userDidSendMessage(session.firstQuestion)
        viewModel.addAssistantLoadingMessage()
        triggerHapticFeedback(type: .light)
    }
}

