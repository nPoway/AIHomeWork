import UIKit
import RevenueCat
import Combine

private enum PlanID: String {
    case weekly         = "weekly"
    case weeklyTrial    = "weekly_trial"
    case monthly        = "monthly"
    case monthlyTrial   = "monthly_trial"
    case annual         = "annual"
    case annualTrial    = "annual_trial"
}

class PaywallTrialController: UIViewController {
    
    // MARK: - UI
    
    private let paywallService = PaywallService.shared
    
    private lazy var planMapping: [SubscriptionPlanView: (base: PlanID, trial: PlanID)] = [
        planWeek:  (.weekly,  .weeklyTrial),
        planMonth: (.monthly, .monthlyTrial),
        planYear:  (.annual,  .annualTrial)
    ]
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "xmark")?.resizeImage(to: CGSize(width: 20, height: 20))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let benefitsView: BulletListView = {
        let benefitsView = BulletListView(
            lines: [
                "Unlimited solution requests",
                "Advanced multi-tasking helper",
                "Exclusive tools for various problems",
                "Round-the-clock problem solver"
            ]
        )
        benefitsView.translatesAutoresizingMaskIntoConstraints = false
        return benefitsView
    }()
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.logo)
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        return imageView
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
    
    private let planWeek   = SubscriptionPlanView(planName: "Week",   priceText: "$8.99",  trialText: "Get a Plan")
    private let planMonth  = SubscriptionPlanView(planName: "Month",  priceText: "$15.99", trialText: "Get a Plan")
    private let planYear   = SubscriptionPlanView(planName: "Year",   priceText: "$99.99", trialText: "Get a Plan")
    
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
    
    private let subscribeButton: GradientButton = {
        let button = GradientButton()
        button.setTitle("Subscribe", for: .normal)
        button.titleLabel?.font = UIFont.plusJakartaSans(.medium, size: 18)
        return button
    }()
    
    private let privacyButton = PaywallBottomButton(title: "Privacy Policy")
    private let restoreButton = PaywallBottomButton(title: "Restore")
    private let termsButton   = PaywallBottomButton(title: "Terms of Use")
    
    private var selectedPlan: SubscriptionPlanView?
    
    private var cancellables = Set<AnyCancellable>()
    
    private var packages: [String: Package] = [:]
    private var planPackages: [SubscriptionPlanView: Package] = [:]
    
    private let scrollView  = UIScrollView()
    private let contentView = UIView()
    
    

    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        configureScroll()
        setupBackground()
        setupLogo()
        setupList()
        setupCloseButton()
        setupTitleLabel()
        setupPlans()
        setupTrialSwitcher()
        setupSubscribeButton()
        setupBottomButtons()
        setupConstraints()
        fetchPackages()
        
        trialSwitch.addTarget(self, action: #selector(handleTrialSwitchChange), for: .valueChanged)
        
        subscribeButton.addTarget(self, action: #selector(handleSubscribe), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(handleRestore), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)
        
        planWeek.addTarget(self, action: #selector(handlePlanTap(_:)), for: .touchUpInside)
        planMonth.addTarget(self, action: #selector(handlePlanTap(_:)), for: .touchUpInside)
        planYear.addTarget(self, action: #selector(handlePlanTap(_:)), for: .touchUpInside)
        
        selectPlan(planWeek)
    }
    
    private func configureScroll() {
            view.addSubview(scrollView)
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            scrollView.addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

                contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
            ])
        }
    
    
    
    private func setupBackground() {
        backgroundImageView.image = UIImage(named: "paywall_trial")
        backgroundImageView.contentMode = .scaleAspectFill
        
        contentView.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        if iphoneWithButton {
            NSLayoutConstraint.activate([
                backgroundImageView.heightAnchor.constraint(equalToConstant: 780)
                ])
        }
        else {
            NSLayoutConstraint.activate([
                backgroundImageView.heightAnchor.constraint(equalToConstant: screenSize.height)
            ])
        }
    }
    
    private func setupCloseButton() {
        contentView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupPlans() {
        plansStack.addArrangedSubview(planWeek)
        plansStack.addArrangedSubview(planMonth)
        plansStack.addArrangedSubview(planYear)
        
        contentView.addSubview(plansStack)
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
        
        contentView.addSubview(trialContainer)
        NSLayoutConstraint.activate([
            trialContainer.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupSubscribeButton() {
        contentView.addSubview(subscribeButton)
        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupBottomButtons() {
        contentView.addSubview(privacyButton)
        contentView.addSubview(restoreButton)
        contentView.addSubview(termsButton)
        
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupLogo() {
        contentView.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupList() {
        contentView.addSubview(benefitsView)
        benefitsView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            
            logoImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: screenSize.height > 900 ? 40 : 0),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 160),
            logoImageView.widthAnchor.constraint(equalToConstant: 160),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -24),
            
            benefitsView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            benefitsView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            plansStack.topAnchor.constraint(equalTo: benefitsView.bottomAnchor, constant: 16),
            plansStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            plansStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            trialContainer.topAnchor.constraint(equalTo: plansStack.bottomAnchor, constant: 5),
            trialContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trialContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            trialLabel.leadingAnchor.constraint(equalTo: trialContainer.leadingAnchor, constant: 15),
            trialLabel.centerYAnchor.constraint(equalTo: trialContainer.centerYAnchor),
            
            trialSwitch.trailingAnchor.constraint(equalTo: trialContainer.trailingAnchor, constant: -12),
            trialSwitch.centerYAnchor.constraint(equalTo: trialContainer.centerYAnchor),
            
            subscribeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subscribeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subscribeButton.topAnchor.constraint(greaterThanOrEqualTo: trialContainer.bottomAnchor, constant: 16),
            subscribeButton.heightAnchor.constraint(equalToConstant: 60),
            subscribeButton.bottomAnchor.constraint(equalTo: restoreButton.topAnchor, constant: -5),
            
            restoreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            restoreButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            privacyButton.centerYAnchor.constraint(equalTo: restoreButton.centerYAnchor),
            privacyButton.trailingAnchor.constraint(equalTo: restoreButton.leadingAnchor, constant: -50),
            
            termsButton.centerYAnchor.constraint(equalTo: restoreButton.centerYAnchor),
            termsButton.leadingAnchor.constraint(equalTo: restoreButton.trailingAnchor, constant: 50),
        ])
    }
    
    // MARK: - Actions
    
    @objc
    private func privacyTapped() {
        if let url = URL(string: "https://www.freeprivacypolicy.com/live/5fdd7d4a-ee18-4460-a13f-cd7d06eab6a9") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc
    private func termsTapped() {
        if let url = URL(string: "https://www.freeprivacypolicy.com/live/3800f35a-2ef3-48e5-a7d9-f6974d7eff2a") {
            UIApplication.shared.open(url)
        }
    }

    private func fetchPackages() {
        Task {
            do {
                let fetched = try await paywallService.offerings()
                await MainActor.run { self.configurePackages(fetched) }
            } catch {
                print("[Paywall] Offerings error: \(error.localizedDescription)")
            }
        }
    }
    
    private func configurePackages(_ fetched: [Package]) {
        packages = Dictionary(uniqueKeysWithValues: fetched.map { ($0.identifier, $0) })
        updatePlansUI(trialEnabled: trialSwitch.isOn)
        selectPlan(planWeek)
    }
    
    private func updatePlansUI(trialEnabled: Bool) {
            trialLabel.text = trialEnabled ? "Free Trial Enabled" : "Free Trial Disabled"
            planPackages.removeAll()

            for (view, ids) in planMapping {
                let targetID = (trialEnabled ? ids.trial : ids.base).rawValue
                guard let package = packages[targetID] else { continue }
                planPackages[view] = package
                view.updatePrice(package.storeProduct.localizedPriceString)
                view.updateTrialText(trialEnabled ? "3-days Free Trial" : "Get a Plan")
            }
        }
    
    @objc private func handleTrialSwitchChange() {
        updatePlansUI(trialEnabled: trialSwitch.isOn)
    }
    
    @objc private func handleSubscribe() {
        
        guard let plan = selectedPlan else { return }
        guard let package = planPackages[plan] else { return }
        
        subscribeButton.isEnabled = false
        Task {
            do {
                let success = try await paywallService.purchase(package)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.subscribeButton.isEnabled = true
                    print("Is premium after purchase: \(paywallService.isPremium)")
                    if success, paywallService.isPremium {
                        
                        dismiss(animated: true)
                    }
                }
            }
            catch {
                await MainActor.run { [weak self] in
                    self?.subscribeButton.isEnabled = true
                    self?.presentAlert(title: "Purchase failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func handleRestore() {
        restoreButton.isEnabled = false
        Task {
            do {
                try await paywallService.restore()
                await MainActor.run {
                    [weak self] in
                    guard let self else { return }
                    restoreButton.isEnabled = true
                    if paywallService.isPremium {
                        dismiss(animated: true)
                    }
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.restoreButton.isEnabled = true
                    self?.presentAlert(title: "Restore failed", message: error.localizedDescription)
                }
            }
        }
    }
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func handleClose() {
        dismiss(animated: true, completion: nil)
        triggerHapticFeedback(type: .selection)
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
