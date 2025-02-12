import UIKit

protocol CropViewDelegate: AnyObject {
    func cropViewDidChangeCropRect(_ cropView: CropView, newCropRect: CGRect)
}

final class CropView: UIView {
    
    // MARK: - Subviews / Sublayers
    
    private let borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.lightGray.cgColor
        layer.lineWidth = 0.5
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    private let cornerMarkers: [CAShapeLayer] = {
        return (0..<4).map { _ in CAShapeLayer() }
    }()
    
    private let edgeMarkers: [CAShapeLayer] = {
        return (0..<4).map { _ in CAShapeLayer() }
    }()
    
    private var cornerGestureViews = [UIView]()
    private var edgeGestureViews = [UIView]()
    
    private let centerGestureView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Public Properties
    
    weak var delegate: CropViewDelegate?
    
    var cropRect: CGRect = CGRect(x: 50, y: 100, width: 250, height: 350) {
        didSet {
            setNeedsLayout()
            delegate?.cropViewDidChangeCropRect(self, newCropRect: cropRect)
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.addSublayer(borderLayer)
        cornerMarkers.forEach { layer.addSublayer($0) }
        edgeMarkers.forEach { layer.addSublayer($0) }
        
        setupGestureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        updateMask()
        updateBorder()
        positionCornerMarkers()
        positionEdgeMarkers()
        
        layoutCenterGestureView()
        layoutCornerGestureViews()
        layoutEdgeGestureViews()
    }
    
    // MARK: - Private Layout Helpers
    
    private func updateMask() {
        let maskLayer = CAShapeLayer()
        let outerPath = UIBezierPath(rect: bounds)
        let holePath = UIBezierPath(rect: cropRect)
        outerPath.append(holePath)
        
        maskLayer.path = outerPath.cgPath
        maskLayer.fillRule = .evenOdd
        layer.mask = maskLayer
    }
    
    private func updateBorder() {
        let path = UIBezierPath(rect: cropRect)
        borderLayer.path = path.cgPath
    }
    
    private func positionCornerMarkers() {
        let markerSize: CGFloat = 20
        let lineWidth: CGFloat = 3
        
        let cornerPositions: [(CGPoint, Bool, Bool)] = [
            (CGPoint(x: cropRect.minX, y: cropRect.minY), true, false),   // Top-left
            (CGPoint(x: cropRect.maxX, y: cropRect.minY), false, false),  // Top-right
            (CGPoint(x: cropRect.minX, y: cropRect.maxY), true, true),    // Bottom-left
            (CGPoint(x: cropRect.maxX, y: cropRect.maxY), false, true)    // Bottom-right
        ]
        
        for (index, (position, flipHorizontal, flipVertical)) in cornerPositions.enumerated() {
            let path = UIBezierPath()
            
            if flipHorizontal {
                if flipVertical {
                    // Bottom-left
                    path.move(to: CGPoint(x: position.x, y: position.y - markerSize))
                    path.addLine(to: position)
                    path.addLine(to: CGPoint(x: position.x + markerSize, y: position.y))
                } else {
                    // Top-left
                    path.move(to: CGPoint(x: position.x, y: position.y + markerSize))
                    path.addLine(to: position)
                    path.addLine(to: CGPoint(x: position.x + markerSize, y: position.y))
                }
            } else {
                if flipVertical {
                    // Bottom-right
                    path.move(to: CGPoint(x: position.x, y: position.y - markerSize))
                    path.addLine(to: position)
                    path.addLine(to: CGPoint(x: position.x - markerSize, y: position.y))
                } else {
                    // Top-right
                    path.move(to: CGPoint(x: position.x, y: position.y + markerSize))
                    path.addLine(to: position)
                    path.addLine(to: CGPoint(x: position.x - markerSize, y: position.y))
                }
            }
            
            cornerMarkers[index].path = path.cgPath
            cornerMarkers[index].strokeColor = UIColor.lightGray.cgColor
            
            cornerMarkers[index].lineWidth = lineWidth
            cornerMarkers[index].fillColor = UIColor.clear.cgColor
        }
    }
    
    private func positionEdgeMarkers() {
        let edgeLength: CGFloat = 30
        let lineWidth: CGFloat = 3
        
        let edgePositions: [(CGPoint, CGPoint)] = [
            (CGPoint(x: cropRect.midX - edgeLength / 2, y: cropRect.minY),
             CGPoint(x: cropRect.midX + edgeLength / 2, y: cropRect.minY)), // Top
            
            (CGPoint(x: cropRect.midX - edgeLength / 2, y: cropRect.maxY),
             CGPoint(x: cropRect.midX + edgeLength / 2, y: cropRect.maxY)), // Bottom
            
            (CGPoint(x: cropRect.minX, y: cropRect.midY - edgeLength / 2),
             CGPoint(x: cropRect.minX, y: cropRect.midY + edgeLength / 2)), // Left
            
            (CGPoint(x: cropRect.maxX, y: cropRect.midY - edgeLength / 2),
             CGPoint(x: cropRect.maxX, y: cropRect.midY + edgeLength / 2))  // Right
        ]
        
        for (index, (start, end)) in edgePositions.enumerated() {
            let path = UIBezierPath()
            path.move(to: start)
            path.addLine(to: end)
            
            edgeMarkers[index].path = path.cgPath
            edgeMarkers[index].strokeColor = UIColor.lightGray.cgColor
            edgeMarkers[index].lineWidth = lineWidth
            edgeMarkers[index].fillColor = UIColor.clear.cgColor
        }
    }
    
    // MARK: - Gesture Setup
    
    private func setupGestureViews() {
        addSubview(centerGestureView)
        let panCenter = UIPanGestureRecognizer(target: self, action: #selector(handleCenterPan(_:)))
        centerGestureView.addGestureRecognizer(panCenter)
        
        for _ in 0..<4 {
            let cornerView = UIView()
            cornerView.backgroundColor = .clear
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handleCornerPan(_:)))
            cornerView.addGestureRecognizer(pan)
            cornerGestureViews.append(cornerView)
            addSubview(cornerView)
        }
        
        for _ in 0..<4 {
            let edgeView = UIView()
            edgeView.backgroundColor = .clear
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
            edgeView.addGestureRecognizer(pan)
            edgeGestureViews.append(edgeView)
            addSubview(edgeView)
        }
    }
    
