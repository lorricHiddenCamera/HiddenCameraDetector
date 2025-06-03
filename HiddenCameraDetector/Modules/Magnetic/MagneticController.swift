import UIKit

class MagneticController: UIViewController {
    private let magneticView = MagneticView()
    
    private let coordinator: MagneticCoordinator
    private let viewModel = MagneticViewModel()
    
    private var isDetecting = false
    
    init(coordinator: MagneticCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        view = magneticView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let ssid = viewModel.currentSSID else { return }
        magneticView.wifiNameLabel.text = ssid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTargets()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.onMagneticFieldValue = { [weak self] value in
            guard let self = self else { return }
            let roundedValue = Int(value)
            DispatchQueue.main.async {
                self.magneticView.magneticNumberLabel.text = "\(roundedValue)"
            }
        }
        
        
        viewModel.onSSIDFetched = { [weak self] ssid in
            guard let self = self else { return }
            magneticView.wifiNameLabel.text = ssid
        }
        
        viewModel.onRotationAngle = { [weak self] angle in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1) {
                    self.magneticView.magneticArrowImageView.transform = CGAffineTransform(rotationAngle: angle)
                }
            }
        }
    }
}


extension MagneticController {
    private func setupTargets() {
        magneticView.navigationBar.onBackButtonTapped = { [weak self] in
            guard let self else { return }
            triggerHapticFeedback(type: .selection)
            self.coordinator.finish()
        }
        
        magneticView.startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    @objc private func startButtonTapped() {
        if !SubscriptionManager.shared.isPremiumUser() {
            coordinator.presentPaywall()
        }
        else {
            triggerHapticFeedback(type: .selection)
            if isDetecting {
                viewModel.stop()
                isDetecting = false
                
                magneticView.startButton.setTitle("Start", for: .normal)
                magneticView.magneticNumberLabel.text = "0"
                magneticView.magneticArrowImageView.transform = CGAffineTransform(rotationAngle: 0)
                
                UIView.animate(withDuration: 0.2) {
                    self.magneticView.magneticArrowImageView.transform = .identity
                }
            } else {
                viewModel.start()
                isDetecting = true
                
                magneticView.startButton.setTitle("Stop", for: .normal)
            }
        }
    }

}

