import UIKit
import CoreBluetooth

class DetectController: UIViewController {
    
    private var detectView: DetectView
    private let coordinator: DetectCoordinator
    private let viewModel: DetectViewModel
    
    init(coordinator: DetectCoordinator) {
        self.coordinator = coordinator
        let viewModel = DetectViewModel()
        self.viewModel = viewModel
        let view = DetectView(viewModel: viewModel)
        self.detectView = view
        detectView.viewModel = viewModel
       
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = detectView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTargets()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.viewModel.requestAllPermissions()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detectView.progressView.setProgress(0, animated: false)
        detectView.progressView.setLabelText("Start")
        detectView.progressView.isUserInteractionEnabled = true
        detectView.reloadTableView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.stopScanning()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func appWillEnterForeground() {
        detectView.progressView.setProgress(0, animated: false)
        detectView.progressView.setLabelText("Start")
        detectView.progressView.isUserInteractionEnabled = true
    }
    
    // MARK: - Alert for going to Settings
    
    private func showAlertForSettings(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        alert.addAction(settingsAction)
        
        let backAction = UIAlertAction(title: "Back", style: .cancel) { _ in
            self.coordinator.finish()
        }
        alert.addAction(backAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Setup Targets
    
    private func setupTargets() {
        viewModel.onSSIDFetched = { [weak self] ssid in
            guard let self = self else { return }
            self.detectView.seeAllButton.isEnabled = true
            if let ssid = ssid {
                self.detectView.wifiNameLabel.text = ssid
            } else {
                self.detectView.wifiNameLabel.text = "Unknown"
            }
        }
        
        
        self.viewModel.onLocalNetworkDenied = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showAlertForSettings(
                    title: "Local Network Permission Required",
                    message: "Please grant local network access in Settings."
                )
            }
        }
        
        self.viewModel.onBluetoothNotAvailable = { [weak self] in
            self?.showAlertForSettings(
                title: "Bluetooth is not available",
                message: "Please grant bluetooth access in Settings."
            )
        }
        
        viewModel.onDevicesChanged = { [weak self] device in
            guard let self = self else { return }
            self.detectView.updateDataSource(with: device)
        }
        
        detectView.onShowDeviceDetails = { [weak self] deviceInfo in
            guard let self = self else { return }
            self.coordinator.presentDevice(with: deviceInfo)
            triggerHapticFeedback(type: .selection)
        }
        
        detectView.navigationBar.onBackButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.coordinator.finish()
            triggerHapticFeedback(type: .selection)
        }
        
        detectView.navigationBar.historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        
        coordinator.onDeviceStatusChanged = { [weak self] deviceInfo in
            guard let self else { return }
            viewModel.updateDevice(with: deviceInfo)
        }
        
        detectView.onShowResultPreview = { [weak self] in
            guard let self else { return }
            coordinator.presentPreviewResult(with: viewModel.devices)
        }
        
        detectView.seeAllButton.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
    }
    
    @objc
    private func historyButtonTapped() {
        if !SubscriptionManager.shared.isPremiumUser() {
            coordinator.presentPaywall(with: self)
        }
        else {
            triggerHapticFeedback(type: .selection)
            coordinator.presentHistory()
        }
    }
    
    @objc
    private func seeAllButtonTapped() {
        if viewModel.isDevicesEmpty() { return }
        if detectView.devicesTableView.isHidden { return }
        triggerHapticFeedback(type: .selection)
        coordinator.presentResult(with: viewModel.devices)
    }
}
