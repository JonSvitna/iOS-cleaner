import XCTest
@testable import iOSCleanerCore

final class DuplicateDetectorTests: XCTestCase {
    
    var detector: DuplicateDetector!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        detector = DuplicateDetector()
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: tempDirectory)
    }
    
    func testNoDuplicatesInEmptyDirectory() {
        let duplicates = detector.findDuplicates(in: [tempDirectory])
        
        XCTAssertTrue(duplicates.isEmpty)
    }
    
    func testFindDuplicateFiles() throws {
        // Create duplicate files
        let file1 = tempDirectory.appendingPathComponent("file1.txt")
        let file2 = tempDirectory.appendingPathComponent("file2.txt")
        let file3 = tempDirectory.appendingPathComponent("file3.txt")
        
        let duplicateContent = "This is duplicate content".data(using: .utf8)!
        let uniqueContent = "This is unique content".data(using: .utf8)!
        
        try duplicateContent.write(to: file1)
        try duplicateContent.write(to: file2)
        try uniqueContent.write(to: file3)
        
        let duplicates = detector.findDuplicates(in: [tempDirectory])
        
        XCTAssertEqual(duplicates.count, 1)
        XCTAssertEqual(duplicates.first?.files.count, 2)
    }
    
    func testRemoveDuplicates() throws {
        // Create duplicate files
        let file1 = tempDirectory.appendingPathComponent("file1.txt")
        let file2 = tempDirectory.appendingPathComponent("file2.txt")
        
        let content = "Duplicate content".data(using: .utf8)!
        try content.write(to: file1)
        try content.write(to: file2)
        
        let duplicates = detector.findDuplicates(in: [tempDirectory])
        XCTAssertEqual(duplicates.count, 1)
        
        if let group = duplicates.first {
            let removed = try detector.removeDuplicates(in: group, keepFirst: true)
            XCTAssertEqual(removed, 1)
            
            // Verify first file still exists
            XCTAssertTrue(FileManager.default.fileExists(atPath: file1.path))
            // Verify second file was removed
            XCTAssertFalse(FileManager.default.fileExists(atPath: file2.path))
        }
    }
    
    func testDuplicateGroupWastedSpace() throws {
        let file1 = tempDirectory.appendingPathComponent("file1.txt")
        let file2 = tempDirectory.appendingPathComponent("file2.txt")
        let file3 = tempDirectory.appendingPathComponent("file3.txt")
        
        let content = "Content".data(using: .utf8)!
        try content.write(to: file1)
        try content.write(to: file2)
        try content.write(to: file3)
        
        let duplicates = detector.findDuplicates(in: [tempDirectory])
        
        if let group = duplicates.first {
            // 3 files, so 2 are wasted
            let expectedWaste = Int64(content.count) * 2
            XCTAssertEqual(group.totalWastedSpace, expectedWaste)
        }
    }
}
