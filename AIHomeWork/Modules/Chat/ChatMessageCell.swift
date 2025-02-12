import UIKit

final class ChatMessageCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.image = UIImage.avatarIcon
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Кастомное представление с анимацией печати
    private lazy var typingIndicatorView: TypingIndicatorView = {
        let view = TypingIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // Фиксированные размеры для анимации,
        // чтобы при отсутствии текста её размеры гарантированно учитывались в layout
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 46),
            view.heightAnchor.constraint(equalToConstant: 20)
        ])
        return view
    }()
    
    // MARK: - Constraints
    
    private var bubbleLeadingConstraint: NSLayoutConstraint!
    private var bubbleTrailingConstraint: NSLayoutConstraint!
    
    /// Ограничение минимальной высоты для bubbleView в режиме загрузки
    private var loadingBubbleMinHeight: NSLayoutConstraint!
    /// Ограничение минимальной ширины для bubbleView в режиме загрузки
    private var loadingBubbleMinWidth: NSLayoutConstraint!
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        
        // Создаем ограничения для режима загрузки (изначально не активны)
        loadingBubbleMinHeight = bubbleView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        loadingBubbleMinHeight.isActive = false
        
        loadingBubbleMinWidth = bubbleView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        loadingBubbleMinWidth.isActive = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(typingIndicatorView)
    }
    
    private func setupConstraints() {
        let maxBubbleWidth = bubbleView.widthAnchor.constraint(
            lessThanOrEqualTo: contentView.widthAnchor,
            multiplier: 0.80
        )
        maxBubbleWidth.priority = .required
        
        bubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(
            equalTo: avatarImageView.trailingAnchor,
            constant: 8
        )
        bubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -8
        )
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            maxBubbleWidth,
            bubbleLeadingConstraint,
            bubbleTrailingConstraint,
            
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
          
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            typingIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            typingIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with message: OpenAIChatMessage) {
        typingIndicatorView.stopAnimating()
        typingIndicatorView.isHidden = true
        messageLabel.text = message.content
            
       
        loadingBubbleMinHeight.isActive = false
        loadingBubbleMinWidth.isActive = false
        
        switch message.role {
        case "assistant", "system":
            avatarImageView.isHidden = false
            bubbleTrailingConstraint.isActive = false
            bubbleLeadingConstraint.isActive = true
            bubbleView.backgroundColor = .systemBlue
            messageLabel.textColor = .white
            applyCustomBubbleMask(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner])
            
        case "user":
            avatarImageView.isHidden = true
            bubbleLeadingConstraint.isActive = false
            bubbleTrailingConstraint.isActive = true
            bubbleView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
            messageLabel.textColor = .white
            applyCustomBubbleMask(corners: [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner])
            
        default:
            messageLabel.text = "Unknown role"
        }
    }
    
    func configureLoadingBubbleForAssistant() {
        messageLabel.text = ""
        avatarImageView.isHidden = false
        bubbleTrailingConstraint.isActive = false
        bubbleLeadingConstraint.isActive = true
        
        // Активируем ограничения, чтобы фон имел минимальные размеры (и по высоте, и по ширине)
        loadingBubbleMinHeight.isActive = true
        loadingBubbleMinWidth.isActive = true
        
        bubbleView.backgroundColor = .systemBlue
        messageLabel.textColor = .white
        
        typingIndicatorView.startAnimating()
        typingIndicatorView.isHidden = false
    }
    private func applyCustomBubbleMask(corners: CACornerMask) {
            bubbleView.layer.cornerRadius = 12
            bubbleView.layer.maskedCorners = corners
        }
}
