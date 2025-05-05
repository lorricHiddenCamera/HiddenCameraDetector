import UIKit

class SpeedTestView: BaseView {
    
    // MARK: - UI Elements
    
    lazy var navigationBar = SpeedTestNavigationView()
   
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
        label.text = "Measure the current network speed and \nidentify potential performance issues"
        label.textColor = .lightGray
        label.font = UIFont.plusJakartaSans(.regular, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    let progressView: CircularProgressView = {
        let view = CircularProgressView()
        return view
    }()
    
    let downloadView: SpeedTestItemView = {
        let view = SpeedTestItemView()
        view.configure(icon: UIImage.downloadIcon,
                       title: "Download",
                       speedValue: "0",
                       unit: "(Mb)")
        return view
    }()
    
    let uploadView: SpeedTestItemView = {
        let view = SpeedTestItemView()
        view.configure(icon: UIImage.uploadIcon,
                       title: "Upload",
                       speedValue: "0",
                       unit: "(Mb)")
        return view
    }()
    
    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.plusJakartaSans(.bold, size: 18)
        button.backgroundColor = .lightBlue6180F2
        button.layer.cornerRadius = 24
        return button
    }()
    
    // MARK: - Setup
    
    override func setupView() {
        backgroundColor = .lightGrayF2F8FF
        
        setupNavigationBar()
        setupWifiConnectView()
        setupInfoLabel()
        setupProgressView()
        setupDownloadUploadViews()
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
        navigationBar.titleText = "Speed Tester"
    }
    
    // MARK: - Wi-Fi Connect
    
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
    
    // MARK: - Info Label
    
    private func setupInfoLabel() {
        addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: wifiConnectContainerView.bottomAnchor, constant: 12),
            infoLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    // MARK: - Progress View
    
    private func setupProgressView() {
        addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 5),
            progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressView.widthAnchor.constraint(equalToConstant: iphoneWithButton ? 250 : 300),
            progressView.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 250 : 300)
        ])
    }
    
    // MARK: - Download / Upload
    
    private func setupDownloadUploadViews() {
        let stack = UIStackView(arrangedSubviews: [downloadView, uploadView])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            stack.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // MARK: - Start Button
    
    private func setupStartButton() {
        addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: iphoneWithButton ? -5 : 0),
            startButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            startButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
