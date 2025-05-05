import UIKit

class DetectNavigationView: BaseNavigationView {
    
    lazy var historyButton: UIButton = {
        let button = UIButton()
        let image = UIImage.historyIcon.resizeImage(to: CGSize(width: 32, height: 32))
        button.setImage(image, for: .normal)
        return button
    }()
    
    init() {
        super.init(isBackButtonHidden: false, titleText: "Scanner")
        setupHistoryButton()
    }
    
    private func setupHistoryButton() {
        addSubview(historyButton)
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            historyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            historyButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            historyButton.widthAnchor.constraint(equalToConstant: 32),
            historyButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
