import UIKit

protocol SegmentButtonsViewDelegate: AnyObject {
    func didSelectSegment(_ index: Int)
}

final class SegmentButtonsView: UIStackView {
    
    weak var delegate: SegmentButtonsViewDelegate?
    
    private let scanButton = UIButton(type: .system)
    private let typeButton = UIButton(type: .system)
    
    // Icons
    private let scanIcon = UIImage(named: "scanIcon")?.withRenderingMode(.alwaysOriginal)
    private let typeIcon = UIImage(named: "typeIcon")?.withRenderingMode(.alwaysOriginal)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStack()
        setupButtons()
        updateSelectedState(isScan: true) // Default selection
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStack() {
        axis = .horizontal
        alignment = .fill
        distribution = .fillEqually
        spacing = 8
    }
    
    private func setupButtons() {
        configureButton(scanButton, title: "Scan", icon: scanIcon)
        configureButton(typeButton, title: "Type", icon: typeIcon)
        
        addArrangedSubview(scanButton)
        addArrangedSubview(typeButton)
    }
    
    private func configureButton(_ button: UIButton, title: String, icon: UIImage?) {
        // Title
        button.setTitle(title, for: .normal)
        // Icon on the left
        if let image = icon {
            button.setImage(image, for: .normal)
        }
        // Adjust insets so the icon is left and text is right
        button.semanticContentAttribute = .forceLeftToRight
        
        // Appearance
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.tintColor = .white
        
        // Content insets (for top/bottom/left/right spacing)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        // Add tap
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        let isScanSelected = (sender == scanButton)
        updateSelectedState(isScan: isScanSelected)
        let selectedIndex = isScanSelected ? 0 : 1
        delegate?.didSelectSegment(selectedIndex)
    }
    
    private func updateSelectedState(isScan: Bool) {
        // Set background colors for selected / non‐selected
        if isScan {
            scanButton.backgroundColor = .systemBlue
            typeButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        } else {
            typeButton.backgroundColor = .systemBlue
            scanButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }
    }
    
    // Optional: Expose a method to programmatically select a segment
    func selectSegmentAtIndex(_ index: Int) {
        updateSelectedState(isScan: (index == 0))
    }
}
