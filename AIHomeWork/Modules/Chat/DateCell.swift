import UIKit

final class DateCell: UITableViewCell {
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = .gray
        dateLabel.font = .plusJakartaSans(.regular, size: 14)
        dateLabel.textAlignment = .center
        
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(dateString: String) {
        dateLabel.text = dateString
    }
    
    
}
