import UIKit

final class InfoView: BaseView {
    
    lazy var navigationBar = MainNavigationView()
    
    let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        return table
    }()
    
    override func setupView() {
        backgroundColor = .lightGrayF2F8FF
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        addSubview(navigationBar)
        navigationBar.setupMainTitleLabel(text: "Information")
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110)
        ])
    }
    
    private func setupTableView() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100)
        ])
    }
}
