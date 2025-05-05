import RealmSwift

class StoredDevice: Object {
    @Persisted(primaryKey: true) var address: String
    @Persisted var name: String
    @Persisted var connectionType: String
    @Persisted var isTrusted: Bool
    @Persisted var isRouter: Bool
    
    convenience init(device: DeviceInfo) {
        self.init()
        self.address = device.address
        self.name = device.name
        self.connectionType = device.connectionType.rawValue
        self.isTrusted = device.isTrusted
        self.isRouter = device.isRouter
    }
}
