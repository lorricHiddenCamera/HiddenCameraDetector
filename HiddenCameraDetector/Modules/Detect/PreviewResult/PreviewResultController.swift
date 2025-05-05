import UIKit

class PreviewResultController: UIViewController {
    
    
    private lazy var navigationBar: DetectNavigationView = {
        let navView = DetectNavigationView()
        navView.historyButton.isHidden = true
        navView.titleText = "Result"
        return navView
    }()
    
    private lazy var totalDevicesView = BlueGradientView()
    
    private lazy var totalDevicesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .plusJakartaSans(.semiBold, size: 18)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var trustedDevicesView: CountDevicesView = {
        let view = CountDevicesView(deviceType: .trusted)
        return view
    }()
    
    private lazy var suspiciosDevicesView: CountDevicesView = {
        let view = CountDevicesView(deviceType: .suspicious)
        return view
    }()
    
    private lazy var seeResultsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See results", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.plusJakartaSans(.bold, size: 18)
        button.backgroundColor = .lightBlue6180F2
        button.layer.cornerRadius = 24
        return button
    }()
    
    private let blurredBackground: UIImage?
    
    private let coordinator: DetectCoordinator
    private let viewModel: PreviewResultViewModel
    
    init(coordinator: DetectCoordinator, viewModel: PreviewResultViewModel, blurredBackground: UIImage?) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        self.blurredBackground = blurredBackground
        super.init(nibName: nil, bundle: nil)
        self.navigationBar.historyButton.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        setupUI()
    }
    
    private func setupUI() {
        let bgImageView = UIImageView(image: blurredBackground)
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.frame = view.bounds
        bgImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(bgImageView)
        
        
        
        totalDevicesView.layer.cornerRadius = 24
        totalDevicesView.layer.masksToBounds = true
        
        setupNavigationBar()
        setupTotalDevicesView()
        setupNumberOfDevicesViews()
        setupResultButton()
        setupTargets()
    }
    
    private func setupNavigationBar() {
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110)
        ])
        
        navigationBar.onBackButtonTapped = { [weak self] in
            guard let self = self else { return }
            coordinator.popToRoot()
            dismiss(animated: true)
            triggerHapticFeedback(type: .selection)
        }
    }
    
    private func setupTotalDevicesView() {
        view.addSubview(totalDevicesView)
        totalDevicesView.addSubview(totalDevicesLabel)
        
        totalDevicesView.translatesAutoresizingMaskIntoConstraints = false
        totalDevicesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        totalDevicesLabel.text = "\(viewModel.getNumberOfAllDevices()) Total Devices Detected"
        
        NSLayoutConstraint.activate([
            totalDevicesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            totalDevicesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            totalDevicesView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -15),
            totalDevicesView.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        NSLayoutConstraint.activate([
            totalDevicesLabel.centerXAnchor.constraint(equalTo: totalDevicesView.centerXAnchor),
            totalDevicesLabel.centerYAnchor.constraint(equalTo: totalDevicesView.centerYAnchor)
        ])
    }
    
    private func setupNumberOfDevicesViews() {
        view.addSubview(trustedDevicesView)
        trustedDevicesView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(suspiciosDevicesView)
        suspiciosDevicesView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trustedDevicesView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 15),
            trustedDevicesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trustedDevicesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trustedDevicesView.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        NSLayoutConstraint.activate([
            suspiciosDevicesView.topAnchor.constraint(equalTo: trustedDevicesView.bottomAnchor, constant: 5),
            suspiciosDevicesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            suspiciosDevicesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            suspiciosDevicesView.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        trustedDevicesView.setNumberOfDevices(viewModel.getNumberOfTrustedDevices())
        suspiciosDevicesView.setNumberOfDevices(viewModel.getNumberOfUntrustedDevices())
    }
    
    private func setupResultButton() {
        view.addSubview(seeResultsButton)
        seeResultsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            seeResultsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            seeResultsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            seeResultsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            seeResultsButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupTargets() {
        seeResultsButton.addTarget(self, action: #selector(seeResultsTapped), for: .touchUpInside)
    }
    
    @objc
    private func seeResultsTapped() {
        if !SubscriptionManager.shared.isPremiumUser() {
            coordinator.presentPaywall(with: self)
        }
        else {
            dismiss(animated: true)
        }
    }

}
