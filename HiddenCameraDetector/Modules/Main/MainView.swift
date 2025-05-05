import UIKit

class MainView: BaseView {
    
    // MARK: - Navigation Bar
    
    lazy var navigationBar = MainNavigationView()
    
    // MARK: - Section Labels
    
    private let popularFeaturesLabel: UILabel = {
        let label = UILabel()
        label.text = "Popular Features"
        label.font = UIFont.plusJakartaSans(.semiBold, size: 17)
        label.textColor = .gray
        return label
    }()
    
    private let usefulToolsLabel: UILabel = {
        let label = UILabel()
        label.text = "Useful Tools"
        label.font = UIFont.plusJakartaSans(.semiBold, size: 17)
        label.textColor = .gray
        return label
    }()
    
    // MARK: - Feature Buttons
    
    lazy var scannerButton: UIButton = {
        let button = UIButton(type: .custom)
        let baseImage = UIImage.scannerCard
        button.setImage(baseImage, for: .normal)
        
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    lazy var detectButton: UIButton = {
        let button = UIButton(type: .custom)
        let baseImage = UIImage.detectCard
        button.setImage(baseImage, for: .normal)
        
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    lazy var speedTesterButton: UIButton = {
        let button = UIButton(type: .custom)
        let baseImage = UIImage.speedCard
            
        button.setImage(baseImage, for: .normal)
       
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    lazy var magneticButton: UIButton = {
        let button = UIButton(type: .custom)
        let baseImage = UIImage.magneticCard
            
        button.setImage(baseImage, for: .normal)
        
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    // MARK: - Setup
    
    override func setupView() {
        backgroundColor = .lightGrayF2F8FF
        setupNavigationBar()
        setupContent()
    }
    
    private func setupNavigationBar() {
        addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110)
        ])
    }
    
    
    
    private func setupContent() {
        [popularFeaturesLabel,
         scannerButton,
         detectButton,
         usefulToolsLabel,
         speedTesterButton,
         magneticButton].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            popularFeaturesLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: iphoneWithButton ? 5 : 16),
            popularFeaturesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            popularFeaturesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        var bigButtonSize: CGFloat = 0
        
        if iphoneWithButton {
            bigButtonSize = 130
        }
        else {
            bigButtonSize = 140
        }
       
        
        NSLayoutConstraint.activate([
            scannerButton.topAnchor.constraint(equalTo: popularFeaturesLabel.bottomAnchor),
            scannerButton.leadingAnchor.constraint(equalTo: popularFeaturesLabel.leadingAnchor),
            scannerButton.trailingAnchor.constraint(equalTo: popularFeaturesLabel.trailingAnchor),
            scannerButton.heightAnchor.constraint(equalToConstant: screenSize.height > 900 ? 155 : bigButtonSize),
            
            detectButton.topAnchor.constraint(equalTo: scannerButton.bottomAnchor),
            detectButton.leadingAnchor.constraint(equalTo: popularFeaturesLabel.leadingAnchor),
            detectButton.trailingAnchor.constraint(equalTo: popularFeaturesLabel.trailingAnchor),
            detectButton.heightAnchor.constraint(equalToConstant: screenSize.height > 900 ? 150 : bigButtonSize),
        ])
        
        NSLayoutConstraint.activate([
            usefulToolsLabel.topAnchor.constraint(equalTo: detectButton.bottomAnchor, constant: 5),
            usefulToolsLabel.leadingAnchor.constraint(equalTo: popularFeaturesLabel.leadingAnchor),
            usefulToolsLabel.trailingAnchor.constraint(equalTo: popularFeaturesLabel.trailingAnchor)
        ])
        
        var smallButtonSize: CGFloat = 0
        
        if iphoneWithButton {
            smallButtonSize = 170
        }
        else {
            smallButtonSize = 185
        }
        
        NSLayoutConstraint.activate([
            speedTesterButton.topAnchor.constraint(equalTo: usefulToolsLabel.bottomAnchor, constant: 5),
            speedTesterButton.leadingAnchor.constraint(equalTo: detectButton.leadingAnchor),
            speedTesterButton.widthAnchor.constraint(equalToConstant: screenSize.height > 900 ? 200 : smallButtonSize),
            speedTesterButton.heightAnchor.constraint(equalToConstant: screenSize.height > 900 ? 200 : smallButtonSize),
            
            magneticButton.topAnchor.constraint(equalTo: speedTesterButton.topAnchor),
            magneticButton.trailingAnchor.constraint(equalTo: scannerButton.trailingAnchor),
            magneticButton.heightAnchor.constraint(equalToConstant: screenSize.height > 900 ? 200 : smallButtonSize),
            magneticButton.widthAnchor.constraint(equalToConstant: screenSize.height > 900 ? 200 : smallButtonSize)
            
          
            
        ])
        
    }
}
