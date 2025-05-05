import UIKit

class OnboardingStepController: UIViewController {
    
    private let backgroundImg: UIImage?
    private var headerText: String?
    private var headerAtr: NSAttributedString?
    private let detailText: String
    private let actionTitle: String
    
    var onAction: (() -> Void)?
    
    // MARK: - UI Components
    
    private let backgroundImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleToFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    private let headerLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let detailLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 19, weight: .regular)
        lbl.textColor = UIColor(red: 0, green: 0.048, blue: 0.223, alpha: 0.6)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let actionButton: OnboardingButton = {
        let btn = OnboardingButton()
        btn.clipsToBounds = true
        return btn
    }()
    
    // MARK: - Initializers
    
    init(image: UIImage?, header: String? = nil, detail: String, buttonTitle: String, headerAtributtedText: NSAttributedString? = nil) {
        self.headerText = ""
        self.headerAtr = NSAttributedString()
        if let headerAtributtedText {
            headerAtr = headerAtributtedText
        }
        else if let header {
            self.headerText = header
        }
        
        self.backgroundImg = image
        
        self.detailText = detail
        self.actionTitle = buttonTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGrayF2F8FF
        
        configureUI()
        configureConstraints()
    }
    
    // MARK: - Setup Methods
    
    private func configureUI() {
        backgroundImageView.image = backgroundImg
        
        if let headerAtr {
            headerLabel.attributedText = headerAtr
        }
        else {
            headerLabel.text = headerText
        }
        
        detailLabel.text = detailText
        
        actionButton.setTitle(actionTitle, for: .normal)
        actionButton.titleLabel?.font = UIFont.plusJakartaSans(.medium, size: 17)
        actionButton.titleLabel?.textColor = .white
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        view.addSubview(backgroundImageView)
        view.addSubview(headerLabel)
        view.addSubview(detailLabel)
        view.addSubview(actionButton)
    }
    
    private func configureConstraints() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            actionButton.heightAnchor.constraint(equalToConstant: 60),
            
            detailLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -15),
            detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            headerLabel.bottomAnchor.constraint(equalTo: detailLabel.topAnchor, constant: -8),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func actionButtonTapped() {
        triggerHapticFeedback(type: .light)
        onAction?()
    }
}
