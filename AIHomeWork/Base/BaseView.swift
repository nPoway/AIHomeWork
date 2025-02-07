import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        setupUI()
        setupConstraints()
        setupTargets()
    }
    
    func setupUI() {}
    func setupConstraints() {}
    func setupTargets() {}
}
