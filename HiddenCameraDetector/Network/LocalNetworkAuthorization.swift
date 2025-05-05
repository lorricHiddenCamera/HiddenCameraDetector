import Foundation
import Network
import UIKit

public class LocalNetworkAuthorization: NSObject {
    
    private var browser: NWBrowser?
    private var netService: NetService?
    private var completion: ((Bool) -> Void)?
    
    public func requestAuthorization(completion: @escaping (Bool) -> Void) {
        self.completion = completion
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        let browser = NWBrowser(for: .bonjour(type: "_bonjour._tcp", domain: nil), using: parameters)
        self.browser = browser
        
        browser.stateUpdateHandler = { newState in
            switch newState {
            case .failed(let error):
                print("Local network permission error: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            case .ready:
                print("Local network permission granted")
                DispatchQueue.main.async {
                    completion(true)
                }
            case .cancelled:
                break
            case .waiting(let error):
                print("Local network permission denied or waiting: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            default:
                break
            }
        }
        
        self.netService = NetService(domain: "local.",
                                     type: "_lnp._tcp.",
                                     name: "LocalNetworkPrivacy",
                                     port: 1100)
        self.netService?.delegate = self
        
        self.browser?.start(queue: .main)
        self.netService?.publish()
    }
    
    private func reset() {
        self.browser?.cancel()
        self.browser = nil
        self.netService?.stop()
        self.netService = nil
    }
}

extension LocalNetworkAuthorization: NetServiceDelegate {
    public func netServiceDidPublish(_ sender: NetService) {
        print("Local network permission has been granted")
        reset()
        completion?(true)
    }
}
