import UIKit

class TypingIndicatorView: UIView {
    
    // Размер точки и расстояние между ними
    private let dotSize: CGFloat = 10.0
    private let dotSpacing: CGFloat = 8.0
    // Массив для хранения точек
    private var dotViews: [UIView] = []
    
    // MARK: - Инициализация
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDots()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDots()
    }
    
    // MARK: - Настройка точек
    
    private func setupDots() {
        // Создаём три точки
        for _ in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = .white 
            dot.layer.cornerRadius = dotSize / 2  // делаем круг
            dot.translatesAutoresizingMaskIntoConstraints = false
            addSubview(dot)
            dotViews.append(dot)
        }
        
        // Расставляем точки горизонтально с помощью Auto Layout
        for (index, dot) in dotViews.enumerated() {
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.heightAnchor.constraint(equalToConstant: dotSize),
                dot.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
            
            if index == 0 {
                // Первая точка привязывается к левому краю родительского view
                dot.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            } else {
                // Остальные точки располагаются справа от предыдущей точки с отступом
                dot.leadingAnchor.constraint(equalTo: dotViews[index - 1].trailingAnchor, constant: dotSpacing).isActive = true
            }
            
            if index == dotViews.count - 1 {
                // Последняя точка привязывается к правому краю родительского view
                dot.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            }
        }
    }
    
    // MARK: - Анимация
    
    /// Запускает анимацию точек
    func startAnimating() {
        for (index, dot) in dotViews.enumerated() {
            animateDot(dot, delay: Double(index) * 0.1)
        }
    }
    
    /// Анимирует одну точку с указанной задержкой
    private func animateDot(_ dot: UIView, delay: Double) {
        UIView.animate(withDuration: 0.6,
                       delay: delay,
                       options: [.repeat, .autoreverse],
                       animations: {
                           // Увеличиваем точку до 1.5 раза
                           dot.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                       },
                       completion: nil)
    }
    
    /// Останавливает анимацию
    func stopAnimating() {
        for dot in dotViews {
            dot.layer.removeAllAnimations()
        }
    }
}
