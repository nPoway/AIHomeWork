import UIKit

final class TranslateViewController: UIViewController {
    
    private let coordinator: TranslateCoordinator
    
    private let navigationBar = TranslateNavigationBar()
    
    private let sourceLanguageButton = UIButton()
    private let targetLanguageButton = UIButton()
    private let swapLanguagesButton = UIButton()
    
    private let customScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let inputTextView: UITextView = {
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
    
    private let inputPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Type here..."
        label.textColor = UIColor.white.withAlphaComponent(0.4)
        label.font = UIFont.plusJakartaSans(.regular, size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    private let translationTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        textView.font = UIFont.plusJakartaSans(.regular, size: 15)
        textView.textColor = .white
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.isEditable = false
        return textView
    }()
    
    private let translationPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Your translation will be here"
        label.textColor = UIColor.white.withAlphaComponent(0.4)
        label.font = UIFont.plusJakartaSans(.regular, size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    private let translateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Translate", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .plusJakartaSans(.semiBold, size: 18)
        button.backgroundColor = .customPrimary
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let charCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/1000"
        label.textColor = UIColor.white.withAlphaComponent(0.4)
        label.font = UIFont.plusJakartaSans(.regular, size: 15)
        label.textAlignment = .left
        return label
    }()
    
    private let inputLabel: UILabel = {
        let label = UILabel()
        label.text = "Your text"
        label.textColor = .white
        label.font = UIFont.plusJakartaSans(.semiBold, size: 16)
        return label
    }()
    
    private let translationLabel: UILabel = {
        let label = UILabel()
        label.text = "Translation"
        label.textColor = .white
        label.font = UIFont.plusJakartaSans(.semiBold, size: 16)
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    private let viewModel = TranslateViewModel(openAIService: OpenAIService())
    
    private var activeLanguageButton: UIButton?
    
    // MARK: - Lifecycle
    
    init(coordinator: TranslateCoordinator, text: String? = nil) {
        if let text {
            self.inputTextView.text = text
            inputPlaceholderLabel.isHidden = true
            viewModel.updateInputText(text)
            self.charCountLabel.text = "\(text.count)/1000"
        }
        
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        view = BlurredGradientView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        [navigationBar,sourceLanguageButton, targetLanguageButton, swapLanguagesButton, customScrollView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        [inputTextView, translationTextView, translateButton, inputLabel, translationLabel,charCountLabel,inputPlaceholderLabel, translationPlaceholderLabel,activityIndicator].forEach {
            customScrollView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        inputTextView.delegate = self

        setupLanguageButton(sourceLanguageButton, title: viewModel.sourceLanguage.name)
        setupLanguageButton(targetLanguageButton, title: viewModel.targetLanguage.name)

        swapLanguagesButton.setImage(UIImage.switchLanguageIcon, for: .normal)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 60 : 50)
        ])
        
        NSLayoutConstraint.activate([
            swapLanguagesButton.widthAnchor.constraint(equalToConstant: 45),
            swapLanguagesButton.heightAnchor.constraint(equalToConstant: 45),
            swapLanguagesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            swapLanguagesButton.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            sourceLanguageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            sourceLanguageButton.topAnchor.constraint(equalTo: swapLanguagesButton.topAnchor),
            sourceLanguageButton.bottomAnchor.constraint(equalTo: swapLanguagesButton.bottomAnchor),
            sourceLanguageButton.trailingAnchor.constraint(equalTo: swapLanguagesButton.leadingAnchor, constant: -15)
        ])
        
        NSLayoutConstraint.activate([
            targetLanguageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            targetLanguageButton.topAnchor.constraint(equalTo: swapLanguagesButton.topAnchor),
            targetLanguageButton.bottomAnchor.constraint(equalTo: swapLanguagesButton.bottomAnchor),
            targetLanguageButton.leadingAnchor.constraint(equalTo: swapLanguagesButton.trailingAnchor, constant: 15)
        ])
        
        // Ограничиваем scrollView
        NSLayoutConstraint.activate([
            customScrollView.topAnchor.constraint(equalTo: swapLanguagesButton.bottomAnchor, constant: 10),
            customScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Привязываем контент scrollView
        NSLayoutConstraint.activate([
            inputLabel.topAnchor.constraint(equalTo: customScrollView.contentLayoutGuide.topAnchor, constant: 10),
            inputLabel.leadingAnchor.constraint(equalTo: customScrollView.frameLayoutGuide.leadingAnchor, constant: 15),
            inputLabel.trailingAnchor.constraint(equalTo: customScrollView.frameLayoutGuide.trailingAnchor, constant: -15)
        ])
        
        NSLayoutConstraint.activate([
            inputTextView.topAnchor.constraint(equalTo: inputLabel.bottomAnchor, constant: 10),
            inputTextView.leadingAnchor.constraint(equalTo: inputLabel.leadingAnchor),
            inputTextView.trailingAnchor.constraint(equalTo: inputLabel.trailingAnchor),
            inputTextView.heightAnchor.constraint(equalToConstant: 235)
        ])
        
        NSLayoutConstraint.activate([
            inputPlaceholderLabel.topAnchor.constraint(equalTo: inputTextView.topAnchor, constant: 12),
            inputPlaceholderLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 12)
        ])
        
        
        NSLayoutConstraint.activate([
            charCountLabel.bottomAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: -12),
            charCountLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 12),
        ])
        
        NSLayoutConstraint.activate([
            translationLabel.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 10),
            translationLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor),
            translationLabel.trailingAnchor.constraint(equalTo: inputTextView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            translationTextView.topAnchor.constraint(equalTo: translationLabel.bottomAnchor, constant: 10),
            translationTextView.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor),
            translationTextView.trailingAnchor.constraint(equalTo: inputTextView.trailingAnchor),
            translationTextView.heightAnchor.constraint(equalToConstant: 235)
        ])
        NSLayoutConstraint.activate([
            translationPlaceholderLabel.topAnchor.constraint(equalTo: translationTextView.topAnchor, constant: 12),
            translationPlaceholderLabel.leadingAnchor.constraint(equalTo: translationTextView.leadingAnchor, constant: 12)
        ])
        NSLayoutConstraint.activate([
            translateButton.topAnchor.constraint(equalTo: translationTextView.bottomAnchor, constant: 20),
            translateButton.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor),
            translateButton.trailingAnchor.constraint(equalTo: inputTextView.trailingAnchor),
            translateButton.heightAnchor.constraint(equalToConstant: 50),
            translateButton.bottomAnchor.constraint(equalTo: customScrollView.contentLayoutGuide.bottomAnchor, constant: -20) // ЗАКРЕПЛЯЕМ КОНТЕНТ
        ])
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: translateButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: translateButton.centerYAnchor)
        ])
    }


    private func setupLanguageButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .plusJakartaSans(.semiBold, size: 16)
        button.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(didTapLanguageButton(_:)), for: .touchUpInside)
    }

    // MARK: - Bindings
    private func setupBindings() {
        viewModel.onTextChanged = { [weak self] text in
            self?.charCountLabel.text = "\(text.count)/1000"
            if text.count > 1000 {
                self?.charCountLabel.textColor = .red
            }
            else {
                self?.charCountLabel.textColor = UIColor.white.withAlphaComponent(0.4)
            }
        }
        
        viewModel.onTranslationChanged = { [weak self] translatedText in
            self?.translationTextView.text = translatedText
            self?.translationPlaceholderLabel.isHidden = !translatedText.isEmpty
        }

        viewModel.onLanguagesSwapped = { [weak self] in
            self?.sourceLanguageButton.setTitle(self?.viewModel.sourceLanguage.name, for: .normal)
            self?.targetLanguageButton.setTitle(self?.viewModel.targetLanguage.name, for: .normal)
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            if isLoading {
                translateButton.setTitle("", for: .normal)
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                translateButton.isUserInteractionEnabled = false
            } else {
                translateButton.setTitle("Translate", for: .normal)
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                translateButton.isUserInteractionEnabled = true
            }
        }
        
        viewModel.onErrorOccurred = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: errorMessage)
            }
        }
        
        swapLanguagesButton.addTarget(self, action: #selector(didTapSwapLanguages), for: .touchUpInside)
        translateButton.addTarget(self, action: #selector(didTapTranslate), for: .touchUpInside)
        navigationBar.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func backTapped() {
        coordinator.finish()
        guard !inputTextView.text.isEmpty else { return }
        viewModel.saveChatSession()
    }
    
    @objc private func didTapLanguageButton(_ sender: UIButton) {
        activeLanguageButton = sender
        let languageVC = LanguageSelectionViewController()
        languageVC.delegate = self
        if let sheet = languageVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(languageVC, animated: true)
    }


    @objc private func didTapSwapLanguages() {
        viewModel.swapLanguages()
    }

    @objc private func didTapTranslate() {
        viewModel.translate()
    }
}

// MARK: - UITextViewDelegate
extension TranslateViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        inputPlaceholderLabel.isHidden = !textView.text.isEmpty
        viewModel.updateInputText(textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension TranslateViewController: LanguageSelectionDelegate {
    func didSelectLanguage(_ language: Language) {
        guard let button = activeLanguageButton else { return }
        
        let newLanguage = language
        
        if newLanguage.name == "Other" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.presentLanguageInputAlert(for: button)
            }
        }
        else {
            if button == sourceLanguageButton {
                updateLanguageSelection(for: button, with: newLanguage)
            } else if button == targetLanguageButton {
                updateLanguageSelection(for: button, with: newLanguage)
            }
        }
    }
}

extension TranslateViewController {
    private func presentLanguageInputAlert(for button: UIButton) {
    let alertController = UIAlertController(
        title: "Enter Language",
        message: "Please enter the name of the language you want to use.",
        preferredStyle: .alert
    )
    
    alertController.addTextField { textField in
        textField.placeholder = "Language name"
        textField.autocapitalizationType = .words
    }
    
    let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
        guard let self = self,
              let languageName = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !languageName.isEmpty else { return }
        
        let customLanguage = Language(name: languageName, code: languageName, flag: "")
        self.updateLanguageSelection(for: button, with: customLanguage)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alertController.addAction(confirmAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true)
}
    
    private func updateLanguageSelection(for button: UIButton, with language: Language) {
        if button == sourceLanguageButton {
            viewModel.updateLanguage(isSource: true, newLanguage: language)
            sourceLanguageButton.setTitle("\(language.name)", for: .normal)
        } else if button == targetLanguageButton {
            viewModel.updateLanguage(isSource: false, newLanguage: language)
            targetLanguageButton.setTitle("\(language.name)", for: .normal)
        }
    }

}


