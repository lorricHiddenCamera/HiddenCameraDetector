import Foundation

class DetectViewModel {
    
    var onLocalNetworkDenied: (() -> Void)?
    
    var onBluetoothNotAvailable: (() -> Void)?
    
    var onSSIDFetched: ((String?) -> Void)?
    
    var onDevicesChanged: (([DeviceInfo]) -> Void)?
    
    // MARK: - Properties
    
    private(set) var devices: [DeviceInfo] = []
    
    private let scannerService: DeviceScannerService
    
    private let localNetworkAuthorization = LocalNetworkAuthorization()
    
    
    init() {
        self.scannerService = DeviceScannerService()
        
        scannerService.onBluetoothNotAvailable = { [weak self] in
            self?.onBluetoothNotAvailable?()
        }
        
        scannerService.onDevicesUpdated = { [weak self] updatedDevices in
            guard let self = self else { return }
            let sortedDevices = updatedDevices.sorted { device1, device2 in
                if device1.connectionType == device2.connectionType {
                    return device1.name < device2.name
                }
                return device1.connectionType == .wifi
            }
            self.devices = sortedDevices
            self.onDevicesChanged?(sortedDevices)
        }
    }
    
    func requestAllPermissions() {
        requestLocalNetworkPermission()
       
        requestLocationAndFetchSSID()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.scannerService.centralManager.state == .unauthorized {
                self.onBluetoothNotAvailable?()
            }
        }
    }
    
    func updateDevice(with device: DeviceInfo) {
        if let index = devices.firstIndex(where: { $0.address == device.address }) {
                devices[index] = device
            onDevicesChanged?(devices)
            }
    }
    
    // MARK: - Local Network
    
    private func requestLocalNetworkPermission() {
        localNetworkAuthorization.requestAuthorization { [weak self] granted in
            guard let self = self else { return }
            if !granted {
                self.onLocalNetworkDenied?()
            }
        }
    }
    
    // MARK: - Location + SSID
    
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
                    print("No access to location => cannot get SSID")
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
    
    func startScanning() {
        scannerService.startScanning()
    }
    
    func stopScanning() {
        scannerService.stopScanning()
    }
    
    
    func numberOfDevices() -> Int {
        return devices.count
    }
    
    func deviceInfo(at index: Int) -> DeviceInfo? {
        guard index >= 0 && index < devices.count else { return nil }
        return devices[index]
    }
    
    func isDevicesEmpty() -> Bool {
        return devices.isEmpty
    }
}
