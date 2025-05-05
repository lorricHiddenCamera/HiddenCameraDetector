import RealmSwift

class RealmDatabaseManager {
    static let shared = RealmDatabaseManager()
    private let realm = try! Realm()
    
    func addOrUpdateDevice(_ device: DeviceInfo) {
        let storedDevice = StoredDevice(device: device)
        try! realm.write {
            realm.add(storedDevice, update: .modified)
        }
    }
    
    func getDevice(by address: String) -> StoredDevice? {
        return realm.object(ofType: StoredDevice.self, forPrimaryKey: address)
    }
    
    func isDeviceTrusted(address: String) -> Bool {
        return getDevice(by: address)?.isTrusted ?? false
    }
    
    func updateDeviceStatus(address: String, isTrusted: Bool) {
        guard let storedDevice = getDevice(by: address) else { return }
        try! realm.write {
            storedDevice.isTrusted = isTrusted
        }
    }
    
    func removeDevice(address: String) {
        guard let storedDevice = getDevice(by: address) else { return }
        try! realm.write {
            realm.delete(storedDevice)
        }
    }
    
    func getAllDevices() -> [StoredDevice] {
        return Array(realm.objects(StoredDevice.self))
    }
}
