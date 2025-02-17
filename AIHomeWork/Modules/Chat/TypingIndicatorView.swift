import UIKit

class TypingIndicatorView: UIView {
    
    private let dotSize: CGFloat = 10.0
    private let dotSpacing: CGFloat = 8.0
    private var dotViews: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDots()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDots()
    }
   
    
    private func setupDots() {
        for _ in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = .white 
            dot.layer.cornerRadius = dotSize / 2
            dot.translatesAutoresizingMaskIntoConstraints = false
            addSubview(dot)
            dotViews.append(dot)
        }
        
        for (index, dot) in dotViews.enumerated() {
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.heightAnchor.constraint(equalToConstant: dotSize),
                dot.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
            
            if index == 0 {
                dot.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            } else {
                dot.leadingAnchor.constraint(equalTo: dotViews[index - 1].trailingAnchor, constant: dotSpacing).isActive = true
            }
            
            if index == dotViews.count - 1 {
                dot.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            }
        }
    }
  
    func startAnimating() {
        for (index, dot) in dotViews.enumerated() {
            animateDot(dot, delay: Double(index) * 0.1)
        }
    }
   
    private func animateDot(_ dot: UIView, delay: Double) {
        UIView.animate(withDuration: 0.6,
                       delay: delay,
                       options: [.repeat, .autoreverse],
                       animations: {
                           dot.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                       },
                       completion: nil)
    }
   
    func stopAnimating() {
        for dot in dotViews {
            dot.layer.removeAllAnimations()
        }
    }
}
