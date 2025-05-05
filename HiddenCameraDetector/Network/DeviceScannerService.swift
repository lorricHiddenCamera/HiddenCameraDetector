import Foundation
import CoreBluetooth
import LanScanner

class DeviceScannerService: NSObject {
    
    // MARK: - Properties
    
    private(set) var discoveredDevices: [DeviceInfo] = []
    var onDevicesUpdated: (([DeviceInfo]) -> Void)?
    var onBluetoothNotAvailable: (() -> Void)?
    
    var centralManager: CBCentralManager!
    
    private var lanScanner: LanScanner!
    
    private var defaultRouterIPAddress: String? {
        return computeDefaultRouterIPAddress()
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        lanScanner = LanScanner(delegate: self)
    }
    
    // MARK: - Scanning Methods
    
    func startScanning() {
        discoveredDevices.removeAll()
        onDevicesUpdated?(discoveredDevices)
        
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
        DispatchQueue.main.async {
            self.lanScanner.start()
        }
        
    }
    
    func stopScanning() {
        centralManager.stopScan()
        DispatchQueue.main.async {
            self.lanScanner.stop()
        }
    }
    
    // MARK: - Helper Methods
    
    private func addDevice(_ device: DeviceInfo) {
        if !discoveredDevices.contains(where: { $0.address == device.address }) {
            var updatedDevice = device
            
            if let storedDevice = RealmDatabaseManager.shared.getDevice(by: device.address) {
                updatedDevice.isTrusted = storedDevice.isTrusted
                updatedDevice.isRouter = storedDevice.isRouter
            }
            else {
                RealmDatabaseManager.shared.addOrUpdateDevice(device)
            }
            
            discoveredDevices.append(updatedDevice)
            onDevicesUpdated?(discoveredDevices)
        }
    }
    
    private func computeDefaultRouterIPAddress() -> String? {
        guard let localIP = getWiFiAddress() else { return nil }
        var components = localIP.split(separator: ".")
        if components.count == 4 {
            components[3] = "1"
            return components.joined(separator: ".")
        }
        return nil
    }
    
    private func getWiFiAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                guard let interface = ptr?.pointee else { continue }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: interface.ifa_name)
                    if name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        let result = getnameinfo(interface.ifa_addr,
                                                 socklen_t(interface.ifa_addr.pointee.sa_len),
                                                 &hostname,
                                                 socklen_t(hostname.count),
                                                 nil,
                                                 socklen_t(0),
                                                 NI_NUMERICHOST)
                        if result == 0 {
                            address = String(cString: hostname)
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}

// MARK: - CBCentralManagerDelegate

extension DeviceScannerService: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            onBluetoothNotAvailable?()
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        let deviceName = peripheral.name ?? "Unknown Bluetooth Device"
        let address = peripheral.identifier.uuidString
        
        let bluetoothDevice = DeviceInfo(name: deviceName,
                                         connectionType: .bluetooth,
                                         address: address,
                                         isTrusted: peripheral.name != nil,
                                         isRouter: false)
        addDevice(bluetoothDevice)
    }
}

// MARK: - LanScannerDelegate

extension DeviceScannerService: LanScannerDelegate {
    
    func lanScanHasUpdatedProgress(_ progress: CGFloat, address: String) {}
    
    func lanScanDidFindNewDevice(_ device: LanDevice) {
        var name = device.name
        var isRouter = false
        var isTrusted = false
        
        if let routerIP = defaultRouterIPAddress, device.ipAddress == routerIP {
            isRouter = true
            isTrusted = true
        }
        
        if let localIP = getWiFiAddress(), device.ipAddress == localIP {
            isTrusted = true
            name = "Your iPhone"
        }
        
        let lanDevice = DeviceInfo(name: name,
                                   connectionType: .wifi,
                                   address: device.ipAddress,
                                   isTrusted: isTrusted,
                                   isRouter: isRouter)
        addDevice(lanDevice)
    }
    
    func lanScanDidFinishScanning() {
        print("LAN scanning finished.")
        onDevicesUpdated?(discoveredDevices)
    }
}
