import Combine
import Foundation

enum SpeedTestState {
    case ready
    case testing
    case finished
}

class SpeedTestViewModel: ObservableObject {
    
    @Published var downloadSpeed: Double = 0.0
    @Published var uploadSpeed: Double = 0.0
    @Published var state: SpeedTestState = .ready
    @Published var errorDescription: String = ""
    
    private let averageSpeed: Double = 200.0
    
    private var qualityFactor: Double = 1.0
    
    private var timer: Timer?
    private var elapsedSeconds = 0
    
    var onSSIDFetched: ((String?) -> Void)?
    
    init() {
        requestLocationAndFetchSSID()
    }
    
    func startTest() {
        state = .testing
        downloadSpeed = 0.0
        uploadSpeed = 0.0
        errorDescription = ""
        elapsedSeconds = 0
        
        qualityFactor = Double.random(in: 0.2...0.8)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1
            
            let progress = min(Double(self.elapsedSeconds) / 15.0, 1.0)
            let simulatedDownload = progress * self.qualityFactor * self.averageSpeed
            let simulatedUpload = max(0, simulatedDownload - 10)
            
            self.downloadSpeed = simulatedDownload
            self.uploadSpeed = simulatedUpload
        }
    }
    
    func stopTest() {
        timer?.invalidate()
        timer = nil
        state = .finished
    }
    
    private func requestLocationAndFetchSSID() {
        LocationManager.shared.onAuthorizationChange = { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                if let ssid = NetworkManager.fetchSSID() {
                    DispatchQueue.main.async {
                        self.onSSIDFetched?(ssid)
                    }
                } else {
                    DispatchQueue.main.async {
                        print("No WI-FI name data")
                        self.onSSIDFetched?("Unknown")
                    }
                }
            default:
                DispatchQueue.main.async {
                    print("No access to location")
                    self.onSSIDFetched?("Unknown")
                }
            }
        }
        
        LocationManager.shared.requestAuthorization()
        if let ssid = NetworkManager.fetchSSID() {
            DispatchQueue.main.async {
                self.onSSIDFetched?(ssid)
            }
        }
    }
}
