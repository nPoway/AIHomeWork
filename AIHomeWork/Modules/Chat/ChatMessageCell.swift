import UIKit
import SwiftMath

final class ChatMessageCell: UITableViewCell {

    // MARK: - UI Elements
    
    private lazy var segmentsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.image = UIImage.avatarIcon
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var attachedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isHidden = true
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
        label.textColor = .white
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var typingIndicatorView: TypingIndicatorView = {
        let view = TypingIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 46),
            view.heightAnchor.constraint(equalToConstant: 20)
        ])
        return view
    }()
    
    // MARK: - Constraints
    
    private var bubbleLeadingConstraint: NSLayoutConstraint!
    private var bubbleTrailingConstraint: NSLayoutConstraint!
    private var bubbleBottomConstraintNoImage: NSLayoutConstraint!
    private var bubbleBottomConstraintWithImage: NSLayoutConstraint!
    private var attachedImageLeadingConstraint: NSLayoutConstraint!
    private var attachedImageTrailingConstraint: NSLayoutConstraint!
    private var attachedImageBottomConstraint: NSLayoutConstraint!
    private var loadingBubbleMinHeight: NSLayoutConstraint!
    private var loadingBubbleMinWidth: NSLayoutConstraint!
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
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
        contentView.addSubview(attachedImageView)
        
        bubbleView.addSubview(segmentsContainer)
        NSLayoutConstraint.activate([
            segmentsContainer.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            segmentsContainer.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            segmentsContainer.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            segmentsContainer.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let maxBubbleWidth = bubbleView.widthAnchor.constraint(
            lessThanOrEqualTo: contentView.widthAnchor,
            multiplier: 0.80
        )
        maxBubbleWidth.priority = .required
        maxBubbleWidth.isActive = true
        
        bubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(
            equalTo: avatarImageView.trailingAnchor,
            constant: 8
        )
        bubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -8
        )
        bubbleLeadingConstraint.isActive = false
        bubbleTrailingConstraint.isActive = false
        
        let bubbleTopConstraint = bubbleView.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: 8
        )
        bubbleTopConstraint.isActive = true
        
        bubbleBottomConstraintNoImage = bubbleView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -8
        )
        bubbleBottomConstraintNoImage.isActive = true
        
        bubbleBottomConstraintWithImage = bubbleView.bottomAnchor.constraint(
            equalTo: attachedImageView.topAnchor,
            constant: -8
        )
        bubbleBottomConstraintWithImage.isActive = false
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            typingIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            typingIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor)
        ])
        
        attachedImageLeadingConstraint = attachedImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor)
        attachedImageLeadingConstraint.isActive = false
        
        attachedImageTrailingConstraint = attachedImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor)
        attachedImageTrailingConstraint.isActive = false
        
        attachedImageBottomConstraint = attachedImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        attachedImageBottomConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            attachedImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 180),
            attachedImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 150)
        ])
        
        attachedImageView.isHidden = true
    }
    
    // MARK: - Configuration
    
    func configure(with message: OpenAIChatMessage, tableView: UITableView,
                   indexPath: IndexPath,
                   animationDidFinish: (() -> Void)? = nil) {
        
        messageLabel.isHidden = false
        messageLabel.text     = nil
        segmentsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        typingIndicatorView.stopAnimating()
        typingIndicatorView.isHidden = true
        loadingBubbleMinHeight.isActive = false
        loadingBubbleMinWidth.isActive  = false
        attachedImageView.isHidden      = true
        attachedImageView.image         = nil
        bubbleBottomConstraintNoImage.isActive  = false
        bubbleBottomConstraintWithImage.isActive = false
        attachedImageLeadingConstraint.isActive  = false
        attachedImageTrailingConstraint.isActive = false
        
        
        switch message.role {
        case "assistant", "system":
            avatarImageView.isHidden = false
            bubbleTrailingConstraint.isActive = false
            bubbleLeadingConstraint.isActive = true
            bubbleView.backgroundColor = .customPrimary
            applyCustomBubbleMask(corners: [.layerMinXMaxYCorner,
                                            .layerMaxXMaxYCorner,
                                            .layerMaxXMinYCorner])
            
            messageLabel.isHidden = true
            
            let segments = message.segments
            
            
            if message.isLoading {
                print("message is loading")
                configureLoadingBubbleForAssistant()
            }
            else if segments.contains(where: { if case .latex = $0 { return true } else { return false } }) {
                for segment in message.segments {
                    switch segment {
                    case .text(let txt):
                        let lbl = UILabel()
                        lbl.numberOfLines = 0
                        lbl.font = messageLabel.font
                        lbl.textColor = messageLabel.textColor
                        lbl.text = txt.trimmingCharacters(in: .newlines)
                        segmentsContainer.addArrangedSubview(lbl)
                        
                    case .latex(let formula, let isInline):
                        let ml = MTMathUILabel()
                        ml.labelMode = isInline ? .text : .display
                        ml.fontSize  = messageLabel.font.pointSize
                        ml.textColor = messageLabel.textColor
                        ml.translatesAutoresizingMaskIntoConstraints = false
                        segmentsContainer.addArrangedSubview(ml)
                        NSLayoutConstraint.activate([
                            ml.widthAnchor.constraint(
                                lessThanOrEqualTo: segmentsContainer.widthAnchor
                            )
                        ])
                        ml.latex = formula
                    }
                }
                
                bubbleBottomConstraintNoImage.isActive = true
                animationDidFinish?()
                return
            }
            else if message.needsTypingAnimation {
                messageLabel.isHidden = false
                messageLabel.text = ""
                DispatchQueue.main.async {
                    self.animateTypingEffect(
                        in: tableView,
                        at: indexPath,
                        text: message.content
                    ) {
                        animationDidFinish?()
                    }
                }
            }
            else {
                messageLabel.isHidden = false
                messageLabel.text = message.content
            }
            
        case "user":
            avatarImageView.isHidden = true
            bubbleLeadingConstraint.isActive = false
            bubbleTrailingConstraint.isActive = true
            bubbleView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
            messageLabel.text = message.content
            messageLabel.textColor = .white
            applyCustomBubbleMask(corners: [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner])
            attachedImageLeadingConstraint.isActive = false
            attachedImageTrailingConstraint.isActive = true
            
        default:
            messageLabel.text = "Unknown role"
        }
        
        if let imageURL = message.imageURL, imageURL.starts(with: "data:image/jpeg;base64,") {
            attachedImageView.isHidden = false
            bubbleBottomConstraintNoImage.isActive = false
            bubbleBottomConstraintWithImage.isActive = true
            let base64String = imageURL.replacingOccurrences(of: "data:image/jpeg;base64,", with: "")
            attachedImageView.image = UIImage.fromBase64(base64String)
            if messageLabel.text == "" {
                bubbleView.backgroundColor = .clear
            }
        } else {
            attachedImageView.isHidden = true
            attachedImageView.image = nil
            bubbleBottomConstraintWithImage.isActive = false
            bubbleBottomConstraintNoImage.isActive = true
        }
    }
    
    private func animateTypingEffect(in tableView: UITableView,
                                     at indexPath: IndexPath,
                                     text: String,
                                     completion: @escaping () -> Void)
    {
        guard !text.isEmpty else {
            completion()
            return
        }
        
        messageLabel.text = ""
        
        var currentIndex = 0
        let characters = Array(text)

        let timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            DispatchQueue.main.async {
                if currentIndex < characters.count {
                    self.messageLabel.text?.append(characters[currentIndex])
                    currentIndex += 1
                    tableView.beginUpdates()
                    tableView.endUpdates()
                    tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                } else {
                    timer.invalidate()
                    completion()
                }
            }
        }
        RunLoop.main.add(timer, forMode: .common)
    }



    
    func configureLoadingBubbleForAssistant() {
        segmentsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        messageLabel.text = ""
        attachedImageView.image = nil
        attachedImageView.isHidden = true
        avatarImageView.isHidden = false
        bubbleTrailingConstraint.isActive = false
        bubbleLeadingConstraint.isActive = true
        loadingBubbleMinHeight.isActive = true
        loadingBubbleMinWidth.isActive = true
        bubbleView.backgroundColor = .customPrimary
        messageLabel.textColor = .white
        typingIndicatorView.startAnimating()
        typingIndicatorView.isHidden = false
    }
    
    // MARK: - Private Methods
    
    private func applyCustomBubbleMask(corners: CACornerMask) {
        bubbleView.layer.cornerRadius = 12
        bubbleView.layer.maskedCorners = corners
    }
}
