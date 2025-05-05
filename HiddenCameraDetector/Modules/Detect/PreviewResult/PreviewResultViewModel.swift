import Foundation

class PreviewResultViewModel {
    
    private let devices: [DeviceInfo]
    
    init(devices: [DeviceInfo]) {
        self.devices = devices
    }
    
    func getNumberOfTrustedDevices() -> Int {
        return devices.filter { $0.isTrusted }.count
    }
    
    func getNumberOfUntrustedDevices() -> Int {
        return devices.count - getNumberOfTrustedDevices()
    }
    
    func getNumberOfAllDevices() -> Int {
        return devices.count
    }
    
}
