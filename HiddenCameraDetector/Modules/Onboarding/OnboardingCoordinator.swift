import UIKit
import StoreKit
import RevenueCatUI
import RevenueCat

class OnboardingFlowCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var completionHandler: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let firstStep = createStepOne()
        navigationController.pushViewController(firstStep, animated: true)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func finish() {
        completionHandler?()
    }
    
    private func createStepOne() -> OnboardingStepController {
        let fullText = "Protect Yourself\nfrom potential\nprivacy threats"
        let attributedText = NSMutableAttributedString(string: fullText)

        let coloredRange = (fullText as NSString).range(of: "Protect Yourself")
        attributedText.addAttribute(.foregroundColor, value: UIColor.blue384EA1, range: coloredRange)
        
        let stepOne = OnboardingStepController(
            image: iphoneWithButton ? UIImage.onb1WithButton : UIImage.onb1,
            header: nil,
            detail: iphoneWithButton ? "Your personal data matters. Our app helps shield your information and ensures your digital privacy remains protected at all times" : "Your personal data matters. Our app helps shield your information and\nensures your digital privacy remains\nprotected at all times",
            buttonTitle: "Continue",
            headerAtributtedText: attributedText
        )
        
        stepOne.onAction = { [weak self] in
            guard let self = self else { return }
            triggerHapticFeedback(type: .selection)
            let secondStep = self.createStepTwo()
            self.navigationController.pushViewController(secondStep, animated: true)
        }
        
        return stepOne
    }
    
    private func createStepTwo() -> OnboardingStepController {
        let fullText = "Network Analyzer\nMonitor Wi‑Fi & Bluetooth signal levels"
        let attributedText = NSMutableAttributedString(string: fullText)

        let coloredRange = (fullText as NSString).range(of: "Network Analyzer")
        attributedText.addAttribute(.foregroundColor, value: UIColor.blue384EA1, range: coloredRange)
        let stepTwo = OnboardingStepController(
            image: iphoneWithButton ? UIImage.onb2WithButton : UIImage.onb2,
            header: nil,
            detail: iphoneWithButton ? "Analyse real‑time Wi‑Fi and Bluetooth signal strength to assess network performance, coverage and interference." : "Analyse real‑time Wi‑Fi and Bluetooth signal strength to assess network performance, areas and interference.",
            buttonTitle: "Continue",
            headerAtributtedText: attributedText
        )

        
        
        stepTwo.onAction = { [weak self] in
            guard let self = self else { return }
            let thirdStep = self.createStepThree()
            triggerHapticFeedback(type: .selection)
            self.requestAppRating()
            self.navigationController.pushViewController(thirdStep, animated: true)
        }
        
        return stepTwo
    }
    
    private func createStepThree() -> OnboardingStepController {
        let fullText = "Found and Explore\nNearby Unknown\nDevices"
        let attributedText = NSMutableAttributedString(string: fullText)

        let coloredRange = (fullText as NSString).range(of: "Found and Explore")
        attributedText.addAttribute(.foregroundColor, value: UIColor.blue384EA1, range: coloredRange)
        let stepThree = OnboardingStepController(
            image: iphoneWithButton ? UIImage.onb3WithButton : UIImage.onb3,
            header: nil,
            detail: iphoneWithButton ? "Begin scanning now to uncover what's around you. Easily identify nearby devices, understand their presence, and stay informed with confidence and clarity" : "Begin scanning now to uncover what's around you. Easily identify nearby devices, understand their presence, and stay informed with confidence and clarity",
            buttonTitle: "Continue",
            headerAtributtedText: attributedText
        )
        
        stepThree.onAction = { [weak self] in
            triggerHapticFeedback(type: .selection)
            self?.presentPaywall()
        }
        
        return stepThree
    }
    
    func presentPaywall() {
        Purchases.shared.getOfferings { [weak self] offerings, error in
            guard let self = self else { return }
            
            if let offering = offerings?.current {
                DispatchQueue.main.async {
                    let paywallVC = PaywallViewController(
                        offering: offering,
                        displayCloseButton: true,
                        shouldBlockTouchEvents: false,
                        dismissRequestedHandler: { [weak self] controller in
                            self?.finish()
                        }
                    )
                    paywallVC.delegate = self
                    self.navigationController.pushViewController(paywallVC, animated: true)
                }
            } else {
                print("⚠️ Не удалось загрузить offering")
            }
        }
    }

    
    private func requestAppRating() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

extension OnboardingFlowCoordinator: PaywallViewControllerDelegate {
   
    func paywallViewController(
        _ controller: PaywallViewController,
        didFinishPurchasingWith customerInfo: CustomerInfo
    ) {
        if customerInfo.entitlements.active.keys.contains("premium") {
            finish()
        }
    }
    
    func paywallViewControllerWasDismissed(_ controller: PaywallViewController) {
        finish()
    }
    
    func paywallViewController(_ controller: PaywallViewController, didFinishRestoringWith customerInfo: CustomerInfo) {
        finish()
    }
}

