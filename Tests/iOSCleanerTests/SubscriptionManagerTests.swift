import XCTest
@testable import iOSCleanerCore

final class SubscriptionManagerTests: XCTestCase {
    var subscriptionManager: SubscriptionManager!
    
    override func setUp() {
        super.setUp()
        subscriptionManager = SubscriptionManager()
    }
    
    override func tearDown() {
        subscriptionManager = nil
        super.tearDown()
    }
    
    func testInitialStatus() {
        let status = subscriptionManager.getStatus()
        
        // Should start with free tier
        XCTAssertEqual(status.tier, .free)
    }
    
    func testFeatureAvailability() {
        // Free tier should have basic cleaning
        XCTAssertTrue(subscriptionManager.isFeatureAvailable(.basicCleaning))
        
        // Free tier should not have premium features
        XCTAssertFalse(subscriptionManager.isFeatureAvailable(.backgroundMonitoring))
        XCTAssertFalse(subscriptionManager.isFeatureAvailable(.gamingMode))
        XCTAssertFalse(subscriptionManager.isFeatureAvailable(.advancedAnalytics))
    }
    
    func testSubscriptionTiers() {
        // Test all tiers have names and features
        for tier in SubscriptionManager.SubscriptionTier.allCases {
            XCTAssertFalse(tier.displayName.isEmpty)
            XCTAssertFalse(tier.price.isEmpty)
            XCTAssertFalse(tier.features.isEmpty)
        }
    }
    
    func testUpgradeOptions() {
        let options = subscriptionManager.getUpgradeOptions()
        
        // Free tier should have upgrade options
        XCTAssertGreaterThan(options.count, 0)
    }
    
    func testCanUpgrade() {
        // Free tier can upgrade
        XCTAssertTrue(subscriptionManager.canUpgrade())
    }
    
    func testFeatureComparison() {
        let comparison = subscriptionManager.getFeatureComparison()
        
        // Should have feature comparison data
        XCTAssertGreaterThan(comparison.count, 0)
        
        // Verify structure
        let firstFeature = comparison[0]
        XCTAssertFalse(firstFeature.feature.isEmpty)
    }
    
    func testPurchaseSubscription() {
        let expectation = self.expectation(description: "Purchase completes")
        
        subscriptionManager.purchaseSubscription(tier: .basic) { result in
            switch result {
            case .success(let status):
                XCTAssertEqual(status.tier, .basic)
                XCTAssertTrue(status.isActive)
            case .failure(let error):
                XCTFail("Purchase failed: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testRestorePurchases() {
        let expectation = self.expectation(description: "Restore completes")
        
        subscriptionManager.restorePurchases { result in
            switch result {
            case .success:
                XCTAssertTrue(true) // Restore succeeded
            case .failure(let error):
                XCTFail("Restore failed: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
    }
}
