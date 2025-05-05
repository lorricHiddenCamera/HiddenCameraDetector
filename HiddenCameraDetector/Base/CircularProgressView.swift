import UIKit

final class CircularProgressView: BaseView {
    
    // MARK: - Subviews / Sublayers
    
    private let innerShadowLayer = CAShapeLayer()
    private let backgroundCircleLayer = CAShapeLayer()
    private let progressCircleLayer = CAShapeLayer()
    
    private let wifiIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.wifiIcon.resizeImage(to: CGSize(width: 140, height: 70)))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.lightBlue6180F2.withAlphaComponent(0.8)
        label.font = UIFont.plusJakartaSans(.bold, size: iphoneWithButton ? 38 : 44)
        label.text = "0%"
        return label
    }()
    
    private var currentProgress: CGFloat = 0
    
    private var displayLink: CADisplayLink?
    
    private var animationCompletion: (() -> Void)?
    
    // MARK: - BaseView
    
    override func setupView() {
        layer.addSublayer(backgroundCircleLayer)
        
        layer.addSublayer(innerShadowLayer)
        
        layer.addSublayer(progressCircleLayer)
        
        backgroundCircleLayer.fillColor = UIColor.white.cgColor
        backgroundCircleLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        backgroundCircleLayer.lineWidth = 10
        backgroundCircleLayer.lineCap = .round
        
        innerShadowLayer.fillRule = .evenOdd
        innerShadowLayer.shadowColor = UIColor.black.cgColor
        innerShadowLayer.shadowOffset = CGSize(width: 0, height: 4)
        innerShadowLayer.shadowOpacity = 0.15
        innerShadowLayer.shadowRadius = 6
        
        configureCircleLayer(
            progressCircleLayer,
            strokeColor: UIColor.lightBlue6180F2.cgColor,
            fillColor: UIColor.clear.cgColor,
            lineWidth: 10
        )
        progressCircleLayer.strokeEnd = 0
        
        addSubview(wifiIconImageView)
        addSubview(percentageLabel)
        wifiIconImageView.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            wifiIconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            wifiIconImageView.bottomAnchor.constraint(equalTo: centerYAnchor),
            wifiIconImageView.widthAnchor.constraint(equalToConstant: iphoneWithButton ? 120 : 140),
            wifiIconImageView.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 60 : 70),
            
            percentageLabel.topAnchor.constraint(equalTo: wifiIconImageView.bottomAnchor, constant: 8),
            percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let radius = min(bounds.width, bounds.height) / 2 * 0.8
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let circlePath = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        backgroundCircleLayer.frame = bounds
        backgroundCircleLayer.path = circlePath.cgPath
        
        let biggerRect = bounds.insetBy(dx: -20, dy: -20)
        let biggerPath = UIBezierPath(rect: biggerRect)
        biggerPath.append(circlePath)
        innerShadowLayer.frame = bounds
        innerShadowLayer.path = biggerPath.cgPath
        innerShadowLayer.fillColor = UIColor.clear.cgColor
        
        progressCircleLayer.frame = bounds
        progressCircleLayer.path = circlePath.cgPath
    }
    
    // MARK: - Public Methods
    
    func setProgress(_ progress: CGFloat,
                     animated: Bool = false,
                     duration: CFTimeInterval = 2.0,
                     completion: (() -> Void)? = nil) {
        percentageLabel.textColor = UIColor.lightBlue6180F2
        let clampedProgress = max(0, min(progress, 1))
        currentProgress = clampedProgress
        
        if !animated {
            progressCircleLayer.removeAnimation(forKey: "progressAnimation")
            progressCircleLayer.strokeEnd = clampedProgress
            percentageLabel.text = "\(Int(clampedProgress * 100))%"
            return
        }
        
        self.animationCompletion = completion
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressCircleLayer.strokeEnd
        animation.toValue = clampedProgress
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        
        progressCircleLayer.strokeEnd = clampedProgress
        progressCircleLayer.add(animation, forKey: "progressAnimation")
        
        startDisplayLink()
    }
    
    func setLabelText(_ text: String) {
        percentageLabel.text = text
        percentageLabel.textColor = UIColor.lightBlue6180F2
    }
    
    // MARK: - Private Methods
    
    private func configureCircleLayer(_ layer: CAShapeLayer,
                                      strokeColor: CGColor,
                                      fillColor: CGColor,
                                      lineWidth: CGFloat) {
        layer.strokeColor = strokeColor
        layer.fillColor = fillColor
        layer.lineWidth = lineWidth
        layer.lineCap = .round
    }
    
    private func startDisplayLink() {
        displayLink?.invalidate()
        let link = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func handleDisplayLink() {
        guard let presentationLayer = progressCircleLayer.presentation() else { return }
        let currentStrokeEnd = presentationLayer.strokeEnd
        percentageLabel.text = "\(Int(currentStrokeEnd * 100))%"
    }
}

// MARK: - CAAnimationDelegate

extension CircularProgressView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopDisplayLink()
        
        if flag {
            let finalValue = Int(progressCircleLayer.strokeEnd * 100)
            percentageLabel.text = "\(finalValue)%"
            
            animationCompletion?()
        }
    }
}
