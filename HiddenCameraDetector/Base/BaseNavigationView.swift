import UIKit

class BaseNavigationView: BaseView {
    
    // MARK: - Layout Constants
    
    private enum LayoutConstants {
        static let horizontalPadding: CGFloat = 16
        static let bottomPadding: CGFloat = 15
        static let buttonSize: CGFloat = 32
        static let bottomLineHeight: CGFloat = 1
    }
    
    // MARK: - UI Elements
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.arrowLeftIcon.resizeImage(to: CGSize(width: LayoutConstants.buttonSize, height: LayoutConstants.buttonSize)), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.plusJakartaSans(.semiBold, size: 24)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    
    var onBackButtonTapped: (() -> Void)?

    var titleText: String? {
        didSet {
            titleLabel.text = titleText
            titleLabel.isHidden = (titleText == nil)
        }
    }
    
    // MARK: - Initialization
    
    init(isBackButtonHidden: Bool = true, titleText: String? = nil) {
        self.titleText = titleText
        super.init(frame: .zero)
        backButton.isHidden = isBackButtonHidden
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    override func setupView() {
        backgroundColor = .white
        setupTitleLabel()
        setupBackButton()
        setupBottomLine()
    }
   
    private func setupTitleLabel() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -LayoutConstants.bottomPadding)
        ])
        titleLabel.text = titleText
        titleLabel.isHidden = (titleText == nil)
    }
    
    private func setupBackButton() {
        guard !backButton.isHidden else { return }
        addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LayoutConstants.horizontalPadding),
            backButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -LayoutConstants.bottomPadding),
            backButton.widthAnchor.constraint(equalToConstant: LayoutConstants.buttonSize),
            backButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonSize)
        ])
    }
    
    private func setupBottomLine() {
        addSubview(bottomLine)
        NSLayoutConstraint.activate([
            bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: LayoutConstants.bottomLineHeight)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func backButtonAction() {
        onBackButtonTapped?()
    }
}
