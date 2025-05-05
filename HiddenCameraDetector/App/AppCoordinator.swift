import UIKit
import RevenueCat
import SwiftUI
import AppTrackingTransparency
import AdSupport
import RevenueCatUI
import AppsFlyerLib

class AppCoordinator: Coordinator {
    var window: UIWindow
    
    var navigationController = UINavigationController()
    private var onboardingCoordinator: OnboardingFlowCoordinator?
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let spashVC = SplashScreenViewController()
        window.rootViewController = spashVC
        window.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            self?.startFlow()
        })
    }
    
    func startFlow() {
        requestATTAuthorizationIfNeeded()
        if isFirstLaunch {
            showOnboarding()
        }
        else {
            showTabBar()
            showPaywall()
        }
    }
    
    func finish() {}
    
}

extension AppCoordinator {
    
    private func showTabBar() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        presentCoordinator(tabBarCoordinator, with: window)
    }
    
    private func showOnboarding() {
        let onboardingCoordinator = OnboardingFlowCoordinator(navigationController: navigationController)
        self.onboardingCoordinator = onboardingCoordinator
        onboardingCoordinator.start()
        navigationController = onboardingCoordinator.navigationController
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        onboardingCoordinator.completionHandler = { [weak self] in
            self?.showTabBar()
            self?.isFirstLaunch = false
            self?.onboardingCoordinator = nil
        }
    }
    
     func showPaywall() {
         if !isFirstLaunch && !SubscriptionManager.shared.isPremiumUser() {
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
                         paywallVC.modalPresentationStyle = .fullScreen
                         self.navigationController.present(paywallVC, animated: true)
                     }
                 }
             }
         }
        
    }
    
    func requestATTAuthorizationIfNeeded() {
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    ATTrackingManager.requestTrackingAuthorization { status in
                        switch status {
                        case .authorized:
                            AppsFlyerLib.shared().start()
                        case .denied:
                            print("🚫 Tracking denied")
                        case .restricted:
                            print("⛔️ Tracking restricted")
                        case .notDetermined:
                            print("❓ Tracking not determined")
                        @unknown default:
                            break
                        }
                    }
                }
            }
        else if ATTrackingManager.trackingAuthorizationStatus == .authorized {
            AppsFlyerLib.shared().start()
        }
    }
}
