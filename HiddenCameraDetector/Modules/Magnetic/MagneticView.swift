import UIKit

class MagneticView: BaseView {
    lazy var navigationBar = MagneticNavigationView()
    
    private let wifiConnectContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        return view
    }()
    
    private let wifiConnectLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.plusJakartaSans(.semiBold, size: 16)
        label.textAlignment = .center
        return label
    }()
    
    let wifiNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.plusJakartaSans(.medium, size: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Identify magnetic field variations from nearby\ndevices."
        label.textColor = .lightGray
        label.font = UIFont.plusJakartaSans(.regular, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let magneticCircleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.magneticCircle)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let magneticArrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.magneticArrow)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    private let magneticNumberView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        return view
    }()
    
    let magneticNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.plusJakartaSans(.semiBold, size: 36)
        label.textColor = .lightBlue6180F2.withAlphaComponent(0.8)
        label.text = "0"
        return label
    }()
    
    private let magneticTeslaLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.plusJakartaSans(.regular, size: 15)
        label.textColor = .lightGray
        label.text = "μT"
        return label
    }()
    
    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Detect", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.plusJakartaSans(.bold, size: 18)
        button.backgroundColor = .lightBlue6180F2
        button.layer.cornerRadius = 24
        return button
    }()
    
    override func setupView() {
        backgroundColor = .lightGrayF2F8FF
        setupNavigationBar()
        setupWifiConnectView()
        setupInfoLabel()
        setupCircleImageView()
        setupMagneticNumberView()
        setupStartButton()
    }
    
    
    
    private func setupNavigationBar() {
        addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110)
        ])
        navigationBar.titleText = "Magnetic"
    }
    
    private func setupWifiConnectView() {
        addSubview(wifiConnectContainerView)
        wifiConnectContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        wifiConnectContainerView.addSubview(wifiConnectLabel)
        wifiConnectContainerView.addSubview(wifiNameLabel)
        wifiConnectLabel.translatesAutoresizingMaskIntoConstraints = false
        wifiNameLabel.translatesAutoresizingMaskIntoConstraints = false
        wifiConnectLabel.text = "Wi-Fi Connect:"
        
        NSLayoutConstraint.activate([
            wifiConnectContainerView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 12),
            wifiConnectContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            wifiConnectContainerView.widthAnchor.constraint(equalToConstant: 155),
            wifiConnectContainerView.heightAnchor.constraint(equalToConstant: 75),
            
            wifiConnectLabel.topAnchor.constraint(equalTo: wifiConnectContainerView.topAnchor, constant: 10),
            wifiConnectLabel.centerXAnchor.constraint(equalTo: wifiConnectContainerView.centerXAnchor),
            wifiNameLabel.topAnchor.constraint(equalTo: wifiConnectLabel.bottomAnchor, constant: 10),
            wifiNameLabel.centerXAnchor.constraint(equalTo: wifiConnectContainerView.centerXAnchor)
        ])
    }
    
    private func setupInfoLabel() {
        addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: wifiConnectContainerView.bottomAnchor, constant: 12),
            infoLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func setupStartButton() {
        addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            startButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            startButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCircleImageView() {
        addSubview(magneticCircleImageView)
        magneticCircleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            magneticCircleImageView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20),
            magneticCircleImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            magneticCircleImageView.widthAnchor.constraint(equalToConstant: 280),
            magneticCircleImageView.heightAnchor.constraint(equalToConstant: 280)
        ])
        
        magneticCircleImageView.addSubview(magneticArrowImageView)
        magneticArrowImageView.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            magneticArrowImageView.leadingAnchor.constraint(equalTo: magneticCircleImageView.leadingAnchor),
            magneticArrowImageView.trailingAnchor.constraint(equalTo: magneticCircleImageView.trailingAnchor),
            magneticArrowImageView.topAnchor.constraint(equalTo: magneticCircleImageView.topAnchor),
            magneticArrowImageView.bottomAnchor.constraint(equalTo: magneticCircleImageView.bottomAnchor),
        ])


    }
    
    private func setupMagneticNumberView() {
        addSubview(magneticNumberView)
        magneticNumberView.addSubview(magneticNumberLabel)
        magneticNumberView.addSubview(magneticTeslaLabel)
        [magneticNumberView, magneticNumberLabel, magneticTeslaLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            magneticNumberView.topAnchor.constraint(equalTo: magneticCircleImageView.bottomAnchor, constant: 20),
            magneticNumberView.centerXAnchor.constraint(equalTo: centerXAnchor),
            magneticNumberView.widthAnchor.constraint(equalToConstant: 175),
            magneticNumberView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        
        
        NSLayoutConstraint.activate([
            magneticNumberLabel.trailingAnchor.constraint(equalTo: magneticNumberView.centerXAnchor, constant: 10),
            magneticNumberLabel.centerYAnchor.constraint(equalTo: magneticNumberView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            magneticTeslaLabel.leadingAnchor.constraint(equalTo: magneticNumberLabel.trailingAnchor, constant: 5),
            magneticTeslaLabel.centerYAnchor.constraint(equalTo: magneticNumberView.centerYAnchor)
        ])
    }
}
