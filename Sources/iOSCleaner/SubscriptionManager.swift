import Foundation
#if canImport(StoreKit)
import StoreKit
#endif

/// Manages in-app subscriptions and feature access
@available(iOS 15.0, *)
public class SubscriptionManager {
    
    /// Subscription tier levels
    public enum SubscriptionTier: String, CaseIterable, Hashable {
        case free = "Free"
        case basic = "Basic"
        case premium = "Premium"
        
        public var displayName: String {
            return rawValue
        }
        
        public var price: String {
            switch self {
            case .free:
                return "Free"
            case .basic:
                return "$2.99/month"
            case .premium:
                return "$4.99/month"
            }
        }
        
        public var features: [String] {
            switch self {
            case .free:
                return [
                    "Basic storage analysis",
                    "Manual cache cleaning",
                    "Duplicate file detection"
                ]
            case .basic:
                return [
                    "All Free features",
                    "Background monitoring",
                    "Performance modes (Speed, Battery Saver)",
                    "Weekly optimization reports",
                    "Photo library scanning"
                ]
            case .premium:
                return [
                    "All Basic features",
                    "Gaming Mode",
                    "Daily background monitoring",
                    "Advanced analytics",
                    "Priority support",
                    "Unlimited storage scans"
                ]
            }
        }
        
        public var productIdentifier: String {
            switch self {
            case .free:
                return ""
            case .basic:
                return "com.ioscleaner.subscription.basic"
            case .premium:
                return "com.ioscleaner.subscription.premium"
            }
        }
    }
    
    /// Subscription status
    public struct SubscriptionStatus {
        public let tier: SubscriptionTier
        public let isActive: Bool
        public let expirationDate: Date?
        public let autoRenewing: Bool
        
        public init(tier: SubscriptionTier, isActive: Bool, expirationDate: Date?, autoRenewing: Bool) {
            self.tier = tier
            self.isActive = isActive
            self.expirationDate = expirationDate
            self.autoRenewing = autoRenewing
        }
    }
    
    private var currentStatus: SubscriptionStatus
    private let userDefaults = UserDefaults.standard
    private let subscriptionKey = "subscriptionTier"
    
    public init() {
        // Load saved subscription or default to free
        let savedTier = userDefaults.string(forKey: subscriptionKey) ?? SubscriptionTier.free.rawValue
        let tier = SubscriptionTier(rawValue: savedTier) ?? .free
        
        self.currentStatus = SubscriptionStatus(
            tier: tier,
            isActive: tier != .free,
            expirationDate: nil,
            autoRenewing: false
        )
    }
    
    /// Get current subscription status
    public func getStatus() -> SubscriptionStatus {
        return currentStatus
    }
    
    /// Check if a feature is available with current subscription
    public func isFeatureAvailable(_ feature: Feature) -> Bool {
        switch feature {
        case .basicCleaning:
            return true // Available to all
        case .backgroundMonitoring:
            return currentStatus.tier == .basic || currentStatus.tier == .premium
        case .performanceModes:
            return currentStatus.tier == .basic || currentStatus.tier == .premium
        case .gamingMode:
            return currentStatus.tier == .premium
        case .advancedAnalytics:
            return currentStatus.tier == .premium
        case .photoLibraryScanning:
            return currentStatus.tier == .basic || currentStatus.tier == .premium
        }
    }
    
    /// Features that can be gated by subscription
    public enum Feature {
        case basicCleaning
        case backgroundMonitoring
        case performanceModes
        case gamingMode
        case advancedAnalytics
        case photoLibraryScanning
    }
    
    /// Purchase a subscription
    public func purchaseSubscription(tier: SubscriptionTier, completion: @escaping (Result<SubscriptionStatus, Error>) -> Void) {
        // In a real app, this would use StoreKit 2 to process the purchase
        // For now, simulate a successful purchase
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let newStatus = SubscriptionStatus(
                tier: tier,
                isActive: true,
                expirationDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
                autoRenewing: true
            )
            
            self.currentStatus = newStatus
            self.userDefaults.set(tier.rawValue, forKey: self.subscriptionKey)
            
            completion(.success(newStatus))
        }
    }
    
    /// Restore previous purchases
    public func restorePurchases(completion: @escaping (Result<SubscriptionStatus, Error>) -> Void) {
        // In a real app, this would use StoreKit to restore purchases
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(self.currentStatus))
        }
    }
    
    /// Cancel subscription
    public func cancelSubscription(completion: @escaping (Result<Void, Error>) -> Void) {
        // In a real app, users would cancel through App Store settings
        // This would update our local state
        
        let freeStatus = SubscriptionStatus(
            tier: .free,
            isActive: false,
            expirationDate: nil,
            autoRenewing: false
        )
        
        self.currentStatus = freeStatus
        self.userDefaults.set(SubscriptionTier.free.rawValue, forKey: subscriptionKey)
        
        completion(.success(()))
    }
    
    /// Get available products for purchase
    public func getAvailableProducts(completion: @escaping (Result<[SubscriptionTier], Error>) -> Void) {
        // In a real app, this would fetch products from App Store
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success([.basic, .premium]))
        }
    }
    
    /// Get upgrade options for current tier
    public func getUpgradeOptions() -> [SubscriptionTier] {
        switch currentStatus.tier {
        case .free:
            return [.basic, .premium]
        case .basic:
            return [.premium]
        case .premium:
            return []
        }
    }
    
    /// Check if upgrade is available
    public func canUpgrade() -> Bool {
        return !getUpgradeOptions().isEmpty
    }
    
    /// Get feature comparison for tiers
    public func getFeatureComparison() -> [(feature: String, free: Bool, basic: Bool, premium: Bool)] {
        return [
            ("Basic Storage Analysis", true, true, true),
            ("Manual Cache Cleaning", true, true, true),
            ("Duplicate File Detection", true, true, true),
            ("Background Monitoring", false, true, true),
            ("Performance Modes", false, true, true),
            ("Photo Library Scanning", false, true, true),
            ("Weekly Reports", false, true, true),
            ("Gaming Mode", false, false, true),
            ("Daily Monitoring", false, false, true),
            ("Advanced Analytics", false, false, true),
            ("Priority Support", false, false, true)
        ]
    }
}

/// Subscription-related errors
public enum SubscriptionError: Error {
    case purchaseFailed
    case restoreFailed
    case productNotFound
    case userCancelled
    
    public var description: String {
        switch self {
        case .purchaseFailed:
            return "Purchase failed. Please try again."
        case .restoreFailed:
            return "Failed to restore purchases."
        case .productNotFound:
            return "Product not available."
        case .userCancelled:
            return "Purchase cancelled by user."
        }
    }
}
