import UIKit
import RevenueCat

class SubscriptionPlansViewController: UIViewController {
    
    private let subManager: SubscriptionManaging = SubscriptionManager.shared
    
    // MARK: - UI Components
    
    private let dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        let closeIcon = UIImage(systemName: "xmark")?
            .resizeImage(to: CGSize(width: 20, height: 20))
        btn.setImage(closeIcon, for: .normal)
        btn.tintColor = .black
        return btn
    }()
    
    private let backdropImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "pwl2")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let headerLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Start To Continue\nWith Full Access"
        lbl.font = UIFont.plusJakartaSans(.bold, size: 34)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let weeklyPlan   = PlanView(planTitle: "Week",  costText: "",  trialText: "Get a Plan")
    private let monthlyPlan  = PlanView(planTitle: "Month", costText: "", trialText: "Get a Plan")
    private let yearlyPlan   = PlanView(planTitle: "Year",  costText: "", trialText: "Get a Plan")
    
    private let plansContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.spacing = 5
        return stack
    }()
    
    private let trialOptionsContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60)
        ])
        return view
    }()
    
    private let trialStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Free Trial Disabled"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trialToggle: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = UIColor.systemBlue
        sw.isOn = false
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    private let subscribeActionButton: OnboardingButton = {
        let btn = OnboardingButton()
        btn.setTitle("Subscribe", for: .normal)
        btn.titleLabel?.font = UIFont.plusJakartaSans(.medium, size: 18)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let privacyPolicyButton = PWLBottomButton(title: "Privacy Policy")
    private let restorePurchaseButton = PWLBottomButton(title: "Restore")
    private let termsOfUseButton      = PWLBottomButton(title: "Terms of Use")
    
    private var activePlan: PlanView?
    
    private var availablePackages: [String: Package] = [:]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        
        subManager.loadOfferings { [weak self] result in
            DispatchQueue.main.async {
                
                switch result {
                case .success(let packages):
                    for package in packages {
                        self?.availablePackages[package.identifier] = package

                        let price = package.storeProduct.localizedPriceString

                        switch package.identifier {
                        case "weekly", "weekly_trial":
                            self?.weeklyPlan.updateCostText(price)
                        case "monthly", "monthly_trial":
                            self?.monthlyPlan.updateCostText(price)
                        case "annual", "annual_trial":
                            self?.yearlyPlan.updateCostText(price)
                        default:
                            break
                        }
                    }
                case .failure(let error):
                    print("❌ Failed to load offerings: \(error.localizedDescription)")
                }
            }
        }
        
        setupBackdrop()
        setupDismissButton()
        setupHeaderLabel()
        setupPlanOptions()
        setupTrialOptions()
        setupSubscribeAction()
        setupBottomLinks()
        setupConstraints()
        
        trialToggle.addTarget(self, action: #selector(didToggleTrialOption), for: .valueChanged)
        subscribeActionButton.addTarget(self, action: #selector(didTapSubscribe), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        
        
        privacyPolicyButton.addTarget(self, action: #selector(privacyPolicyTapped), for: .touchUpInside)
        restorePurchaseButton.addTarget(self, action: #selector(restorePurchaseTapped), for: .touchUpInside)
        termsOfUseButton.addTarget(self, action: #selector(termsOfUseTapped), for: .touchUpInside)
        
        weeklyPlan.addTarget(self, action: #selector(didSelectPlan(_:)), for: .touchUpInside)
        monthlyPlan.addTarget(self, action: #selector(didSelectPlan(_:)), for: .touchUpInside)
        yearlyPlan.addTarget(self, action: #selector(didSelectPlan(_:)), for: .touchUpInside)
        
        selectPlan(weeklyPlan)
    }
    
    // MARK: - Setup Methods
    
    private func setupBackdrop() {
        view.addSubview(backdropImageView)
        backdropImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupHeaderLabel() {
        view.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupPlanOptions() {
        plansContainer.addArrangedSubview(weeklyPlan)
        plansContainer.addArrangedSubview(monthlyPlan)
        plansContainer.addArrangedSubview(yearlyPlan)
        view.addSubview(plansContainer)
        plansContainer.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupTrialOptions() {
        trialOptionsContainer.addSubview(trialStatusLabel)
        trialOptionsContainer.addSubview(trialToggle)
        view.addSubview(trialOptionsContainer)
    }
    
    private func setupSubscribeAction() {
        view.addSubview(subscribeActionButton)
    }
    
    private func setupBottomLinks() {
        view.addSubview(privacyPolicyButton)
        view.addSubview(restorePurchaseButton)
        view.addSubview(termsOfUseButton)
        
        privacyPolicyButton.translatesAutoresizingMaskIntoConstraints = false
        restorePurchaseButton.translatesAutoresizingMaskIntoConstraints = false
        termsOfUseButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backdropImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdropImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dismissButton.widthAnchor.constraint(equalToConstant: 20),
            dismissButton.heightAnchor.constraint(equalToConstant: 20),
            
            headerLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: iphoneWithButton ? -150 : -110),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            
            plansContainer.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 30),
            plansContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            plansContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trialOptionsContainer.topAnchor.constraint(equalTo: plansContainer.bottomAnchor, constant: 5),
            trialOptionsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trialOptionsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trialStatusLabel.leadingAnchor.constraint(equalTo: trialOptionsContainer.leadingAnchor, constant: 15),
            trialStatusLabel.centerYAnchor.constraint(equalTo: trialOptionsContainer.centerYAnchor),
            
            trialToggle.trailingAnchor.constraint(equalTo: trialOptionsContainer.trailingAnchor, constant: -12),
            trialToggle.centerYAnchor.constraint(equalTo: trialOptionsContainer.centerYAnchor),
            
            subscribeActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subscribeActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            subscribeActionButton.heightAnchor.constraint(equalToConstant: 60),
            subscribeActionButton.bottomAnchor.constraint(equalTo: restorePurchaseButton.topAnchor, constant: iphoneWithButton ? -5 : -20),
            
            restorePurchaseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restorePurchaseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            privacyPolicyButton.centerYAnchor.constraint(equalTo: restorePurchaseButton.centerYAnchor),
            privacyPolicyButton.trailingAnchor.constraint(equalTo: restorePurchaseButton.leadingAnchor, constant: -50),
            
            termsOfUseButton.centerYAnchor.constraint(equalTo: restorePurchaseButton.centerYAnchor),
            termsOfUseButton.leadingAnchor.constraint(equalTo: restorePurchaseButton.trailingAnchor, constant: 50)
        ])
    }
    
    // MARK: - Action Handlers
    
    @objc private func didToggleTrialOption() {
        if trialToggle.isOn {
            trialStatusLabel.text = "Free Trial Enabled"
            weeklyPlan.updateTrialText("3-days Free Trial")
            monthlyPlan.updateTrialText("3-days Free Trial")
            yearlyPlan.updateTrialText("3-days Free Trial")

            weeklyPlan.updateCostText(availablePackages["weekly_trial"]?.storeProduct.localizedPriceString ?? "")
            monthlyPlan.updateCostText(availablePackages["monthly_trial"]?.storeProduct.localizedPriceString ?? "")
            yearlyPlan.updateCostText(availablePackages["annual_trial"]?.storeProduct.localizedPriceString ?? "")
        } else {
            trialStatusLabel.text = "Free Trial Disabled"
            weeklyPlan.updateTrialText("Get a Plan")
            monthlyPlan.updateTrialText("Get a Plan")
            yearlyPlan.updateTrialText("Get a Plan")

            weeklyPlan.updateCostText(availablePackages["weekly"]?.storeProduct.localizedPriceString ?? "")
            monthlyPlan.updateCostText(availablePackages["monthly"]?.storeProduct.localizedPriceString ?? "")
            yearlyPlan.updateCostText(availablePackages["annual"]?.storeProduct.localizedPriceString ?? "")
        }
    }

    
    
    
    @objc private func didTapDismiss() {
        dismiss(animated: true, completion: nil)
        triggerHapticFeedback(type: .selection)
    }
    
    @objc private func didSelectPlan(_ sender: PlanView) {
        selectPlan(sender)
    }
    
    private func selectPlan(_ plan: PlanView) {
        activePlan?.isSelected = false
        activePlan = plan
        plan.isSelected = true
    }
    
    @objc private func didTapSubscribe() {
        triggerHapticFeedback(type: .selection)
        subscribeActionButton.isEnabled = false
        guard let plan = activePlan else {
            return
        }

        let selectedPackageID: String

        switch plan {
        case weeklyPlan:
            selectedPackageID = trialToggle.isOn ? "weekly_trial" : "weekly"
        case monthlyPlan:
            selectedPackageID = trialToggle.isOn ? "monthly_trial" : "monthly"
        case yearlyPlan:
            selectedPackageID = trialToggle.isOn ? "annual_trial" : "annual"
        default:
            return
        }

        guard let package = availablePackages[selectedPackageID] else { return }
        
        
        subManager.purchase(package: package) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success {
                        self?.subscribeActionButton.isEnabled = true
                        triggerHapticFeedback(type: .success)
                        self?.dismiss(animated: true)
                    }
                case .failure(let error):
                    self?.subscribeActionButton.isEnabled = true
                }
            }
        }
    }

    
    @objc private func restorePurchaseTapped() {
        SubscriptionManager.shared.restorePurchases { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let restored):
                    let alert = UIAlertController(
                        title: restored ? "Success" : "Nothing to Restore",
                        message: restored ? "Purchases restored successfully." : "No active subscriptions were found.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                case .failure(let error):
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to restore purchases: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func privacyPolicyTapped() {
        if let url = URL(string: "https://docs.google.com/document/d/1ckGSlpTpTRicDp3LiS7_ZxrC1uZyuRQu1CKzTqT92sQ") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func termsOfUseTapped() {
        if let url = URL(string: "https://docs.google.com/document/d/17cMDICt0pCpTtXEhZL-QdKP6s_qVGYpubk_SoEGB4ss") {
            UIApplication.shared.open(url)
        }
    }
}
