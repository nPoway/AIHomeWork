import UIKit
import StoreKit

class OnboardingCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var onFinish: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let step1 = makeStep1()
        navigationController.pushViewController(step1, animated: true)
        navigationController.navigationBar.isHidden = true
    }
    
    func finish() {
        onFinish?()
    }
   
    private func makeStep1() -> OnboardingStepViewController {
        let step = OnboardingStepViewController(
            image: UIImage(named: "onb1"),
            titleText: "AI Homework Helper & Solver",
            subtitleText: "Get instant solutions, detailed explanations, and AI-powered assistance to make studying easier and more effective.",
            buttonTitle: "Continue"
        )
        
        step.onContinue = { [weak self] in
            guard let self = self else { return }
            let step2 = self.makeStep2()
            print("Before push:", self.navigationController.viewControllers)
            self.navigationController.pushViewController(step2, animated: true)
            print("After push:", self.navigationController.viewControllers)

            
        }
        
        return step
    }
    
    private func makeStep2() -> OnboardingStepViewController {
        let step = OnboardingStepViewController(
            image: UIImage(named: "onb2"),
            titleText: "Smart Scanner to Solve Problems",
            subtitleText: "Snap a photo of your homework, and let AI provide accurate solutions with step-by-step explanations in seconds",
            buttonTitle: "Continue"
        )
        
        step.onContinue = { [weak self] in
            guard let self = self else { return }
            let step3 = self.makeStep3()
            self.showRatePopup()
            self.navigationController.pushViewController(step3, animated: true)
        }
        
        return step
    }
    
    private func makeStep3() -> OnboardingStepViewController {
        let step = OnboardingStepViewController(
            image: UIImage(named: "onb3"),
            titleText: "Large Number of Task Categories",
            subtitleText: "Solve problems across math, science, writing, and more with AI-powered tools designed for every subject and task",
            buttonTitle: "Continue"
        )
        
        step.onContinue = { [weak self] in
            guard let self = self else { return }
            let step4 = self.makeStep4()
            self.navigationController.pushViewController(step4, animated: true)
        }
        
        return step
    }
    
    private func makeStep4() -> OnboardingStepViewController {
        let step = OnboardingStepViewController(
            image: UIImage(named: "onb4"),
            titleText: "Get Unique Results with AI Chat",
            subtitleText: "Chat with AI anytime to get personalized answers, detailed explanations, and unique solutions tailored to your homework needs",
            buttonTitle: "Continue"
        )
        
        step.onContinue = { [weak self] in
            self?.showPaywall()
        }
        
        return step
    }
    
    func showPaywall() {
        let pw = PaywallViewController()
        navigationController.pushViewController(pw, animated: true)
        
        pw.onContinue = { [weak self] in
            self?.finish()
        }
    }
    
    private func showRatePopup() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
