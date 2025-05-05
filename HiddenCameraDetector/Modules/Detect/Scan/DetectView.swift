import UIKit

class DetectView: BaseView {
    
    // MARK: - ViewModel
    
    var viewModel: DetectViewModel
    
    // MARK: - Public Subviews
    
    lazy var navigationBar = DetectNavigationView()
    
    // MARK: - Private UI
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
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
        label.text = "Wi-Fi Connect:"
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
        label.text = "Identify devices on the current network that \nmay be suspicious."
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
    
    private let noDevicesImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.noDevices)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Found Devices UI
    
    private let foundDevicesLabel: UILabel = {
        let label = UILabel()
        label.text = "Found Devices"
        label.textColor = .black
        label.font = UIFont.plusJakartaSans(.semiBold, size: 16)
        return label
    }()
    
    let seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSAttributedString(
            string: "See all",
            attributes: [
                .font: UIFont.plusJakartaSans(.semiBold, size: 14),
                .foregroundColor: UIColor.systemBlue
            ]
        )
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.isEnabled = false
        return button
    }()
    
     let devicesTableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.isScrollEnabled = false
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .clear
        table.alpha = 0
        return table
    }()
    
    private var dataSource: UITableViewDiffableDataSource<Int, DeviceInfo>!
    
    private var tableHeightConstraint: NSLayoutConstraint?
    
    var onShowDeviceDetails: ((DeviceInfo) -> Void)?
    
    var onShowResultPreview: (() -> Void)?
    
    init(viewModel: DetectViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func setupView() {
        backgroundColor = .lightGrayF2F8FF
        
        setupNavigationBar()
        setupScrollView()
        setupContent()
        setupTableView()
        
        progressView.setLabelText("Start")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProgressViewTap))
        progressView.addGestureRecognizer(tapGesture)
        progressView.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        devicesTableView.layoutIfNeeded()
        tableHeightConstraint?.constant = devicesTableView.contentSize.height
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110)
        ])
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupContent() {
        contentView.addSubview(wifiConnectContainerView)
        wifiConnectContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        wifiConnectContainerView.addSubview(wifiConnectLabel)
        wifiConnectContainerView.addSubview(wifiNameLabel)
        wifiConnectLabel.translatesAutoresizingMaskIntoConstraints = false
        wifiNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            wifiConnectContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            wifiConnectContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            wifiConnectContainerView.widthAnchor.constraint(equalToConstant: 155),
            wifiConnectContainerView.heightAnchor.constraint(equalToConstant: 75),
            
            wifiConnectLabel.topAnchor.constraint(equalTo: wifiConnectContainerView.topAnchor, constant: 10),
            wifiConnectLabel.centerXAnchor.constraint(equalTo: wifiConnectContainerView.centerXAnchor),
            
            wifiNameLabel.topAnchor.constraint(equalTo: wifiConnectLabel.bottomAnchor, constant: 10),
            wifiNameLabel.centerXAnchor.constraint(equalTo: wifiConnectContainerView.centerXAnchor)
        ])
        
        contentView.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: wifiConnectContainerView.bottomAnchor, constant: 12),
            infoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        contentView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 5),
            progressView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            progressView.widthAnchor.constraint(equalToConstant: iphoneWithButton ? 250 : 300),
            progressView.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 250 : 300)
        ])
        
        contentView.addSubview(foundDevicesLabel)
        foundDevicesLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            foundDevicesLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: iphoneWithButton ? 5 : 20),
            foundDevicesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
        
        contentView.addSubview(seeAllButton)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            seeAllButton.centerYAnchor.constraint(equalTo: foundDevicesLabel.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        contentView.addSubview(devicesTableView)
        devicesTableView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = devicesTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        bottomConstraint.priority = .defaultHigh
        
        tableHeightConstraint = devicesTableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint?.priority = .required
        
        contentView.addSubview(noDevicesImageView)
        noDevicesImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            devicesTableView.topAnchor.constraint(equalTo: foundDevicesLabel.bottomAnchor, constant: 12),
            devicesTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            devicesTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottomConstraint,
            tableHeightConstraint!
        ])
        
        NSLayoutConstraint.activate([
            noDevicesImageView.topAnchor.constraint(equalTo: foundDevicesLabel.bottomAnchor),
            noDevicesImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            noDevicesImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            noDevicesImageView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupTableView() {
        devicesTableView.register(DetectDeviceCell.self, forCellReuseIdentifier: "DetectDeviceCell")
        
        dataSource = UITableViewDiffableDataSource<Int, DeviceInfo>(tableView: devicesTableView) { tableView, indexPath, deviceInfo in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetectDeviceCell", for: indexPath) as? DetectDeviceCell else {
                return UITableViewCell()
            }
            cell.configure(with: deviceInfo)
            return cell
        }
        
        devicesTableView.delegate = self
    }
    
    func reloadTableView() {
        devicesTableView.reloadData()
    }
    
    func updateDataSource(with devices: [DeviceInfo]) {
        updateTableViewVisibility()
        var snapshot = NSDiffableDataSourceSnapshot<Int, DeviceInfo>()
        snapshot.appendSections([0])
        snapshot.appendItems(devices)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc
    private func handleProgressViewTap() {
        triggerHapticFeedback(type: .selection)
        progressView.isUserInteractionEnabled = false
        progressView.setProgress(0, animated: false)
        devicesTableView.isHidden = true
        noDevicesImageView.isHidden = false
        viewModel.startScanning()
        progressView.setProgress(1, animated: true, duration: 15) { [weak self] in
            guard let self else { return }
            triggerHapticFeedback(type: .success)
            viewModel.stopScanning()
            
            if !viewModel.isDevicesEmpty() {
                noDevicesImageView.isHidden = true
                devicesTableView.isHidden = false
            }
            
            self.onShowResultPreview?()
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.progressView.setLabelText("Start")
                self.progressView.isUserInteractionEnabled = true
            }
           
        }
    }
    
    private func updateTableViewVisibility() {
        if viewModel.isDevicesEmpty() {
            noDevicesImageView.isHidden = false
            devicesTableView.alpha = 0
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                self.noDevicesImageView.isHidden = true
//                self.devicesTableView.isHidden = false
                UIView.animate(withDuration: 0.5) {
                    self.devicesTableView.alpha = 1
                }
               
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension DetectView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfDevices()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetectDeviceCell", for: indexPath) as? DetectDeviceCell, let deviceInfo = viewModel.deviceInfo(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        guard let stored = RealmDatabaseManager.shared.getDevice(by: deviceInfo.address) else { return UITableViewCell() }
        
        let device = DeviceInfo(name: stored.name,
                                connectionType: ConnectionType(rawValue: stored.connectionType) ?? .wifi,
                                address: stored.address,
                                isTrusted: stored.isTrusted,
                                isRouter: stored.isRouter)
        
        cell.configure(with: device)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let stored = RealmDatabaseManager.shared.getDevice(by: viewModel.devices[indexPath.row].address) else { return }
        
        let device = DeviceInfo(name: stored.name,
                                connectionType: ConnectionType(rawValue: stored.connectionType) ?? .wifi,
                                address: stored.address,
                                isTrusted: stored.isTrusted,
                                isRouter: stored.isRouter)
        onShowDeviceDetails?(device)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
