import Foundation
import SwiftUI
import RevenueCat
import Combine


public final class PaywallService: NSObject, SubscriptionServicing {

    public static let shared = PaywallService()
    
    @AppStorage("freeRequestsLeft") var freeRequestsLeft: Int = 2

    private let premiumEntitlementID = "Premium"

    private let customerInfoSubject = CurrentValueSubject<CustomerInfo?, Never>(nil)

    public var customerInfoPublisher: AnyPublisher<CustomerInfo?, Never> {
        customerInfoSubject.eraseToAnyPublisher()
    }

    public var isPremium: Bool {
        customerInfoSubject.value?.entitlements.active
            .keys
            .contains(premiumEntitlementID) ?? false
    }

    // MARK: – Init

    private override init() {
        super.init()
        Purchases.shared.delegate = self
        Task { await refreshCustomerInfo() }
    }

    public func offerings() async throws -> [Package] {
        try await Purchases
            .shared
            .offerings()
            .current?
            .availablePackages ?? []
    }

    @discardableResult
    public func purchase(_ package: Package) async throws -> Bool {
        let result = try await Purchases.shared.purchase(package: package)
        customerInfoSubject.send(result.customerInfo)
        return !result.userCancelled
    }

    public func restore() async throws {
        let info = try await Purchases.shared.restorePurchases()
        customerInfoSubject.send(info)
    }

    @MainActor
    private func refreshCustomerInfo() async {
        if let info = try? await Purchases.shared.customerInfo() {
            customerInfoSubject.send(info)
            print("[DEBUG] active entitlements:",
                  info.entitlements.active.keys)

        }
    }
    
    func decrementFreeRequestsLeft() {
        guard freeRequestsLeft != 0 else { return }
        freeRequestsLeft -= 1
    }
    
    func isPaywallNeeded() -> Bool {
        if !isPremium && freeRequestsLeft < 1 {
            return true
        }
        else {
            return false
        }
    }
}

extension PaywallService: PurchasesDelegate {

    public func purchases(_ purchases: Purchases,
                          receivedUpdated customerInfo: CustomerInfo) {
        customerInfoSubject.send(customerInfo)
    }

    public func purchases(_ purchases: Purchases,
                          readyForPromotedProduct product: StoreProduct,
                          purchase startPurchase: @escaping StartPurchaseBlock) {

        startPurchase { [weak self] _, info, error, cancelled in
            if let info { self?.customerInfoSubject.send(info) }
            if let error { print("RevenueCat promoted purchase error:", error.localizedDescription) }
            if cancelled { print("RevenueCat promoted purchase cancelled") }
        }
    }
}
