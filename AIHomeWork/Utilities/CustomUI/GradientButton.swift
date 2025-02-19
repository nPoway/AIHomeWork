import UIKit

class GradientButton: UIButton {
    
    private let gradientLayer = CAGradientLayer()
    
    // Цвета градиента (слева направо)
    private let gradientColors: [CGColor] = [
        UIColor(hex: "#00328F")?.cgColor ?? UIColor.blue.cgColor,
        UIColor(hex: "#3577F2")?.cgColor ?? UIColor.systemBlue.cgColor,
        UIColor(hex: "#B0CCFF")?.cgColor ?? UIColor.cyan.cgColor
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
        // Горизонтальный градиент: startPoint слева, endPoint справа
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1.0, y: 0.5)
        
        // Добавляем слой в начало (под текст)
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Скруглённые углы
        layer.cornerRadius = 22
        clipsToBounds = true
        
        // Текст кнопки по умолчанию — белый
        setTitleColor(.white, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Обновляем фрейм градиента, чтобы он растягивался по всей кнопке
        gradientLayer.frame = bounds
    }
}
