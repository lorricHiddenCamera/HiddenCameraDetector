import UIKit

class DetectResultController: UIViewController {
    lazy var navigationBar = DetectNavigationView()
    
    private let coordinator: DetectCoordinator
     
    private var devices: [DeviceInfo]
    
    private let devicesTableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .clear
        return table
    }()
    
    private var dataSource: UITableViewDiffableDataSource<Int, DeviceInfo>!
    
    init(coordinator: DetectCoordinator, with devices: [DeviceInfo]) {
        self.coordinator = coordinator
        self.devices = devices
        super.init(nibName: nil, bundle: nil)
        self.navigationBar.historyButton.isHidden = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGrayF2F8FF
        setupViews()
    }
    
    private func setupViews() {
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        navigationBar.titleText = "Result"
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110)
        ])
        
        navigationBar.onBackButtonTapped = { [weak self] in
            guard let self = self else { return }
            coordinator.finish()
            triggerHapticFeedback(type: .selection)
        }
        coordinator.onDeviceStatusChanged = { [weak self] device in
            guard let self else { return }
            if let index = devices.firstIndex(where: { $0.address == device.address }) {
                    devices[index] = device
                }
            updateDataSource(with: devices)
        }
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
        updateDataSource(with: devices)
        
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
    private func updateDataSource(with devices: [DeviceInfo]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, DeviceInfo>()
        snapshot.appendSections([0])
        snapshot.appendItems(devices)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension DetectResultController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let deviceInfo = devices[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetectDeviceCell", for: indexPath) as? DetectDeviceCell else {
            return UITableViewCell()
        }
        
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
