import CoreMotion
import UIKit
import CoreHaptics

final class MagneticViewModel {
    
    private let motionManager = CMMotionManager()
    private let updateInterval = 0.1
    var currentSSID: String?
    
    var onMagneticFieldValue: ((Double) -> Void)?
    var onRotationAngle: ((CGFloat) -> Void)?
    var onSSIDFetched: ((String?) -> Void)?
    
    private var hapticEngine: CHHapticEngine?
    
    init() {
        prepareHaptics()
        requestLocationAndFetchSSID()
    }
    deinit {
        hapticEngine?.stop(completionHandler: nil)
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Ошибка запуска haptic engine: \(error)")
        }
    }
    
    func start() {
        guard motionManager.isMagnetometerAvailable else {
            print("Магнитометр недоступен на этом устройстве.")
            return
        }
        
        motionManager.magnetometerUpdateInterval = updateInterval
        motionManager.startMagnetometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            
            let x = data.magneticField.x
            let y = data.magneticField.y
            let z = data.magneticField.z
            let magnitude = sqrt(x*x + y*y + z*z)
            self.onMagneticFieldValue?(magnitude)
            
            let degrees: Double
            if magnitude <= 500 {
                degrees = (magnitude / 500.0) * 45.0
            } else {
                let extra = (magnitude - 500.0) / 100.0 * 10.0
                degrees = 45.0 + extra
            }
            
            let finalDegrees = min(degrees, 220.0)
            let angleRad = CGFloat(finalDegrees * .pi / 180.0)
            self.onRotationAngle?(angleRad)
            if magnitude > 500 {
                let intensity = min((magnitude - 300) / (2000 - 300), 1.0)
                self.playHaptic(intensity: intensity)
            }
        }
    }
    
    private func playHaptic(intensity: Double) {
        guard let engine = hapticEngine, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity))
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let event = CHHapticEvent(eventType: .hapticContinuous,
                                  parameters: [intensityParam, sharpnessParam],
                                  relativeTime: 0,
                                  duration: updateInterval)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Ошибка воспроизведения haptic: \(error)")
        }
    }
    
    func requestLocationAndFetchSSID() {
        LocationManager.shared.onAuthorizationChange = { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                if let ssid = NetworkManager.fetchSSID() {
                    DispatchQueue.main.async {
                        self.currentSSID = ssid
                        self.onSSIDFetched?(ssid)
                    }
                } else {
                    DispatchQueue.main.async {
                        print("Нет данных о WI-FI имени")
                        self.onSSIDFetched?("Unknown")
                    }
                }
            default:
                DispatchQueue.main.async {
                    print("Нет доступа к локации")
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
    
    func stop() {
        motionManager.stopMagnetometerUpdates()
    }
}
