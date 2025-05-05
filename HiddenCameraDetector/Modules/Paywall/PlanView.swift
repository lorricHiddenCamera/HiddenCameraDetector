import UIKit

class PlanView: UIControl {
    
    private let checkmarkImageView = UIImageView()
    private let titleLabel = UILabel()
    private let costLabel = UILabel()
    private let trialPeriodLabel = UILabel()
    
    private let gradientLayer = CAGradientLayer()
    
    private let gradientColors: [CGColor] = [
        UIColor("#B0CCFF")!.cgColor,
        UIColor("#3577F2")!.cgColor,
        UIColor("#00328F")!.cgColor
    ]
    
    init(planTitle: String, costText: String, trialText: String) {
        super.init(frame: .zero)
        
        checkmarkImageView.image = UIImage.customCheckmark
        
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        layer.borderWidth = 1
        backgroundColor = .white
        
        titleLabel.text = planTitle
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = .black
        
        costLabel.text = costText
        costLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        costLabel.textColor = .black
        
        trialPeriodLabel.text = trialText
        trialPeriodLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        trialPeriodLabel.textColor = .gray
        
        configureSubviews()
        configureConstraints()
        configureGradient()
        
        layer.cornerRadius = 12
        clipsToBounds = true
        
        gradientLayer.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviews() {
        let views = [checkmarkImageView, titleLabel, costLabel, trialPeriodLabel]
        views.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func configureGradient() {
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            checkmarkImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            checkmarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: checkmarkImageView.trailingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            costLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            costLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            trialPeriodLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            trialPeriodLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    func updateTrialText(_ text: String) {
        trialPeriodLabel.text = text
    }
    
    func updateCostText(_ text: String) {
        costLabel.text = text
    }
    
    override var isSelected: Bool {
        didSet {
            adjustAppearance()
        }
    }
    
    private func adjustAppearance() {
        if isSelected {
            gradientLayer.isHidden = false
            checkmarkImageView.image = UIImage.checkmarkFilled
            
            titleLabel.textColor = .white
            costLabel.textColor = .white
            trialPeriodLabel.textColor = .white
        }
        else {
            gradientLayer.isHidden = true
            layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
            layer.borderWidth = 1
            backgroundColor = .white
            
            checkmarkImageView.image = UIImage.customCheckmark
            titleLabel.textColor = .black
            costLabel.textColor = .black
            trialPeriodLabel.textColor = .gray
        }
    }
}
