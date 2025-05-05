import UIKit
import RevenueCatUI
import RevenueCat

class InfoCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {}
    
    func finish() {}
    
}


extension InfoCoordinator {
    func makeViewController() -> UIViewController {
        let vc = InfoController(coordinator: self)
        return vc
    }
    
    func presentPlansPaywall() {
        let vc = makePaywallController()
        vc.modalPresentationStyle = .overFullScreen
        navigationController.present(vc, animated: true)
    }
    
    func makePaywallController() -> UIViewController {
        let pwl = SubscriptionPlansViewController()
        return pwl
    }
}

extension InfoCoordinator: PaywallViewControllerDelegate {
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
                            self?.navigationController.dismiss(animated: true)
                        }
                    )
                    paywallVC.delegate = self
                    paywallVC.modalPresentationStyle = .fullScreen
                    self.navigationController.present(paywallVC, animated: true)
                }
            } else {
                print("⚠️ Не удалось загрузить offering")
            }
        }
    }

    
    
    func paywallViewController(
        _ controller: PaywallViewController,
        didFinishPurchasingWith customerInfo: CustomerInfo
    ) {
        if customerInfo.entitlements.active.keys.contains("premium") {
            
        }
    }
    
    func paywallViewControllerWasDismissed(_ controller: PaywallViewController) {
        
    }
    
    func paywallViewController(_ controller: PaywallViewController, didFinishRestoringWith customerInfo: CustomerInfo) {
        
    }
}


