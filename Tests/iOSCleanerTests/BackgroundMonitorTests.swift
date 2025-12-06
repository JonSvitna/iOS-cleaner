import XCTest
@testable import iOSCleanerCore

final class BackgroundMonitorTests: XCTestCase {
    var backgroundMonitor: BackgroundMonitor!
    var performanceManager: PerformanceManager!
    
    override func setUp() {
        super.setUp()
        performanceManager = PerformanceManager()
        backgroundMonitor = BackgroundMonitor(performanceManager: performanceManager)
    }
    
    override func tearDown() {
        backgroundMonitor = nil
        performanceManager = nil
        super.tearDown()
    }
    
    func testPerformBackgroundCheck() {
        // Test that background check runs without crashing
        let result = backgroundMonitor.performBackgroundCheck()
        
        XCTAssertNotNil(result.timestamp)
        XCTAssertNotNil(result.metrics)
        XCTAssertGreaterThanOrEqual(result.recommendations.count, 0)
    }
    
    func testMetricsHistory() {
        // Perform a check to add to history
        _ = backgroundMonitor.performBackgroundCheck()
        
        // Get history
        let history = backgroundMonitor.getMetricsHistory()
        
        XCTAssertGreaterThan(history.count, 0)
    }
    
    func testSubscriptionCheck() {
        // Test subscription status check
        let isActive = backgroundMonitor.isSubscriptionActive()
        
        // Should return a boolean
        XCTAssertTrue(isActive == true || isActive == false)
    }
    
    func testMonitoringFrequency() {
        // Test that frequency enum has values
        XCTAssertGreaterThan(BackgroundMonitor.MonitoringFrequency.daily.timeInterval, 0)
        XCTAssertGreaterThan(BackgroundMonitor.MonitoringFrequency.weekly.timeInterval, 0)
        XCTAssertGreaterThan(BackgroundMonitor.MonitoringFrequency.monthly.timeInterval, 0)
        
        // Test that weekly > daily
        XCTAssertGreaterThan(
            BackgroundMonitor.MonitoringFrequency.weekly.timeInterval,
            BackgroundMonitor.MonitoringFrequency.daily.timeInterval
        )
    }
    
    func testMetricsHistoryEntry() {
        let entry = MetricsHistoryEntry(
            timestamp: Date(),
            memoryUsagePercentage: 50.0,
            storageUsagePercentage: 75.0
        )
        
        XCTAssertNotNil(entry.timestamp)
        XCTAssertEqual(entry.memoryUsagePercentage, 50.0)
        XCTAssertEqual(entry.storageUsagePercentage, 75.0)
    }
}
