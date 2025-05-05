import UIKit

class HistoryController: UIViewController {
    
    // MARK: - UI
    lazy var navigationBar = DetectNavigationView()
    
    private let noDevicesImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.noDevicesHistoryIcon)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let devicesTableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .clear
        return table
    }()
    
    // MARK: - Properties
    private let coordinator: HistoryCoordinator
    private let viewModel: HistoryViewModel
    
    private var devices: [DeviceInfo] = []
    
    private var dataSource: UITableViewDiffableDataSource<Int, DeviceInfo>!
    
    // MARK: - Lifecycle
    
    init(coordinator: HistoryCoordinator,
         viewModel: HistoryViewModel = HistoryViewModel())
    {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGrayF2F8FF
        
        setupViews()
        bindViewModel()
        viewModel.loadDevices()
    }
    
    // MARK: - View Setup
    
    private func setupViews() {
        setupNavigationBar()
        setupNoDevicesImageView()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        navigationBar.titleText = "History"
        navigationBar.historyButton.isHidden = true
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110)
        ])
        
        navigationBar.onBackButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.coordinator.finish()
            triggerHapticFeedback(type: .selection)
        }
        
        coordinator.onDeviceStatusChanged = { [weak self] device in
            guard let self else { return }
            
            RealmDatabaseManager.shared.addOrUpdateDevice(device)
            
            self.viewModel.loadDevices()
        }
    }
    
    private func setupNoDevicesImageView() {
        view.addSubview(noDevicesImageView)
        noDevicesImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noDevicesImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDevicesImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noDevicesImageView.widthAnchor.constraint(equalToConstant: 200),
            noDevicesImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupTableView() {
        devicesTableView.register(DetectDeviceCell.self, forCellReuseIdentifier: "DetectDeviceCell")
        
        dataSource = UITableViewDiffableDataSource<Int, DeviceInfo>(tableView: devicesTableView) {
            tableView, indexPath, deviceInfo in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetectDeviceCell", for: indexPath)
                    as? DetectDeviceCell else {
                return UITableViewCell()
            }
            cell.configure(with: deviceInfo)
            return cell
        }
        updateDataSource(with: [])
        
        devicesTableView.delegate = self
        devicesTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(devicesTableView)
        
        NSLayoutConstraint.activate([
            devicesTableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            devicesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            devicesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            devicesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Update UI
    
    private func updateDataSource(with devices: [DeviceInfo]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, DeviceInfo>()
        snapshot.appendSections([0])
        snapshot.appendItems(devices)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.onDevicesLoaded = { [weak self] devices in
            guard let self else { return }
            self.devices = devices
            
            if devices.isEmpty {
                self.noDevicesImageView.isHidden = false
                self.devicesTableView.isHidden = true
            } else {
                self.noDevicesImageView.isHidden = true
                self.devicesTableView.isHidden = false
            }
            
            self.updateDataSource(with: devices)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension HistoryController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetectDeviceCell", for: indexPath)
                as? DetectDeviceCell else {
            return UITableViewCell()
        }
        
        let deviceInfo = devices[indexPath.row]
        cell.configure(with: deviceInfo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        triggerHapticFeedback(type: .selection)
        coordinator.presentDevice(with: devices[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
