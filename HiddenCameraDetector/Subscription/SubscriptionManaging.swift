import Foundation
import RevenueCat

public protocol SubscriptionManaging: AnyObject {
    func loadOfferings(completion: @escaping (Result<[Package], Error>) -> Void)
    func purchase(package: Package,
                  completion: @escaping (Result<Bool, Error>) -> Void)
    func isPremiumUser() -> Bool
    func restorePurchases(completion: @escaping (Result<Bool, Error>) -> Void)
    func observeCustomerInfoChanges(handler: @escaping (CustomerInfo?) -> Void)
}
