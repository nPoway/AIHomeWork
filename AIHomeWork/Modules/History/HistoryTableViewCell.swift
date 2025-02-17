import UIKit

final class HistoryTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        return view
    }()
    
    private let subjectImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let subjectLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        label.textColor = .white
        return label
    }()
    
    private let firstQuestionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.plusJakartaSans(.regular, size: 15)
        label.textColor = .white
        label.numberOfLines = 4
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.plusJakartaSans(.regular, size: 15)
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(subjectImageView)
        containerView.addSubview(subjectLabel)
        containerView.addSubview(firstQuestionLabel)
        containerView.addSubview(dateLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        subjectImageView.translatesAutoresizingMaskIntoConstraints = false
        subjectLabel.translatesAutoresizingMaskIntoConstraints = false
        firstQuestionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            subjectImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            subjectImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            subjectImageView.widthAnchor.constraint(equalToConstant: 32),
            subjectImageView.heightAnchor.constraint(equalToConstant: 32),
            
            subjectLabel.centerYAnchor.constraint(equalTo: subjectImageView.centerYAnchor),
            subjectLabel.leadingAnchor.constraint(equalTo: subjectImageView.trailingAnchor, constant: 12),
            subjectLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -8),
            
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            dateLabel.centerYAnchor.constraint(equalTo: subjectImageView.centerYAnchor),
            dateLabel.widthAnchor.constraint(equalToConstant: 100),
            
            firstQuestionLabel.topAnchor.constraint(equalTo: subjectImageView.bottomAnchor, constant: 8),
            firstQuestionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            firstQuestionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            firstQuestionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
   
    func configure(with session: RealmChatSession, subject: Subject?) {
        subjectLabel.text = session.subject
        firstQuestionLabel.text = session.firstQuestion
        dateLabel.text = format(date: session.createdAt)
        
        if let subject {
            subjectImageView.image = UIImage(named: subject.imageName)
        } else {
            subjectImageView.image = UIImage.chatLogo
        }
    }
    
    private func format(date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMMM d"
            return formatter.string(from: date)
        }
    }
}
