import UIKit

final class SettingsCell: UITableViewCell {
    static let reuseID = "SettingsCell"
    
    private let backgroundCard = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView(image: UIImage.arrowRightIncon)
    
    private let iconSize: CGFloat = 32

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        
        backgroundCard.layer.cornerRadius = 16
        backgroundCard.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        backgroundCard.layer.borderWidth = 1
        backgroundCard.backgroundColor = .white
        
        titleLabel.textColor = .black
        titleLabel.font = UIFont.plusJakartaSans(.medium, size: 16)
        
        arrowImageView.tintColor = .white
        
        contentView.addSubview(backgroundCard)
        [iconImageView, titleLabel, arrowImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            backgroundCard.addSubview($0)
        }
        
        backgroundCard.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            backgroundCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backgroundCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backgroundCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize),
            iconImageView.centerYAnchor.constraint(equalTo: backgroundCard.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: backgroundCard.leadingAnchor, constant: 16),
            
            titleLabel.centerYAnchor.constraint(equalTo: backgroundCard.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            
            arrowImageView.centerYAnchor.constraint(equalTo: backgroundCard.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: backgroundCard.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalToConstant: iconSize),
            arrowImageView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
    }
    
    func configure(with title: String, icon: UIImage?) {
        titleLabel.text = title
        iconImageView.image = icon
    }
}
