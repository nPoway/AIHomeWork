final class SettingsCell: UITableViewCell {
    static let identifier = "SettingsCell"
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let arrowView = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        iconView.tintColor = .white
        
        arrowView.tintColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [iconView, titleLabel, UIView(), arrowView])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(title: String, icon: UIImage?) {
        titleLabel.text = title
        iconView.image = icon
    }
}