import UIKit
import Combine

class SpeedTestController: UIViewController {
    private let speedView = SpeedTestView()
    private var viewModel = SpeedTestViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let coordinator: SpeedTestCoordinator
    
    init(coordinator: SpeedTestCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = speedView
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTargets()
        bindViewModel()
    }
    
}

extension SpeedTestController {
    private func setupTargets() {
        speedView.navigationBar.onBackButtonTapped = { [weak self] in
            guard let self else { return }
            triggerHapticFeedback(type: .selection)
            coordinator.finish()
        }
        speedView.startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.$downloadSpeed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] speed in
                self?.speedView.downloadView.configure(
                    icon: UIImage.downloadIcon,
                    title: "Download",
                    speedValue: String(format: "%.0f", speed),
                    unit: "(Mb)"
                )
            }
            .store(in: &cancellables)
        
        viewModel.$uploadSpeed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] speed in
                self?.speedView.uploadView.configure(
                    icon: UIImage.uploadIcon,
                    title: "Upload",
                    speedValue: String(format: "%.0f", speed),
                    unit: "(Mb)"
                )
            }
            .store(in: &cancellables)
        viewModel.onSSIDFetched = { [weak self] ssid in
            self?.speedView.wifiNameLabel.text = ssid
        }
        
    }
    
    private func showError(_ message: String) {
        triggerHapticFeedback(type: .error)
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
    @objc
    private func startButtonTapped() {
        if !SubscriptionManager.shared.isPremiumUser() {
            coordinator.presentPaywall()
        }
        else {
            triggerHapticFeedback(type: .selection)
            speedView.startButton.isEnabled = false
            speedView.startButton.backgroundColor = .lightBlue6180F2.withAlphaComponent(0.8)
            speedView.progressView.setProgress(0, animated: false)
            viewModel.startTest()
            speedView.progressView.setProgress(1, animated: true, duration: 15) { [weak self] in
                guard let self else { return }
                viewModel.stopTest()
                speedView.startButton.isEnabled = true
                speedView.startButton.setTitle("Restart", for: .normal)
                speedView.startButton.backgroundColor = .lightBlue6180F2
                triggerHapticFeedback(type: .success)
            }
            speedView.startButton.setTitle("Checking...", for: .normal)
        }
    }
}
