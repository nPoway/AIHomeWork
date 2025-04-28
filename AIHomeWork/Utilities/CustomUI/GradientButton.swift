import UIKit

class GradientButton: UIButton {
    
    private let gradientLayer = CAGradientLayer()
    
    private let gradientColors: [CGColor] = [
        UIColor(hex: "#B0CCFF").cgColor,
        UIColor(hex: "#3577F2").cgColor,
        UIColor(hex: "#00328F").cgColor
        
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1.0, y: 0.5)
        
        layer.insertSublayer(gradientLayer, at: 0)
        
        layer.cornerRadius = 30
        clipsToBounds = true
        
        setTitleColor(.white, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
