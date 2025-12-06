import XCTest
@testable import iOSCleanerCore

final class StorageAnalyzerTests: XCTestCase {
    
    var analyzer: StorageAnalyzer!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        analyzer = StorageAnalyzer()
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: tempDirectory)
    }
    
    func testAnalyzeEmptyDirectory() {
        let result = analyzer.analyzeDirectory(at: tempDirectory, category: "Test")
        
        XCTAssertEqual(result.category, "Test")
        XCTAssertEqual(result.size, 0)
        XCTAssertEqual(result.fileCount, 0)
    }
    
    func testAnalyzeDirectoryWithFiles() throws {
        // Create test files
        let file1 = tempDirectory.appendingPathComponent("test1.txt")
        let file2 = tempDirectory.appendingPathComponent("test2.txt")
        
        let data1 = "Hello World".data(using: .utf8)!
        let data2 = "Test Data".data(using: .utf8)!
        
        try data1.write(to: file1)
        try data2.write(to: file2)
        
        let result = analyzer.analyzeDirectory(at: tempDirectory, category: "Test")
        
        XCTAssertEqual(result.category, "Test")
        XCTAssertEqual(result.fileCount, 2)
        XCTAssertGreaterThan(result.size, 0)
    }
    
    func testFormatBytes() {
        let zeroBytes = StorageAnalyzer.formatBytes(0)
        XCTAssertTrue(zeroBytes.contains("0") || zeroBytes.lowercased().contains("zero"))
        XCTAssertTrue(StorageAnalyzer.formatBytes(1024).contains("KB"))
        XCTAssertTrue(StorageAnalyzer.formatBytes(1024 * 1024).contains("MB"))
    }
    
    func testAnalyzeStorage() {
        let results = analyzer.analyzeStorage()
        
        // Should have at least some results (temp, caches, documents)
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.contains { $0.category == "Temporary Files" })
    }
}
