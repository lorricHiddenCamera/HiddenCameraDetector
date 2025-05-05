import UIKit

class MainNavigationView: BaseMainNavigationView {
    
    private lazy var proButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.proButton.resizeImage(to: CGSize(width: 90, height: 50)), for: .normal)
        return button
    }()
    
    var onProButtonTapped: (() -> Void)?
    
    override func setupView() {
        super.setupView()
        setupProButton()
        setupMainTitleLabel(text: "Tools and Features")
    }
    
    private func setupProButton() {
        addSubview(proButton)
        
        NSLayoutConstraint.activate([
            proButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            proButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            proButton.widthAnchor.constraint(equalToConstant: 85),
            proButton.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        proButton.addTarget(self, action: #selector(proButtonTapped), for: .touchUpInside)
    }
    
    @objc
    private func proButtonTapped() {
        onProButtonTapped?()
    }
    
}
