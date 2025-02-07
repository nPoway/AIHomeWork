import UIKit

protocol SegmentButtonsViewDelegate: AnyObject {
    func didSelectSegment(_ index: Int)
}

final class SegmentButtonsView: UIStackView {
    
    weak var delegate: SegmentButtonsViewDelegate?
    
    private let scanButton = UIButton()
    private let typeButton = UIButton()
    
    private let scanIcon = UIImage.scanIcon
    private let typeIcon = UIImage.typeIcon
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStack()
        setupButtons()
        updateSelectedState(isScan: true)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStack() {
        axis = .horizontal
        backgroundColor = .darkGray.withAlphaComponent(0.2)
        layer.cornerRadius = 16
        layer.masksToBounds = true
        alignment = .fill
        distribution = .fillEqually
        spacing = 0
    }
    
    private func setupButtons() {
        configureButton(scanButton, title: "Scan", icon: scanIcon)
        configureButton(typeButton, title: "Type", icon: typeIcon)
        
        addArrangedSubview(scanButton)
        addArrangedSubview(typeButton)
    }
    
    private func configureButton(_ button: UIButton, title: String, icon: UIImage?) {
        button.setTitle(title, for: .normal)

        if let image = icon?.resizeImage(to: CGSize(width: 24, height: 24)) {
            button.setImage(image, for: .normal)
        }
        
        button.semanticContentAttribute = .forceLeftToRight

        let spacing: CGFloat = 4
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
        
        // Appearance
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        button.tintColor = .white
       
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
    }

    
    @objc private func didTapButton(_ sender: UIButton) {
        let isScanSelected = (sender == scanButton)
        updateSelectedState(isScan: isScanSelected)
        let selectedIndex = isScanSelected ? 0 : 1
        delegate?.didSelectSegment(selectedIndex)
    }
    
    private func updateSelectedState(isScan: Bool) {
        if isScan {
            scanButton.backgroundColor = .systemBlue
            typeButton.backgroundColor = .clear
        }
        else {
            typeButton.backgroundColor = .systemBlue
            scanButton.backgroundColor = .clear
        }
    }
   
    func selectSegmentAtIndex(_ index: Int) {
        updateSelectedState(isScan: (index == 0))
    }
}
