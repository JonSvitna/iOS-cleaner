import XCTest
@testable import iOSCleanerCore

final class PermissionManagerTests: XCTestCase {
    var permissionManager: PermissionManager!
    
    override func setUp() {
        super.setUp()
        permissionManager = PermissionManager()
    }
    
    override func tearDown() {
        permissionManager = nil
        super.tearDown()
    }
    
    func testPermissionStatus() {
        // Test that we can check status without crashing
        let status = permissionManager.checkPhotoLibraryPermission()
        
        // Should return a valid status
        XCTAssertTrue(
            status == .authorized ||
            status == .denied ||
            status == .notDetermined ||
            status == .restricted
        )
    }
    
    func testPermissionDescription() {
        // Test that descriptions are provided
        let photoDescription = permissionManager.permissionDescription(for: .photoLibrary)
        XCTAssertFalse(photoDescription.isEmpty)
        
        let filesDescription = permissionManager.permissionDescription(for: .files)
        XCTAssertFalse(filesDescription.isEmpty)
    }
    
    func testHasRequiredPermissions() {
        // Should return true since photo library is optional
        XCTAssertTrue(permissionManager.hasRequiredPermissions())
    }
    
    func testPendingPermissions() {
        let pending = permissionManager.pendingPermissions()
        
        // Should return an array (may be empty)
        XCTAssertNotNil(pending)
    }
    
    func testPermissionRequest() {
        let request = PermissionRequest.photoLibraryRequest()
        
        XCTAssertEqual(request.type, .photoLibrary)
        XCTAssertFalse(request.title.isEmpty)
        XCTAssertFalse(request.description.isEmpty)
        XCTAssertFalse(request.icon.isEmpty)
    }
}
