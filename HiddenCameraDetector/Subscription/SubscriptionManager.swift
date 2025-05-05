import Foundation
import RevenueCat

public final class SubscriptionManager: NSObject, SubscriptionManaging {
    
    public static let shared = SubscriptionManager()

    private var currentCustomerInfo: CustomerInfo? {
        didSet {
            notifyObservers()
        }
    }

    private var observers: [UUID: (CustomerInfo?) -> Void] = [:]

    
    // MARK: - Init

    private override init() {
        super.init()
        setupRevenueCat()
    }
    
    private func setupRevenueCat() {
        
        Purchases.shared.delegate = self
        
        Purchases.shared.getCustomerInfo { [weak self] info, error in
            guard let self = self else { return }
            self.currentCustomerInfo = info
        }
    }
    
    // MARK: -  SubscriptionManaging
    
    public func loadOfferings(completion: @escaping (Result<[Package], Error>) -> Void) {
        Purchases.shared.getOfferings { [weak self] offerings, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let defaultOffering = offerings?.current else {
                completion(.success([]))
                return
            }
            
            let packages = defaultOffering.availablePackages
            completion(.success(packages))
        }
    }
    
    public func purchase(package: Package,
                         completion: @escaping (Result<Bool, Error>) -> Void) {
        Purchases.shared.purchase(package: package) { [weak self] transaction, info, error, userCancelled in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if userCancelled {
                completion(.success(false))
                return
            }
            
            self.currentCustomerInfo = info
            completion(.success(true))
        }
    }
    
    public func isPremiumUser() -> Bool {
        return currentCustomerInfo?.entitlements.active.keys.contains("premium") ?? false
    }
    
    public func restorePurchases(completion: @escaping (Result<Bool, Error>) -> Void) {
        Purchases.shared.restorePurchases { [weak self] info, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            self.currentCustomerInfo = info
            completion(.success(true))
        }
    }
    
    public func observeCustomerInfoChanges(handler: @escaping (CustomerInfo?) -> Void) {
        let id = UUID()
        observers[id] = handler
        handler(currentCustomerInfo)
    }
    
    private func notifyObservers() {
        for (_, observer) in observers {
            observer(currentCustomerInfo)
        }
    }
}

// MARK: - PurchasesDelegate

extension SubscriptionManager: PurchasesDelegate {
    
    public func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        currentCustomerInfo = customerInfo
    }
    
    
    public func purchases(_ purchases: Purchases,
                          readyForPromotedProduct product: StoreProduct,
                          purchase startPurchase: @escaping StartPurchaseBlock) {
        
        startPurchase { transaction, customerInfo, error, userCancelled in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
            } else if userCancelled {
                print("🚫 Cancelled")
            } else {
                print("✅ Success!")
            }
        }
    }
}
