import UIKit

class SettingsView: BaseView {
    lazy var navigationBar = MainNavigationView()
    
    override func setupView() {
        backgroundColor = .lightGrayF2F8FF
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        addSubview(navigationBar)
        navigationBar.setupMainTitleLabel(text: "Settings")
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110)
        ])
    }
    
}
