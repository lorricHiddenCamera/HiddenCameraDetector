import Network

protocol AppNetworkMonitoring {
    var isConnected: Bool { get }
    func startMonitoring()
    func stopMonitoring()
    func setUpdateHandler(_ handler: @escaping (Bool) -> Void)
}

final class NetworkMonitorService: AppNetworkMonitoring {

    static let shared = NetworkMonitorService()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .utility)

    private(set) var isConnected: Bool = true
    private var handler: ((Bool) -> Void)?

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            self?.isConnected = connected
            self?.handler?(connected)
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    func setUpdateHandler(_ handler: @escaping (Bool) -> Void) {
        self.handler = handler
    }
}
