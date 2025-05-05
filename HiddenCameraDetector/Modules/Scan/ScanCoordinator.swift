import UIKit

class ScanCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        presentViewController(makeScanController())
    }
    
    func finish() {
        pop()
    }
}

extension ScanCoordinator {
    private func makeScanController() -> UIViewController {
        let vc = ScanController(coordinator: self)
        return vc
    }
    
}
