import XCTest
@testable import iOSCleanerCore

final class CacheCleanerTests: XCTestCase {
    
    var cleaner: CacheCleaner!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        cleaner = CacheCleaner()
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: tempDirectory)
    }
    
    func testCleanOldFiles() throws {
        // Create test files with different dates
        let oldFile = tempDirectory.appendingPathComponent("old.txt")
        let recentFile = tempDirectory.appendingPathComponent("recent.txt")
        
        try "old content".write(to: oldFile, atomically: true, encoding: .utf8)
        try "recent content".write(to: recentFile, atomically: true, encoding: .utf8)
        
        // Set old file's access date to 31 days ago
        let oldDate = Calendar.current.date(byAdding: .day, value: -31, to: Date())!
        try FileManager.default.setAttributes([.modificationDate: oldDate], ofItemAtPath: oldFile.path)
        
        let result = try cleaner.cleanOldFiles(in: tempDirectory, olderThanDays: 30)
        
        XCTAssertGreaterThan(result.itemsRemoved, 0)
        XCTAssertGreaterThan(result.spaceFreed, 0)
        
        // Old file should be removed
        XCTAssertFalse(FileManager.default.fileExists(atPath: oldFile.path))
        // Recent file should still exist
        XCTAssertTrue(FileManager.default.fileExists(atPath: recentFile.path))
    }
    
    func testPerformFullCleanup() {
        let results = cleaner.performFullCleanup()
        
        // Should return results for temp and cache cleaning
        XCTAssertFalse(results.isEmpty)
    }
    
    func testCleaningResultStructure() {
        let result = CacheCleaner.CleaningResult(itemsRemoved: 5, spaceFreed: 1024, category: "Test")
        
        XCTAssertEqual(result.itemsRemoved, 5)
        XCTAssertEqual(result.spaceFreed, 1024)
        XCTAssertEqual(result.category, "Test")
    }
}
