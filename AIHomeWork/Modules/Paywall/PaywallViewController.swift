import UIKit

class PaywallViewController: UIViewController {
    
    // MARK: - UI Элементы
    private let backgroundImageView = UIImageView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Start To Continue\nWith Full Access"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UITextView = {
        let textView = UITextView()
        let fullText = "Get a trusted companion in learning without limits with a risk-free 3-days free trial, then $7.99/week or proceed with a limited version"
        
        let attributedString = NSMutableAttributedString(string: fullText)
        let linkRange = (fullText as NSString).range(of: "or proceed with a limited version")
        
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: linkRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSMakeRange(0, fullText.count))
        
        let textView = UITextView()
        textView.attributedText = attributedString
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textAlignment = .center
        textView.delegate = textView
        
        return textView
    }()
    
    private let continueButton: GradientButton = {
        let button = GradientButton()
        button.setTitle("Start to Continue", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return button
    }()
    
    private let privacyButton = PaywallBottomButton(title: "Privacy Policy")
    private let restoreButton = PaywallBottomButton(title: "Restore")
    private let termsButton = PaywallBottomButton(title: "Terms of Use")
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Настройка UI
    private func setupViews() {
        // Фон
        backgroundImageView.image = UIImage(named: "paywall_background")
        backgroundImageView.contentMode = .scaleAspectFill
        
        // Добавляем элементы на экран
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(continueButton)
        view.addSubview(privacyButton)
        view.addSubview(restoreButton)
        view.addSubview(termsButton)
        
        // Добавляем действие на кнопку continue
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Фон
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Заголовок
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // Подзаголовок
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // Кнопка Continue
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Нижние кнопки (Privacy, Restore, Terms)
            restoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            privacyButton.trailingAnchor.constraint(equalTo: restoreButton.leadingAnchor, constant: -20),
            privacyButton.centerYAnchor.constraint(equalTo: restoreButton.centerYAnchor),
            
            termsButton.leadingAnchor.constraint(equalTo: restoreButton.trailingAnchor, constant: 20),
            termsButton.centerYAnchor.constraint(equalTo: restoreButton.centerYAnchor)
        ])
    }
    
    @objc private func handleContinue() {
        print("Continue tapped")
    }
}

// MARK: - Подчёркнутый текст внутри UITextView
extension UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.absoluteString == "dismiss" {
            textView.window?.rootViewController?.dismiss(animated: true, completion: nil)
            return false
        }
        return true
    }
}

// MARK: - Кнопки внизу (Privacy, Restore, Terms)
class PaywallBottomButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.gray, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
