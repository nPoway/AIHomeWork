import UIKit

class OnboardingStepViewController: UIViewController {
    
    let stepImage: UIImage?
    
    let titleText: String
    
    let subtitleText: String
    
    let buttonTitle: String
    
    var onContinue: (() -> Void)?
    
    // MARK: - UI
    
    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let continueButton = GradientButton()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        backgroundImageView.image = stepImage
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.clipsToBounds = true
        
        titleLabel.text = titleText
        titleLabel.font = UIFont.plusJakartaSans(.bold, size: 34)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        subtitleLabel.text = subtitleText
        subtitleLabel.font = UIFont.plusJakartaSans(.regular, size: 17)
        subtitleLabel.textColor = UIColor("#d7dfe8")?.withAlphaComponent(0.6)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
    
        continueButton.setTitle(buttonTitle, for: .normal)
        continueButton.titleLabel?.font = UIFont.plusJakartaSans(.medium, size: 17)
        continueButton.clipsToBounds = true
        
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(continueButton)
    }
    
    private func setupConstraints() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -35),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 60),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            subtitleLabel.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
          
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -2),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35)
        ])
    }
    
    @objc private func handleContinue() {
        triggerHapticFeedback(type: .light)
        onContinue?()
    }
}
