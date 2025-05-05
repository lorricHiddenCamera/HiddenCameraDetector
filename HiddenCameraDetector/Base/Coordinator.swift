import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
    func finish()
    
    func pop()
    func popToRoot()
    func presentViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    
    func presentCoordinator(_ coordinator: Coordinator, with window: UIWindow?)
}

extension Coordinator {
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
    
    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func presentViewController(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func presentCoordinator(_ coordinator: Coordinator, with widnow: UIWindow? = nil) {
        coordinator.start()
        if let userWindow = widnow {
            userWindow.rootViewController = navigationController
            userWindow.makeKeyAndVisible()
        }
    }
    
    
}
