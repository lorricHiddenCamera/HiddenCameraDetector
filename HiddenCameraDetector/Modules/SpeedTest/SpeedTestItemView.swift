import UIKit

final class SpeedTestItemView: UIView {
    
    private let iconImageView = UIImageView()
    
    private let titleLabel = UILabel()
    
    private let speedLabel = UILabel()
    
    private let unitLabel = UILabel()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        backgroundColor = .white
        
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.font = UIFont.plusJakartaSans(.medium, size: 14)
        titleLabel.textColor = .darkGray
        titleLabel.textAlignment = .center
        
        speedLabel.font = UIFont.plusJakartaSans(.bold, size: 36)
        speedLabel.textColor = .black
        speedLabel.textAlignment = .right
        
        unitLabel.font = UIFont.plusJakartaSans(.regular, size: 14)
        unitLabel.textColor = .gray
        unitLabel.textAlignment = .left
        
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(speedLabel)
        addSubview(unitLabel)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 72)
        ])
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor),
            
            speedLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -6),
            speedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            unitLabel.topAnchor.constraint(equalTo: speedLabel.bottomAnchor),
            unitLabel.centerXAnchor.constraint(equalTo: speedLabel.centerXAnchor)
        ])
    }
    
    // MARK: - Configure
    
    func configure(icon: UIImage?, title: String, speedValue: String, unit: String) {
        iconImageView.image = icon
        titleLabel.text = title
        speedLabel.text = speedValue
        unitLabel.text = unit
    }
}
