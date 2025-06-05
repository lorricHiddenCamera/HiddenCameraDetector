import UIKit
import RevenueCatUI
import RevenueCat

class MainController: UIViewController {
    
    let subManager = SubscriptionManager.shared

    private let coordinator: MainCoordinator
    
    private let mainView = MainView()
    
    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        
        mainView.navigationBar.proButton.isHidden = subManager.isPremiumUser()
        
        subManager.observeCustomerInfoChanges { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.mainView.navigationBar.proButton.isHidden = self.subManager.isPremiumUser()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainView.navigationBar.proButton.isHidden = SubscriptionManager.shared.isPremiumUser()
    }
}


extension MainController {
    private func setupTargets() {
        mainView.speedTesterButton.addTarget(self, action: #selector(speedTesterButtonTapped), for: .touchUpInside)
        mainView.detectButton.addTarget(self, action: #selector(detectButtonTapped), for: .touchUpInside)
        mainView.magneticButton.addTarget(self, action: #selector(magneticButtonTapped), for: .touchUpInside)
        mainView.scannerButton.addTarget(self, action: #selector(scannerButtonTapped), for: .touchUpInside)
        mainView.navigationBar.onProButtonTapped = { [weak self] in
            self?.coordinator.presentPlansPaywall()
        }
    }
    
    @objc
    private func speedTesterButtonTapped() {
        triggerHapticFeedback(type: .selection)
        coordinator.presentSpeedTest()
    }
    
    @objc
    private func scannerButtonTapped() {
        if !SubscriptionManager.shared.isPremiumUser() {
            presentPaywall()
        }
        else {
            triggerHapticFeedback(type: .selection)
            coordinator.presentScanner()
        }
    }
    
    @objc
    private func detectButtonTapped() {
        triggerHapticFeedback(type: .selection)
        coordinator.presentDetect()
    }
    
    @objc
    private func magneticButtonTapped() {
        triggerHapticFeedback(type: .selection)
        coordinator.presentMagnetic()
    }
    
    private func presentPaywall() {
        coordinator.presentPaywall()
    }
}
