import UIKit

class PaywallTrialController: UIViewController {
    
    // MARK: - UI
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "xmark")?.resizeImage(to: CGSize(width: 20, height: 20))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let backgroundImageView = UIImageView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Start To Continue\nWith Full Access"
        label.font = UIFont.plusJakartaSans(.bold, size: 34)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let planWeek   = SubscriptionPlanView(planName: "Week",   priceText: "$7.99",  trialText: "Get a Plan")
    private let planMonth  = SubscriptionPlanView(planName: "Month",  priceText: "$14.99", trialText: "Get a Plan")
    private let planYear   = SubscriptionPlanView(planName: "Year",   priceText: "$83.99", trialText: "Get a Plan")
    
    private let plansStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.spacing = 5
        return stack
    }()
    
    private let trialContainer = UIView()
    
    private let trialLabel: UILabel = {
        let label = UILabel()
        label.text = "Free Trial Disabled"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .white
        return label
    }()
    private let trialSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = UIColor.systemBlue
        sw.isOn = false
        return sw
    }()
    
    // Кнопка Subscribe
    private let subscribeButton: GradientButton = {
        let button = GradientButton()
        button.setTitle("Subscribe", for: .normal)
        button.titleLabel?.font = UIFont.plusJakartaSans(.medium, size: 18)
        return button
    }()
    
    // Три кнопки снизу
    private let privacyButton = PaywallBottomButton(title: "Privacy Policy")
    private let restoreButton = PaywallBottomButton(title: "Restore")
    private let termsButton   = PaywallBottomButton(title: "Terms of Use")
    
    private var selectedPlan: SubscriptionPlanView?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupBackground()
        setupCloseButton()
        setupTitleLabel()
        setupPlans()
        setupTrialSwitcher()
        setupSubscribeButton()
        setupBottomButtons()
        setupConstraints()
        trialSwitch.addTarget(self, action: #selector(handleTrialSwitchChange), for: .valueChanged)
        
        subscribeButton.addTarget(self, action: #selector(handleSubscribe), for: .touchUpInside)
        
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        
        planWeek.addTarget(self, action: #selector(handlePlanTap(_:)), for: .touchUpInside)
        planMonth.addTarget(self, action: #selector(handlePlanTap(_:)), for: .touchUpInside)
        planYear.addTarget(self, action: #selector(handlePlanTap(_:)), for: .touchUpInside)
        
        selectPlan(planWeek)
    }
   
    
    private func setupBackground() {
        backgroundImageView.image = UIImage(named: "paywall_trial")
        backgroundImageView.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupCloseButton() {
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupPlans() {
        plansStack.addArrangedSubview(planWeek)
        plansStack.addArrangedSubview(planMonth)
        plansStack.addArrangedSubview(planYear)
        
        view.addSubview(plansStack)
        plansStack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupTrialSwitcher() {
        trialContainer.addSubview(trialLabel)
        trialContainer.addSubview(trialSwitch)
        trialContainer.translatesAutoresizingMaskIntoConstraints = false
        trialLabel.translatesAutoresizingMaskIntoConstraints = false
        trialSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        trialContainer.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        trialContainer.layer.cornerRadius = 20
        
        view.addSubview(trialContainer)
        NSLayoutConstraint.activate([
            trialContainer.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupSubscribeButton() {
        view.addSubview(subscribeButton)
        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupBottomButtons() {
        view.addSubview(privacyButton)
        view.addSubview(restoreButton)
        view.addSubview(termsButton)
        
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Фон
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: iphoneWithButton ? -150 : -110),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            
            plansStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            plansStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            plansStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trialContainer.topAnchor.constraint(equalTo: plansStack.bottomAnchor, constant: 5),
            trialContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trialContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trialLabel.leadingAnchor.constraint(equalTo: trialContainer.leadingAnchor, constant: 15),
            trialLabel.centerYAnchor.constraint(equalTo: trialContainer.centerYAnchor),
            
            trialSwitch.trailingAnchor.constraint(equalTo: trialContainer.trailingAnchor, constant: -12),
            trialSwitch.centerYAnchor.constraint(equalTo: trialContainer.centerYAnchor),
            
            subscribeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subscribeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            subscribeButton.heightAnchor.constraint(equalToConstant: 60),
            subscribeButton.bottomAnchor.constraint(equalTo: restoreButton.topAnchor, constant: iphoneWithButton ? -5 : -20),
            
            restoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            privacyButton.centerYAnchor.constraint(equalTo: restoreButton.centerYAnchor),
            privacyButton.trailingAnchor.constraint(equalTo: restoreButton.leadingAnchor, constant: -50),
            
            termsButton.centerYAnchor.constraint(equalTo: restoreButton.centerYAnchor),
            termsButton.leadingAnchor.constraint(equalTo: restoreButton.trailingAnchor, constant: 50),
        ])
    }
    
    // MARK: - Actions
    
    @objc
    private func handleTrialSwitchChange() {
        if trialSwitch.isOn {
            trialLabel.text = "Free Trial Enabled"
            planWeek.updateTrialText("3-days Free Trial")
            planMonth.updateTrialText("3-days Free Trial")
            planMonth.updatePrice("$15.99")
            planYear.updateTrialText("3-days Free Trial")
            planYear.updatePrice("$99.99")
        } else {
            trialLabel.text = "Free Trial Disabled"
            
            planWeek.updateTrialText("Get a Plan")
            planMonth.updateTrialText("Get a Plan")
            planMonth.updatePrice("$14.99")
            planYear.updateTrialText("Get a Plan")
            planYear.updatePrice("$83.99")
        }
    }
    
    @objc private func handleSubscribe() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handlePlanTap(_ sender: SubscriptionPlanView) {
        selectPlan(sender)
    }
    private func selectPlan(_ plan: SubscriptionPlanView) {
        selectedPlan?.isSelected = false
        selectedPlan = plan
        plan.isSelected = true
    }
}
