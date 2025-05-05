import UIKit

class SettingsCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {}
    
    func finish() {}
    
}

extension SettingsCoordinator {
    func makeViewController() -> UIViewController {
        let vc = SettingsController(coordinator: self)
        return vc
    }
    
    func presentTrialPaywall() {
        let vc = makePaywallController()
        vc.modalPresentationStyle = .overFullScreen
        navigationController.present(vc, animated: true)
    }
    
    func makePaywallController() -> UIViewController {
        let pwl = SubscriptionPlansViewController()
        return pwl
    }
}
