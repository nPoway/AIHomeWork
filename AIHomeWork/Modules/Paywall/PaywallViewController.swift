//import UIKit
//
//class PaywallViewController: UIViewController {
//    
//    // MARK: - UI
//    
//    private let backgroundImageView = UIImageView()
//    
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Start To Continue\nWith Full Access"
//        label.font = UIFont.plusJakartaSans(.bold, size: 34)
//        label.textColor = .white
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        return label
//    }()
//    
//    private let textView: UITextView = {
//        let tv = UITextView()
//        tv.backgroundColor = .clear
//        tv.isEditable = false
//        tv.isScrollEnabled = false
//        tv.textAlignment = .center
//        return tv
//    }()
//    
//    private let continueButton: GradientButton = {
//        let button = GradientButton()
//        button.setTitle("Start to Continue", for: .normal)
//        button.titleLabel?.font = UIFont.plusJakartaSans(.medium, size: 18)
//        return button
//    }()
//    
//    private let privacyButton = PaywallBottomButton(title: "Privacy Policy")
//    private let restoreButton = PaywallBottomButton(title: "Restore")
//    private let termsButton   = PaywallBottomButton(title: "Terms of Use")
//    
//    var onContinue: (() -> Void)?
//    
//    private var linkRange = NSRange(location: 0, length: 0)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .black
//        
//        setupBackground()
//        setupTextView()
//        setupButtons()
//        setupLayout()
//    }
//    
//    private func setupBackground() {
//        backgroundImageView.image = UIImage(named: "paywall_onb")
//        backgroundImageView.contentMode = .scaleAspectFill
//        view.addSubview(backgroundImageView)
//        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
//            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
//    }
//    
//    private func setupTextView() {
//        let fullText = """
//        Get a trusted companion in learning without limits with a risk-free 3-days free trial, then $7.99/week or proceed with a limited version
//        """
//        let linkText = "or proceed with a limited version"
//        
//        let attributedString = NSMutableAttributedString(string: fullText, attributes: [
//            .font: UIFont.plusJakartaSans(.regular, size: 19),
//            .foregroundColor: UIColor.gray
//        ])
//        
//        linkRange = (fullText as NSString).range(of: linkText)
//        
//        attributedString.addAttributes([
//            .underlineStyle: NSUnderlineStyle.single.rawValue,
//            .foregroundColor: UIColor.gray
//        ], range: linkRange)
//        
//        textView.attributedText = attributedString
//        textView.textAlignment = .center
//        
//        textView.gestureRecognizers?.forEach { textView.removeGestureRecognizer($0) }
//        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTextTap(_:)))
//        
//        tap.delaysTouchesBegan = false
//        tap.delaysTouchesEnded = false
//        textView.addGestureRecognizer(tap)
//        
//        view.addSubview(textView)
//    }
//    
//    private func setupButtons() {
//        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
//        
//        view.addSubview(continueButton)
//        view.addSubview(privacyButton)
//        view.addSubview(restoreButton)
//        view.addSubview(termsButton)
//    }
//   
//    private func setupLayout() {
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        continueButton.translatesAutoresizingMaskIntoConstraints = false
//        privacyButton.translatesAutoresizingMaskIntoConstraints = false
//        restoreButton.translatesAutoresizingMaskIntoConstraints = false
//        termsButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(titleLabel)
//        
//        NSLayoutConstraint.activate([
//            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
//            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            restoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            restoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            
//            privacyButton.trailingAnchor.constraint(equalTo: restoreButton.leadingAnchor, constant: -50),
//            privacyButton.centerYAnchor.constraint(equalTo: restoreButton.centerYAnchor),
//            
//            termsButton.leadingAnchor.constraint(equalTo: restoreButton.trailingAnchor, constant: 50),
//            termsButton.centerYAnchor.constraint(equalTo: restoreButton.centerYAnchor),
//            
//            continueButton.bottomAnchor.constraint(equalTo: termsButton.topAnchor, constant: -5),
//            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            continueButton.heightAnchor.constraint(equalToConstant: 60),
//            
//            textView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -5),
//            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
//            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
//            
//            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            titleLabel.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -5),
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
//            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
//            
//        ])
//    }
//    
//    
//    @objc private func handleContinue() {
//        onContinue?()
//        triggerHapticFeedback(type: .selection)
//    }
//    
//    @objc private func handleTextTap(_ gesture: UITapGestureRecognizer) {
//        let location = gesture.location(in: textView)
//        
//        guard let textPos = getCharacterIndex(at: location) else { return }
//        
//        if NSLocationInRange(textPos, linkRange) {
//            onContinue?()
//            triggerHapticFeedback(type: .selection)
//        }
//    }
//    
//    private func getCharacterIndex(at location: CGPoint) -> Int? {
//        var fraction: CGFloat = 0
//        let layoutManager = textView.layoutManager
//        let textContainer = textView.textContainer
//        let offset = textView.textContainerInset
//        let locationInContainer = CGPoint(x: location.x - offset.left,
//                                          y: location.y - offset.top)
//        
//        let index = layoutManager.characterIndex(for: locationInContainer,
//                                                 in: textContainer,
//                                                 fractionOfDistanceBetweenInsertionPoints: &fraction)
//        
//        if index >= textView.attributedText.length {
//            return nil
//        }
//        return index
//    }
//}
