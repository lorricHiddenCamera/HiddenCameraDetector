import UIKit

class BaseMainNavigationView: BaseNavigationView {
    private lazy var mainTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.plusJakartaSans(.semiBold, size: 24)
        label.textAlignment = .left
        return label
    }()
    
    override func setupView() {
        super.setupView()
        setupMainTitleLabel()
    }
    
    private func setupMainTitleLabel() {
        addSubview(mainTitleLabel)
        
        NSLayoutConstraint.activate([
            mainTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }
    
    func setupMainTitleLabel(text: String) {
        mainTitleLabel.text = text
    }
}
