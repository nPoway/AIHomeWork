import UIKit

class BlurredGradientView: UIView {
    
    private let blurView = UIVisualEffectView(effect: nil)
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        blurView.effect = blurEffect
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)
        
        gradientLayer.colors = [
            UIColor(hex: "#0E0E11", alpha: 0.90).cgColor,
            UIColor(hex: "#000000", alpha: 0.75).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = bounds
        
        blurView.contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        gradientLayer.frame = blurView.bounds
    }
}
