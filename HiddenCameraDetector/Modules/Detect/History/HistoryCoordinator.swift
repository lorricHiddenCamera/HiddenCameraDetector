import UIKit

class HistoryCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var onDeviceStatusChanged: ((DeviceInfo) -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        presentViewController(makeHistoryController())
    }
    
    func finish() {
        pop()
    }
}

extension HistoryCoordinator {
    private func makeHistoryController() -> UIViewController {
        let vc = HistoryController(coordinator: self)
        return vc
    }
    
    func presentDevice(with device: DeviceInfo) {
        presentViewController(makeDeviceController(with: device))
    }
    
    private func makeDeviceController(with device: DeviceInfo) -> UIViewController {
        let deviceController = DetectedDeviceController(coordinator: self, with: device)
        deviceController.onDeviceStatusChanged = { [weak self] device in
            self?.onDeviceStatusChanged?(device)
        }
        return deviceController
    }
}
