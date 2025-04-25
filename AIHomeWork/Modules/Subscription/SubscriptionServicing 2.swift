import Foundation
import Combine
import RevenueCat

public protocol SubscriptionServicing: AnyObject {
    var customerInfoPublisher: AnyPublisher<CustomerInfo?, Never> { get }
    var isPremium: Bool { get }

    func offerings() async throws -> [Package]
    func purchase(_ package: Package) async throws -> Bool
    func restore() async throws
}
