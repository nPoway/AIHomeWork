import UIKit

class BlurredGradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hex: "#0E0E11", alpha: 0.85).cgColor, UIColor(hex: "#000000", alpha: 0.6).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = bounds
        blurView.layer.insertSublayer(gradientLayer, at: 0)
    }
}