    private func layoutCenterGestureView() {
        centerGestureView.frame = cropRect
    }
    
    private func layoutCornerGestureViews() {
        let hotZoneSize: CGFloat = 44
        
        let cornerPositions: [CGPoint] = [
            CGPoint(x: cropRect.minX, y: cropRect.minY),
            CGPoint(x: cropRect.maxX, y: cropRect.minY),
            CGPoint(x: cropRect.minX, y: cropRect.maxY),
            CGPoint(x: cropRect.maxX, y: cropRect.maxY)
        ]
        
        for (i, position) in cornerPositions.enumerated() {
            cornerGestureViews[i].frame = CGRect(
                x: position.x - hotZoneSize / 2,
                y: position.y - hotZoneSize / 2,
                width: hotZoneSize,
                height: hotZoneSize
            )
        }
    }
    
    private func layoutEdgeGestureViews() {
        let thickness: CGFloat = 44
        
        // 0 = Top
        edgeGestureViews[0].frame = CGRect(
            x: cropRect.minX,
            y: cropRect.minY - thickness/2,
            width: cropRect.width,
            height: thickness
        )
        // 1 = Bottom
        edgeGestureViews[1].frame = CGRect(
            x: cropRect.minX,
            y: cropRect.maxY - thickness/2,
            width: cropRect.width,
            height: thickness
        )
        // 2 = Left
        edgeGestureViews[2].frame = CGRect(
            x: cropRect.minX - thickness/2,
            y: cropRect.minY,
            width: thickness,
            height: cropRect.height
        )
        // 3 = Right
        edgeGestureViews[3].frame = CGRect(
            x: cropRect.maxX - thickness/2,
            y: cropRect.minY,
            width: thickness,
            height: cropRect.height
        )
    }
    
    // MARK: - Gesture Handlers
    
    @objc private func handleCenterPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        var newRect = cropRect
        newRect.origin.x += translation.x
        newRect.origin.y += translation.y
        
        newRect = clampRectToBounds(newRect)
        cropRect = newRect
        
        gesture.setTranslation(.zero, in: self)
    }
    
    @objc private func handleCornerPan(_ gesture: UIPanGestureRecognizer) {
        guard let cornerView = gesture.view else { return }
        
        let translation = gesture.translation(in: self)
        guard let cornerIndex = cornerGestureViews.firstIndex(of: cornerView) else { return }
        
        var newRect = cropRect
        
        switch cornerIndex {
        case 0: // Top-left
            newRect.origin.x += translation.x
            newRect.origin.y += translation.y
            newRect.size.width -= translation.x
            newRect.size.height -= translation.y
        case 1: // Top-right
            newRect.origin.y += translation.y
            newRect.size.width += translation.x
            newRect.size.height -= translation.y
        case 2: // Bottom-left
            newRect.origin.x += translation.x
            newRect.size.width -= translation.x
            newRect.size.height += translation.y
        case 3: // Bottom-right
            newRect.size.width += translation.x
            newRect.size.height += translation.y
        default:
            break
        }
        
        newRect = clampRectToBounds(newRect)
        cropRect = newRect
        
        gesture.setTranslation(.zero, in: self)
    }
    
    @objc private func handleEdgePan(_ gesture: UIPanGestureRecognizer) {
        guard let edgeView = gesture.view else { return }
        
        let translation = gesture.translation(in: self)
        guard let edgeIndex = edgeGestureViews.firstIndex(of: edgeView) else { return }
        
        var newRect = cropRect
        
        switch edgeIndex {
        case 0: // Top
            newRect.origin.y += translation.y
            newRect.size.height -= translation.y
        case 1: // Bottom
            newRect.size.height += translation.y
        case 2: // Left
            newRect.origin.x += translation.x
            newRect.size.width -= translation.x
        case 3: // Right
            newRect.size.width += translation.x
        default:
            break
        }
        
        newRect = clampRectToBounds(newRect)
        cropRect = newRect
        
        gesture.setTranslation(.zero, in: self)
    }
    
    // MARK: - Clamping
    
    private func clampRectToBounds(_ rect: CGRect) -> CGRect {
        var rect = rect
        
        if rect.minX < 0 {
            rect.size.width += rect.minX
            rect.origin.x = 0
        }
        if rect.minY < 0 {
            rect.size.height += rect.minY
            rect.origin.y = 0
        }
        
        if rect.maxX > bounds.width {
            rect.size.width = bounds.width - rect.origin.x
        }
        if rect.maxY > bounds.height {
            rect.size.height = bounds.height - rect.origin.y
        }
        
        if rect.width < 1 { rect.size.width = 1 }
        if rect.height < 1 { rect.size.height = 1 }
        
        return rect
    }
}
