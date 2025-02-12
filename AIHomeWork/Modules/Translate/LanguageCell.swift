import UIKit

final class LanguageCell: UITableViewCell {
    
    static let identifier = "LanguageCell"
    
    private let flagImageView = UIImageView()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        view.layer.cornerRadius = 12
        return view
    }()
    
    // Констрейнты, которые будем изменять
    private var flagWidthConstraint: NSLayoutConstraint!
    private var flagHeightConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(flagImageView)
        containerView.addSubview(nameLabel)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        flagImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Первоначальные ограничения для обычных флагов
        flagWidthConstraint = flagImageView.widthAnchor.constraint(equalToConstant: 32)
        flagHeightConstraint = flagImageView.heightAnchor.constraint(equalToConstant: 24)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            containerView.heightAnchor.constraint(equalToConstant: 50),
            
            flagImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            flagImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            flagWidthConstraint, // Активируем здесь
            flagHeightConstraint,
            
            nameLabel.leadingAnchor.constraint(equalTo: flagImageView.trailingAnchor, constant: 15),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with language: Language) {
        flagImageView.image = UIImage(named: language.flag)
        nameLabel.text = language.name
        
        // Проверяем, если это "Other", меняем размер
        if language.code == "other" {
            flagWidthConstraint.constant = 28
            flagHeightConstraint.constant = 24
        } else {
            flagWidthConstraint.constant = 32
            flagHeightConstraint.constant = 24
        }
        
        // Перерисовываем layout
        layoutIfNeeded()
    }
}
