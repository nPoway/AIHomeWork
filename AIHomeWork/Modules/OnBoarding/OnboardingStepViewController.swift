import UIKit

class OnboardingStepViewController: UIViewController {
    
    // MARK: - Публичные свойства
    
    /// Картинка на экране
    let stepImage: UIImage?
    /// Заголовок
    let titleText: String
    /// Подзаголовок
    let subtitleText: String
    /// Текст на кнопке
    let buttonTitle: String
    
    /// Коллбэк, который вызывается при нажатии на "Continue"/"Finish"
    var onContinue: (() -> Void)?
    
    // MARK: - UI
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let continueButton = UIButton(type: .system)
    
    // MARK: - Инициализаторы
    
    init(image: UIImage?, titleText: String, subtitleText: String, buttonTitle: String) {
        self.stepImage = image
        self.titleText = titleText
        self.subtitleText = subtitleText
        self.buttonTitle = buttonTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Жизненный цикл
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Приватные методы
    
    private func setupViews() {
        // Настройка imageView
        imageView.image = stepImage
        imageView.contentMode = .scaleAspectFit
        
        // Настройка titleLabel
        titleLabel.text = titleText
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        // Настройка subtitleLabel
        subtitleLabel.text = subtitleText
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        // Настройка continueButton
        continueButton.setTitle(buttonTitle, for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        
        // Добавляем subviews
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(continueButton)
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Примерное расположение: картинка сверху
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Заголовок под картинкой
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // Подзаголовок под заголовком
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // Кнопка снизу
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 44),
            continueButton.widthAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    @objc private func handleContinue() {
        onContinue?()
    }
}
