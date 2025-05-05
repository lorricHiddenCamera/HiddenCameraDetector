import UIKit

class DetectedDeviceController: UIViewController {
    
    // MARK: - UI
    
    lazy var navigationBar = DetectNavigationView()
    
    
    var onDeviceStatusChanged: ((DeviceInfo) -> Void)?
    
    private let nameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        label.textColor = .gray
        return label
    }()
    
    private let nameValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        label.textColor = .black
        return label
    }()
    
    private let connectionTypeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Connection Type"
        label.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        label.textColor = .gray
        return label
    }()
    
    private let connectionTypeValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        label.textColor = .lightBlue6180F2
        return label
    }()
    
    private let ipAddressTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        label.textColor = .gray
        return label
    }()
    
    private let ipAddressValueLabel: CopyableLabel = {
        let label = CopyableLabel()
        label.textAlignment = .right
        label.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        label.textColor = .lightBlue6180F2
        return label
    }()
    
    private let statusTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Status"
        label.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        label.textColor = .gray
        return label
    }()
    
    private let statusValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        return label
    }()
    
    private let markButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.plusJakartaSans(.semiBold, size: 18)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: - Properties
    
    private let coordinator: Coordinator
    private var device: DeviceInfo
    
    // MARK: - Initialization
    
    init(coordinator: Coordinator, with device: DeviceInfo) {
        self.coordinator = coordinator
        self.device = device
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch device.connectionType {
        case .bluetooth:
            ipAddressTitleLabel.text = "Bluetooth ID"
        case .wifi:
            ipAddressTitleLabel.text = "IP Address"
        }
        setupViews()
        configureUI()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .lightGrayF2F8FF
        setupNavigationBar()
        setupLayout()
        markButton.addTarget(self, action: #selector(markButtonTapped), for: .touchUpInside)
    }
    
    private func setupNavigationBar() {
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        navigationBar.titleText = "Device"
        navigationBar.historyButton.isHidden = true
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110)
        ])
        
        navigationBar.onBackButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.coordinator.pop()
            triggerHapticFeedback(type: .selection)
        }
    }
    
    private func setupLayout() {
        let row1 = createRowContainer(leftLabel: nameTitleLabel, rightLabel: nameValueLabel)
        let row2 = createRowContainer(leftLabel: connectionTypeTitleLabel, rightLabel: connectionTypeValueLabel)
        let row3 = createRowContainer(leftLabel: ipAddressTitleLabel, rightLabel: ipAddressValueLabel)
        let row4 = createRowContainer(leftLabel: statusTitleLabel, rightLabel: statusValueLabel)
        
        let verticalStack = UIStackView(arrangedSubviews: [row1, row2, row3, row4])
        verticalStack.axis = .vertical
        verticalStack.spacing = 5
        
        view.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(markButton)
        markButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 20),
            verticalStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            markButton.heightAnchor.constraint(equalToConstant: 50),
            markButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            markButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            markButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func createRowContainer(leftLabel: UILabel, rightLabel: UILabel) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        
        let stack = UIStackView(arrangedSubviews: [leftLabel, rightLabel])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18)
        ])
        
        return container
    }
    
    // MARK: - UI Configuration
    
    private func configureUI() {
        nameValueLabel.text = device.name
        
        switch device.connectionType {
        case .wifi:
            connectionTypeValueLabel.text = "Wi-Fi"
            connectionTypeValueLabel.textColor = UIColor.systemBlue
        case .bluetooth:
            connectionTypeValueLabel.text = "Bluetooth"
            connectionTypeValueLabel.textColor = UIColor.systemBlue
        }
        
        ipAddressValueLabel.text = device.address
        ipAddressValueLabel.textColor = UIColor.systemBlue
        
        if device.isTrusted {
            statusValueLabel.text = "Trusted"
            statusValueLabel.textColor = .systemGreen
        } else {
            statusValueLabel.text = "Suspicious"
            statusValueLabel.textColor = .systemRed
        }
        
        updateMarkButtonAppearance()
    }
    
    private func updateMarkButtonAppearance() {
        if device.isTrusted {
            markButton.setTitle("Mark as Suspicious", for: .normal)
            markButton.backgroundColor = .systemRed
            markButton.setTitleColor(.white, for: .normal)
        } else {
            markButton.setTitle("Mark as Trusted", for: .normal)
            markButton.backgroundColor = .systemGreen
            markButton.setTitleColor(.white, for: .normal)
        }
    }
    
    // MARK: - Actions
    
    @objc private func markButtonTapped() {
        triggerHapticFeedback(type: .success)
        device.isTrusted.toggle()
        
        if device.isTrusted {
            statusValueLabel.text = "Trusted"
            statusValueLabel.textColor = .systemGreen
            markButton.setTitle("Mark as Suspicious", for: .normal)
            markButton.backgroundColor = .systemRed
        } else {
            statusValueLabel.text = "Suspicious"
            statusValueLabel.textColor = .systemRed
            markButton.setTitle("Mark as Trusted", for: .normal)
            markButton.backgroundColor = .systemGreen
        }
        onDeviceStatusChanged?(self.device)
        RealmDatabaseManager.shared.updateDeviceStatus(address: device.address, isTrusted: device.isTrusted)
    }
}
