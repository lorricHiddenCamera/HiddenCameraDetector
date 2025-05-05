import UIKit

final class InfoController: UIViewController {
    
    private let coordinator: InfoCoordinator
    
    private var items: [InfoItem] = []
    
    init(coordinator: InfoCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var infoView: InfoView {
        return view as! InfoView
    }
    
    override func loadView() {
        view = InfoView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoView.navigationBar.onProButtonTapped = { [weak self] in
            guard let self else { return }
            coordinator.presentPlansPaywall()
        }
        
        setupItems()
        setupTableView()
    }
   
    private func setupItems() {
        items = [
            InfoItem(
                title: "How to use Scanner",
                description: """
        The Scanner feature analyzes environmental signals to help you monitor your surroundings for any anomalies.

        Instructions:
        1. Open the Scanner feature.
        2. Slowly move your device around the space.
        3. Pay attention to areas with signal strength fluctuations.
        4. Use on-screen indicators to review readings.
        5. Investigate areas flagged for potential irregularities.
        """,
                isExpanded: false,
                iconName: "scannerInfoIcon"
            ),

            InfoItem(
                title: "How to use Wi-Fi Scanner",
                description: """
        The Wi-Fi Scanner displays all devices connected to your network for verification and management.

        Instructions:
        1. Open the Wi-Fi Scanner feature.
        2. Start a network scan.
        3. Review the list of connected devices.
        4. Mark known devices to differentiate them.
        5. Check any unrecognized entries.
        """,
                isExpanded: false,
                iconName: "routerInfoIcon"
            ),

            InfoItem(
                title: "How to use Speed Tester",
                description: """
        The Speed Tester measures network performance to identify potential slowdowns.

        Instructions:
        1. Open the Speed Tester feature.
        2. Tap "Start" to begin the test.
        3. Compare results with expected benchmarks.
        4. If speeds are below expectations, rerun the test or review network setup.
        """,
                isExpanded: false,
                iconName: "speedInfoIcon"
            ),

            InfoItem(
                title: "How to use Magnetic Sensor",
                description: """
        The Magnetic Sensor measures magnetic field variations around objects.

        Instructions:
        1. Open the Magnetic Sensor feature.
        2. Move your device slowly near walls, furniture, and electronics.
        3. Observe the magnetic field strength indicator:
           • 🟢 Low – normal background levels
           • 🟡 Medium – moderate variations
           • 🔴 High – significant activity
        4. Follow up on areas with elevated readings for further review.
        """,
                isExpanded: false,
                iconName: "magneticInfoIcon"
            )
        ]

    }

    private func setupTableView() {
        let tableView = infoView.tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(InfoCell.self, forCellReuseIdentifier: InfoCell.identifier)
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension InfoController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.identifier,
                                                       for: indexPath) as? InfoCell
        else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !SubscriptionManager.shared.isPremiumUser() {
            coordinator.presentPaywall()
        }
        else {
            items[indexPath.row].isExpanded.toggle()
            triggerHapticFeedback(type: .selection)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    
}
