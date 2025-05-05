import UIKit

class SplashScreenViewController: UIViewController {
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.launchScreenBg)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.logoIcon)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundImageView)
        view.addSubview(logoImageView)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.widthAnchor.constraint(equalToConstant: 681),
            backgroundImageView.heightAnchor.constraint(equalToConstant: 1108),
            
            backgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 131),
            logoImageView.heightAnchor.constraint(equalToConstant: 131)
        ])
        startPulseAnimation()
    }

    private func startPulseAnimation() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 1.0
        pulse.fromValue = 1.0
        pulse.toValue = 1.1
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        logoImageView.layer.add(pulse, forKey: "pulse")
    }

}
