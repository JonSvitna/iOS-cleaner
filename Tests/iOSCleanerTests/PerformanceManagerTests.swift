import XCTest
@testable import iOSCleanerCore

final class PerformanceManagerTests: XCTestCase {
    var performanceManager: PerformanceManager!
    
    override func setUp() {
        super.setUp()
        performanceManager = PerformanceManager()
    }
    
    override func tearDown() {
        performanceManager = nil
        super.tearDown()
    }
    
    func testGetCurrentMetrics() {
        // Test that we can get metrics without crashing
        let metrics = performanceManager.getCurrentMetrics()
        
        // On non-Darwin platforms, memory values will be 0
        XCTAssertGreaterThanOrEqual(metrics.memoryUsage, 0)
        XCTAssertGreaterThanOrEqual(metrics.availableMemory, 0)
        XCTAssertGreaterThanOrEqual(metrics.storageUsed, 0)
        XCTAssertGreaterThanOrEqual(metrics.storageAvailable, 0)
    }
    
    func testPerformanceModes() {
        // Test setting different modes
        performanceManager.setMode(.speed)
        XCTAssertEqual(performanceManager.getCurrentMode(), .speed)
        
        performanceManager.setMode(.batterySaver)
        XCTAssertEqual(performanceManager.getCurrentMode(), .batterySaver)
        
        performanceManager.setMode(.gaming)
        XCTAssertEqual(performanceManager.getCurrentMode(), .gaming)
    }
    
    func testModeDescriptions() {
        // Verify all modes have descriptions
        XCTAssertFalse(PerformanceManager.PerformanceMode.speed.description.isEmpty)
        XCTAssertFalse(PerformanceManager.PerformanceMode.batterySaver.description.isEmpty)
        XCTAssertFalse(PerformanceManager.PerformanceMode.gaming.description.isEmpty)
    }
    
    func testGetRecommendations() {
        // Test that we get some recommendations
        let recommendations = performanceManager.getRecommendations()
        
        // Should always return some recommendations
        XCTAssertGreaterThanOrEqual(recommendations.count, 0)
    }
    
    func testEstimatePerformanceImpact() {
        // Test impact estimation for different sizes
        let smallImpact = performanceManager.estimatePerformanceImpact(cleaningSize: 50_000_000)
        XCTAssertFalse(smallImpact.isEmpty)
        
        let mediumImpact = performanceManager.estimatePerformanceImpact(cleaningSize: 2_000_000_000)
        XCTAssertFalse(mediumImpact.isEmpty)
        
        let largeImpact = performanceManager.estimatePerformanceImpact(cleaningSize: 6_000_000_000)
        XCTAssertFalse(largeImpact.isEmpty)
    }
    
    func testMetricsPercentages() {
        let metrics = PerformanceManager.PerformanceMetrics(
            memoryUsage: 500_000_000,
            availableMemory: 500_000_000,
            storageUsed: 30_000_000_000,
            storageAvailable: 10_000_000_000
        )
        
        XCTAssertEqual(metrics.memoryUsagePercentage, 50.0, accuracy: 0.1)
        XCTAssertEqual(metrics.storageUsagePercentage, 75.0, accuracy: 0.1)
    }
}
