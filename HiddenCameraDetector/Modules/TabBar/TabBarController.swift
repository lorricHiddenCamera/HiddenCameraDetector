import UIKit

class TabBarController: UITabBarController {
    
    // MARK: - UI Elements
    
    private let customTabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var toolsButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    // MARK: - Properties
    
    private let coordinator: TabBarCoordinator
    
    // MARK: - Initialization
    
    init(coordinator: TabBarCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        
        setupCustomTabBar()
        selectedIndex = 0
        updateTabButtonSelection()
    }
    
    func setupViewControllers(_ viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
        self.selectedIndex = 0
        updateTabButtonSelection()
    }
    
    // MARK: - Setup Methods
    
    private func setupCustomTabBar() {
        view.addSubview(customTabBarView)
        
        customTabBarView.layer.cornerRadius = 25
        customTabBarView.layer.masksToBounds = false
        customTabBarView.layer.shadowColor = UIColor(red: 0.071, green: 0.077, blue: 0.102, alpha: 0.1).cgColor
        customTabBarView.layer.shadowOffset = CGSize(width: 0, height: -4)
        customTabBarView.layer.shadowRadius = 24
        customTabBarView.layer.shadowOpacity = 1
        customTabBarView.layer.shadowPath = UIBezierPath(roundedRect: customTabBarView.bounds, cornerRadius: 0).cgPath
        
        
        NSLayoutConstraint.activate([
            customTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customTabBarView.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 80 : 100)
        ])
        
        setupTabButtons()
    }
    
    private func setupTabButtons() {
        configureTabButton(
            button: toolsButton,
            tag: 0,
            normalImageName: "toolsIcon",
            selectedImageName: "toolsIconSelected"
        )
        configureTabButton(
            button: infoButton,
            tag: 1,
            normalImageName: "infoIcon",
            selectedImageName: "infoIconSelected"
        )
        configureTabButton(
            button: settingsButton,
            tag: 2,
            normalImageName: "settingsIcon",
            selectedImageName: "settingsIconSelected"
        )
        
        [toolsButton, infoButton, settingsButton].forEach {
            customTabBarView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
       
        NSLayoutConstraint.activate([
            toolsButton.leadingAnchor.constraint(equalTo: customTabBarView.leadingAnchor, constant: 40),
            toolsButton.centerYAnchor.constraint(equalTo: customTabBarView.centerYAnchor),
            toolsButton.widthAnchor.constraint(equalToConstant: 55),
            toolsButton.heightAnchor.constraint(equalToConstant: 55),
            
            infoButton.centerXAnchor.constraint(equalTo: customTabBarView.centerXAnchor),
            infoButton.centerYAnchor.constraint(equalTo: customTabBarView.centerYAnchor),
            infoButton.widthAnchor.constraint(equalToConstant: 55),
            infoButton.heightAnchor.constraint(equalToConstant: 55),
            
            settingsButton.trailingAnchor.constraint(equalTo: customTabBarView.trailingAnchor, constant: -40),
            settingsButton.centerYAnchor.constraint(equalTo: customTabBarView.centerYAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 55),
            settingsButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func configureTabButton(button: UIButton, tag: Int, normalImageName: String, selectedImageName: String) {
        button.tag = tag
        button.setImage(UIImage(named: normalImageName), for: .normal)
        button.setImage(UIImage(named: selectedImageName), for: .selected)
        button.backgroundColor = .clear
        button.tintColor = .clear
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func tabButtonTapped(_ sender: UIButton) {
        triggerHapticFeedback(type: .selection)
        selectedIndex = sender.tag
        updateTabButtonSelection()
    }
    
    // MARK: - Helper Methods
   
    private func updateTabButtonSelection() {
        toolsButton.isSelected = (selectedIndex == 0)
        infoButton.isSelected = (selectedIndex == 1)
        settingsButton.isSelected = (selectedIndex == 2)
    }
}
