import UIKit

enum DeviceType {
    case trusted, suspicious
}

class CountDevicesView: UIView {
    
//    MARK: - Properties
    
    private let deviceType: DeviceType
    
    private lazy var connectionIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var deviceTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.plusJakartaSans(.semiBold, size: 16)
        label.textColor = .black
        return label
    }()
    
    private lazy var deviceCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.plusJakartaSans(.semiBold, size: 24)
        label.textColor = .black
        return label
    }()
    
//    MARK: - Init
    
    init(deviceType: DeviceType) {
        self.deviceType = deviceType
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    MARK: - Setup UI
    
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 25
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        layer.borderWidth = 1
        
        [connectionIconImageView,deviceTypeLabel,deviceCountLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        switch deviceType {
        case .trusted:
            connectionIconImageView.image = .trustedIcon
            deviceTypeLabel.text = "Trusted devices"
        case .suspicious:
            connectionIconImageView.image = .suspiciosIcon
            deviceTypeLabel.text = "Suspicious devices"
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            connectionIconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            connectionIconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            connectionIconImageView.widthAnchor.constraint(equalToConstant: 55),
            connectionIconImageView.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        NSLayoutConstraint.activate([
            deviceTypeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            deviceTypeLabel.leadingAnchor.constraint(equalTo: connectionIconImageView.trailingAnchor, constant: 12)
        ])
        
        NSLayoutConstraint.activate([
            deviceCountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            deviceCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
//    MARK: - Public
    
    func setNumberOfDevices(_ numberOfDevices: Int) {
        deviceCountLabel.text = "\(numberOfDevices)"
    }
}
