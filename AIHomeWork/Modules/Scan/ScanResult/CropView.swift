import UIKit

final class CropView: UIView {
    
    private let borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 2
        layer.fillColor = UIColor.clear.cgColor
        layer.lineDashPattern = [8, 4] // Пунктирная линия
        return layer
    }()
    
    private let resizeHandles: [UIView] = {
        return (0..<4).map { _ in
            let handle = UIView()
            handle.backgroundColor = .white
            handle.layer.cornerRadius = 4
            return handle
        }
    }()
    
    var cropRect: CGRect = CGRect(x: 50, y: 100, width: 250, height: 350) {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(borderLayer)
        resizeHandles.forEach { addSubview($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBorder()
        positionHandles()
    }
    
    private func updateBorder() {
        let path = UIBezierPath(rect: cropRect)
        borderLayer.path = path.cgPath
    }
    
    private func positionHandles() {
        let handleSize: CGFloat = 16
        let positions: [CGPoint] = [
            CGPoint(x: cropRect.minX - handleSize / 2, y: cropRect.minY - handleSize / 2), // Top-left
            CGPoint(x: cropRect.maxX - handleSize / 2, y: cropRect.minY - handleSize / 2), // Top-right
            CGPoint(x: cropRect.minX - handleSize / 2, y: cropRect.maxY - handleSize / 2), // Bottom-left
            CGPoint(x: cropRect.maxX - handleSize / 2, y: cropRect.maxY - handleSize / 2)  // Bottom-right
        ]
        
        for (index, handle) in resizeHandles.enumerated() {
            handle.frame = CGRect(origin: positions[index], size: CGSize(width: handleSize, height: handleSize))
        }
    }
    
    // Позже сюда можно добавить жесты для изменения размера cropRect
}
