import UIKit
import StoreKit

final class SettingsController: UIViewController {
    
    private let coordinator: SettingsCoordinator
    private let settingsView = SettingsView()
    private let viewModel = SettingsViewModel()
    let subManager = SubscriptionManager.shared
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    init(coordinator: SettingsCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = settingsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsView.navigationBar.proButton.isHidden = SubscriptionManager.shared.isPremiumUser()
    }
    
    private func setupBindings() {
        
        subManager.observeCustomerInfoChanges { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.settingsView.navigationBar.proButton.isHidden = self.subManager.isPremiumUser()
            }
        }
        
        viewModel.openURL = { url in
            UIApplication.shared.open(url, options: [:])
        }
        
        viewModel.presentActivity = { [weak self] activityVC in
            self?.present(activityVC, animated: true)
        }
        
        viewModel.requestReview = {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
        settingsView.navigationBar.onProButtonTapped = { [weak self] in
            guard let self else { return }
            coordinator.presentTrialPaywall()
            
        }
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseID)
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: settingsView.navigationBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension SettingsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseID, for: indexPath) as? SettingsCell else {
            return UITableViewCell()
        }
        let item = viewModel.settingsOptions[indexPath.row]
        cell.configure(with: item.titleText, icon: item.iconImage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        triggerHapticFeedback(type: .selection)
        viewModel.settingsOptions[indexPath.row].action()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}
