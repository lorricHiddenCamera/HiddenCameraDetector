import UIKit

final class InternetAlertService {

    static let shared = InternetAlertService()
    
    private var isAlertShown = false

    func startMonitoring() {
        NetworkMonitorService.shared.setUpdateHandler { [weak self] isConnected in
            DispatchQueue.main.async {
                if isConnected {
                    self?.dismissAlertIfNeeded()
                } else {
                    self?.presentBlockingAlert()
                }
            }
        }
        NetworkMonitorService.shared.startMonitoring()
    }

    private func presentBlockingAlert() {
        guard !isAlertShown, let topVC = topViewController() else { return }

        isAlertShown = true
        
        let alert = UIAlertController(
            title: "No Internet Connection",
            message: "Please check your internet connection and try again.",
            preferredStyle: .alert
        )

        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            guard let self = self else { return }

            if NetworkMonitorService.shared.isConnected {
                self.isAlertShown = false
                alert.dismiss(animated: true)
            } else {
                self.isAlertShown = false
                self.presentBlockingAlert()
            }
        }

        alert.addAction(tryAgainAction)
        topVC.present(alert, animated: true)
    }

    private func dismissAlertIfNeeded() {
        guard isAlertShown,
              let topVC = topViewController(),
              let alert = topVC.presentedViewController as? UIAlertController else { return }

        alert.dismiss(animated: true)
        isAlertShown = false
    }

    private func topViewController(base: UIViewController? = UIApplication.shared
        .connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?
        .rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }

        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }

        return base
    }
}
