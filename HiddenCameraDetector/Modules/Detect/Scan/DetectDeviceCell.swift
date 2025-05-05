import UIKit

class DetectDeviceCell: UITableViewCell {
    
    // MARK: - Subviews
    
    private let bubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        return view
    }()
    
    private let connectionIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let deviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.plusJakartaSans(.semiBold, size: 16)
        label.textColor = .black
        return label
    }()
    
    private let ipAddressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.plusJakartaSans(.regular, size: 14)
        label.textColor = UIColor.lightBlue6180F2
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "arrowRightIncon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear
        
        bubbleContainer.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        bubbleContainer.layer.borderWidth = 1
        
        contentView.addSubview(bubbleContainer)
        bubbleContainer.addSubview(connectionIconImageView)
        bubbleContainer.addSubview(deviceNameLabel)
        bubbleContainer.addSubview(ipAddressLabel)
        bubbleContainer.addSubview(arrowImageView)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with device: DeviceInfo) {
        switch device.connectionType {
        case .bluetooth:
            ipAddressLabel.text = "ID: \(device.address)"
            if device.isTrusted {
                connectionIconImageView.image = UIImage.bluetoothIcon
            } else {
                connectionIconImageView.image = UIImage.suspiciosIcon
            }
        case .wifi:
            ipAddressLabel.text = "IP: \(device.address)"
            if device.isRouter {
                connectionIconImageView.image = UIImage.routerIcon
            } else if device.isTrusted {
                connectionIconImageView.image = UIImage.trustedIcon
            } else {
                connectionIconImageView.image = UIImage.suspiciosIcon
            }
        }
        deviceNameLabel.text = device.name
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        bubbleContainer.translatesAutoresizingMaskIntoConstraints = false
        connectionIconImageView.translatesAutoresizingMaskIntoConstraints = false
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        ipAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bubbleContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bubbleContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bubbleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            connectionIconImageView.leadingAnchor.constraint(equalTo: bubbleContainer.leadingAnchor, constant: 16),
            connectionIconImageView.centerYAnchor.constraint(equalTo: bubbleContainer.centerYAnchor),
            connectionIconImageView.widthAnchor.constraint(equalToConstant: 45),
            connectionIconImageView.heightAnchor.constraint(equalToConstant: 45),
            
            arrowImageView.centerYAnchor.constraint(equalTo: bubbleContainer.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: bubbleContainer.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalToConstant: 25),
            arrowImageView.heightAnchor.constraint(equalToConstant: 25),
            
            deviceNameLabel.topAnchor.constraint(equalTo: bubbleContainer.topAnchor, constant: 15),
            deviceNameLabel.leadingAnchor.constraint(equalTo: connectionIconImageView.trailingAnchor, constant: 12),
            deviceNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowImageView.leadingAnchor, constant: -12),
            
            ipAddressLabel.bottomAnchor.constraint(equalTo: connectionIconImageView.bottomAnchor),
            ipAddressLabel.leadingAnchor.constraint(equalTo: deviceNameLabel.leadingAnchor),
            ipAddressLabel.trailingAnchor.constraint(equalTo: deviceNameLabel.trailingAnchor),
            ipAddressLabel.bottomAnchor.constraint(lessThanOrEqualTo: bubbleContainer.bottomAnchor, constant: -10)
        ])
    }
}
