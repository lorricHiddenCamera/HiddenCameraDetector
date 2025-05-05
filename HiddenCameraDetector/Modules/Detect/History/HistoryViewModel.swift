import Foundation
import RealmSwift

final class HistoryViewModel {
    private let databaseManager: RealmDatabaseManager
    
    private var devices: [DeviceInfo] = []
    
    var onDevicesLoaded: (([DeviceInfo]) -> Void)?
    
    init(databaseManager: RealmDatabaseManager = .shared) {
        self.databaseManager = databaseManager
    }
    
    func loadDevices() {
        let storedDevices = databaseManager.getAllDevices()
        var loadedDevices = storedDevices.map { stored in
            DeviceInfo(name: stored.name,
                       connectionType: ConnectionType(rawValue: stored.connectionType) ?? .wifi,
                       address: stored.address,
                       isTrusted: stored.isTrusted,
                       isRouter: stored.isRouter)
        }
        
        loadedDevices.sort { device1, device2 in
            if device1.connectionType == device2.connectionType {
                return device1.name < device2.name
            } else {
                return device1.connectionType == .wifi
            }
        }
        
        self.devices = loadedDevices
        onDevicesLoaded?(self.devices)
    }
    
    func updateDeviceStatus(address: String, isTrusted: Bool) {
        databaseManager.updateDeviceStatus(address: address, isTrusted: isTrusted)
        loadDevices()
    }
    
    func removeDevice(address: String) {
        databaseManager.removeDevice(address: address)
        loadDevices()
    }
}
