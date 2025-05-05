import Foundation

struct DeviceInfo: Hashable {
    var name: String
    var connectionType: ConnectionType
    var address: String = "Unknown"
    var isTrusted: Bool = false
    var isRouter: Bool = false
}

enum ConnectionType: String {
    case bluetooth, wifi
}
