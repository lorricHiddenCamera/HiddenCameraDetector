import UIKit

class ScanController: UIViewController {
    
    // MARK: - Properties
    
    private let coordinator: ScanCoordinator
    private let viewModel = ScanViewModel()
    
    private let navigationBar = BaseNavigationView(isBackButtonHidden: false, titleText: "Camera")
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.scannerBackground)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let processedImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let colorOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let colorStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var circleColors = [UIView: UIColor]()
    
    // MARK: - Initialization
    
    init(coordinator: ScanCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
        viewModel.checkCameraPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.startSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.stopSession()
    }
    
    // MARK: - Setup Methods
    
    private func setupBindings() {
        navigationBar.onBackButtonTapped = { [weak self] in
            self?.coordinator.pop()
        }
        
        viewModel.onCameraReady = { [weak self] in
            UIView.animate(withDuration: 0.6) {
                self?.backgroundImageView.alpha = 0
            }
        }
        
        viewModel.onCameraPermissionDenied = { [weak self] in
            self?.showAlertForSettings(title: "No Camera access", message: "Please, give access to camera to continue")
            }
        
        viewModel.onFrameProcessed = { [weak self] image in
            self?.processedImageView.image = image
        }
    }
    private func showAlertForSettings(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        alert.addAction(settingsAction)
        
        let backAction = UIAlertAction(title: "Back", style: .cancel) { _ in
            self.coordinator.finish()
        }
        alert.addAction(backAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        
        view.addSubview(processedImageView)
        NSLayoutConstraint.activate([
            processedImageView.topAnchor.constraint(equalTo: view.topAnchor),
            processedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            processedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            processedImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(colorOverlayView)
        NSLayoutConstraint.activate([
            colorOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            colorOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            colorOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            colorOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.backgroundColor = .white
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: iphoneWithButton ? 90 : 110)
        ])
        navigationBar.titleText = "Camera"
        
        view.addSubview(colorStack)
        NSLayoutConstraint.activate([
            colorStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            colorStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let redCircle = makeColorCircle(color: .red)
        let greenCircle = makeColorCircle(color: .green)
        let blueCircle = makeColorCircle(color: .blue)
        
        colorStack.addArrangedSubview(redCircle)
        colorStack.addArrangedSubview(greenCircle)
        colorStack.addArrangedSubview(blueCircle)
        
        viewModel.overlayColor = .red
        updateCircleSelection()
    }
    
    // MARK: - Helper Methods
    
    private func makeColorCircle(color: UIColor) -> UIView {
        let circleView = UIView()
        circleView.backgroundColor = color
        circleView.layer.cornerRadius = 15
        circleView.layer.masksToBounds = true
        circleView.layer.borderWidth = 0
        
        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: 30),
            circleView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        circleColors[circleView] = color
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(circleTapped(_:)))
        circleView.addGestureRecognizer(tapGesture)
        circleView.isUserInteractionEnabled = true
        
        return circleView
    }
    
    // MARK: - Actions
    
    @objc private func circleTapped(_ gesture: UITapGestureRecognizer) {
        guard let circle = gesture.view,
              let chosenColor = circleColors[circle] else { return }
        
        colorOverlayView.backgroundColor = chosenColor
        viewModel.overlayColor = chosenColor
        
        updateCircleSelection()
    }
    
    private func updateCircleSelection() {
        for circle in colorStack.arrangedSubviews {
            guard let originalColor = circleColors[circle] else { continue }
            if originalColor == viewModel.overlayColor {
                circle.backgroundColor = .clear
                circle.layer.borderWidth = 3
                circle.layer.borderColor = originalColor.cgColor
            } else {
                circle.backgroundColor = originalColor
                circle.layer.borderWidth = 0
            }
        }
    }
}
