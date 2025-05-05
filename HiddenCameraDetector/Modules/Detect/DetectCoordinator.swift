import UIKit
import RevenueCat
import RevenueCatUI

class DetectCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var onDeviceStatusChanged: ((DeviceInfo) -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        presentViewController(makeDetectController())
    }
    
    func finish() {
        pop()
    }
}

extension DetectCoordinator {
    private func makeDetectController() -> UIViewController {
        let detectController = DetectController(coordinator: self)
        return detectController
    }
    
    func presentHistory() {
        let coordinator = HistoryCoordinator(navigationController: navigationController)
        coordinator.onDeviceStatusChanged = { [weak self] device in
            guard let self = self else { return }
            onDeviceStatusChanged?(device)
        }
        presentCoordinator(coordinator)
    }
    
    private func makeDetectResultController(with devices: [DeviceInfo]) -> UIViewController {
        let detectResultController = DetectResultController(coordinator: self, with: devices)
        return detectResultController
    }
    
    private func makeDeviceController(with device: DeviceInfo) -> UIViewController {
        let deviceController = DetectedDeviceController(coordinator: self, with: device)
        deviceController.onDeviceStatusChanged = { [weak self] device in
            self?.onDeviceStatusChanged?(device)
        }
        return deviceController
    }
    
    private func makePreviewResultController(with devices: [DeviceInfo]) -> UIViewController {
        let blurredImage = makeBlurredScreenshot(of: self.navigationController.viewControllers.last!.view, blurRadius: 20)
        let viewModel = PreviewResultViewModel(devices: devices)
        let previewResultController = PreviewResultController(coordinator: self, viewModel: viewModel, blurredBackground: blurredImage)
        previewResultController.modalPresentationStyle = .overCurrentContext
        return previewResultController
    }
    
    func presentResult(with devices: [DeviceInfo]) {
        presentViewController(makeDetectResultController(with: devices))
    }
    
    func presentDevice(with device: DeviceInfo) {
        presentViewController(makeDeviceController(with: device))
    }
    
    func presentPreviewResult(with devices: [DeviceInfo]) {
        navigationController.present(makePreviewResultController(with: devices), animated: true)
    }
    
    func makeBlurredScreenshot(of view: UIView, blurRadius: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let inputImage = snapshot?.ciImage ?? CIImage(image: snapshot!) else { return nil }
        
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        let ciContext = CIContext(options: nil)
        guard let outputImage = filter.outputImage else { return nil }
        
        let rect = inputImage.extent
        guard let cgImage = ciContext.createCGImage(outputImage, from: rect) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }

}

extension DetectCoordinator: PaywallViewControllerDelegate {
    func presentPaywall(with viewController: UIViewController) {
        Purchases.shared.getOfferings { [weak self] offerings, error in
            guard let self = self else { return }
            
            if let offering = offerings?.current {
                DispatchQueue.main.async {
                    let paywallVC = PaywallViewController(
                        offering: offering,
                        displayCloseButton: true,
                        shouldBlockTouchEvents: false,
                        dismissRequestedHandler: { controller in
                            controller.dismiss(animated: true)
                        }
                    )
                    paywallVC.delegate = self
                    paywallVC.modalPresentationStyle = .fullScreen
                    viewController.present(paywallVC, animated: true)
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


