import UIKit

class BlueGradientView: UIView {
    let gradientLayer = CAGradientLayer()
    
    let gradientColors: [CGColor] = [
        UIColor("#B0CCFF")!.cgColor,
        UIColor("#3577F2")!.cgColor,
        UIColor("#00328F")!.cgColor
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradient() {
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
