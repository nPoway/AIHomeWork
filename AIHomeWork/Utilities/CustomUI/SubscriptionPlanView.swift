import UIKit

class SubscriptionPlanView: UIControl {
    
    private let checkImageView = UIImageView()
    private let planNameLabel = UILabel()
    private let priceLabel = UILabel()
    private let trialLabel = UILabel()
    
    private let gradientLayer = CAGradientLayer()
    
    private let gradientColors: [CGColor] = [
        UIColor(hex: "#B0CCFF").cgColor,
        UIColor(hex: "#3577F2").cgColor,
        UIColor(hex: "#00328F").cgColor
    ]
    
    init(planName: String, priceText: String, trialText: String) {
        super.init(frame: .zero)
        
        checkImageView.image = UIImage.checkmarkIcon
        
        planNameLabel.text = planName
        planNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        planNameLabel.textColor = .white
        
        priceLabel.text = priceText
        priceLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        priceLabel.textColor = .white
        
        trialLabel.text = trialText
        trialLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        trialLabel.textColor = .gray
        
        setupViews()
        setupConstraints()
        setupGradient()
        
        layer.cornerRadius = 12
        clipsToBounds = true
        
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        
        gradientLayer.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [checkImageView, planNameLabel, priceLabel, trialLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupGradient() {
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1.0, y: 0.5)
    
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            checkImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            checkImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            planNameLabel.leadingAnchor.constraint(equalTo: checkImageView.trailingAnchor, constant: 15),
            planNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            priceLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            trialLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            trialLabel.leadingAnchor.constraint(equalTo: planNameLabel.leadingAnchor),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
        ])
    }
    
    func updateTrialText(_ text: String) {
        trialLabel.text = text
    }
    
    func updatePrice(_ text: String) {
        priceLabel.text = text
    }
    
    override var isSelected: Bool {
        didSet { updateSelectionUI() }
    }
    
    private func updateSelectionUI() {
        if isSelected {
            gradientLayer.isHidden = false
            checkImageView.image = UIImage.checkmarkFilled
            
            planNameLabel.textColor = .white
            priceLabel.textColor = .white
            trialLabel.textColor = .white
        }
        else {
            gradientLayer.isHidden = true
            backgroundColor = UIColor.white.withAlphaComponent(0.1)
            
            checkImageView.image = UIImage.checkmarkIcon
            planNameLabel.textColor = .white
            priceLabel.textColor = .white
            trialLabel.textColor = .gray
        }
    }
}
