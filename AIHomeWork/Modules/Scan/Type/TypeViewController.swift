import UIKit

final class TypeViewController: UIViewController, UITextViewDelegate {
    
    private let viewModel = TypeViewModel()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        textView.font = UIFont.plusJakartaSans(.regular, size: 15)
        textView.textColor = .white
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.returnKeyType = .done
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Type here..."
        label.textColor = UIColor.white.withAlphaComponent(0.4)
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let charCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/1000"
        label.textColor = UIColor.white.withAlphaComponent(0.4)
        label.font = UIFont.plusJakartaSans(.regular, size: 15)
        return label
    }()
    
    private let solveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Solve", for: .normal)
        button.titleLabel?.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        button.backgroundColor = UIColor.customPrimary
        button.layer.cornerRadius = 24
        button.isEnabled = false
        return button
    }()
    
    private let coordinator: ScanCoordinator
    
    init(coordinator: ScanCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = BlurredGradientView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        setupBindings()
        setupKeyboardDismiss()
    }
    
    private func setupUI() {
        textView.delegate = self
        
        view.addSubview(textView)
        view.addSubview(placeholderLabel)
        view.addSubview(charCountLabel)
        view.addSubview(solveButton)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        charCountLabel.translatesAutoresizingMaskIntoConstraints = false
        solveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: iphoneWithButton ? 150 : 130),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 250),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 12),
            
            charCountLabel.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -12),
            charCountLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 12),
            
            solveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            solveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            solveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            solveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        solveButton.addTarget(self, action: #selector(solveTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onTextChanged = { [weak self] text in
            self?.charCountLabel.text = "\(text.count)/\(self?.viewModel.maxCharacters ?? 1000)"
            self?.placeholderLabel.isHidden = !text.isEmpty
        }
        
        viewModel.onButtonStateChanged = { [weak self] isEnabled in
            self?.solveButton.isEnabled = isEnabled
            self?.solveButton.setTitleColor(isEnabled ? .white : UIColor.white.withAlphaComponent(0.5), for: .normal)
        }
    }
    
    private
    func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        triggerHapticFeedback(type: .error)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
        triggerHapticFeedback(type: .error)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > viewModel.maxCharacters {
            textView.text = String(textView.text.prefix(viewModel.maxCharacters))
        }
        
        viewModel.inputText = textView.text
        viewModel.validateInput()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.inputText = textView.text
        viewModel.validateInput()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc private func solveTapped() {
        coordinator.showSolution(with: viewModel.inputText)
    }
}
