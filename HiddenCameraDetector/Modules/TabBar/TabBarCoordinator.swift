import UIKit

class TabBarCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    private let mainCoordinator: MainCoordinator
    private let infoCoordinator: InfoCoordinator
    private let settingsCoordinator: SettingsCoordinator
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.infoCoordinator = InfoCoordinator(navigationController: navigationController)
        self.mainCoordinator = MainCoordinator(navigationController: navigationController)
        self.settingsCoordinator = SettingsCoordinator(navigationController: navigationController)
    }
    
    func start() {
        makeTabBarController()
    }
    
    func finish() {}
    
}

extension TabBarCoordinator {
    
    private func makeTabBarController() {
        let tabBarController = TabBarController(coordinator: self)
        let mainVC = mainCoordinator.makeViewController()
        let infoVC = infoCoordinator.makeViewController()
        let settingsVC = settingsCoordinator.makeViewController()
        
        tabBarController.setupViewControllers([mainVC, infoVC, settingsVC])
        
        navigationController.viewControllers = [tabBarController]
        navigationController.navigationBar.isHidden = true
    }
}
