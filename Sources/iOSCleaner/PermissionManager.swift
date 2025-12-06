import Foundation
#if canImport(Photos)
import Photos
#endif

/// Manages permissions required for iOS Cleaner functionality
@available(iOS 15.0, *)
public class PermissionManager {
    
    /// Permission types that the app may need
    public enum PermissionType {
        case photoLibrary
        case files
    }
    
    /// Permission status
    public enum PermissionStatus {
        case authorized
        case denied
        case notDetermined
        case restricted
    }
    
    public init() {}
    
    /// Check photo library permission status
    public func checkPhotoLibraryPermission() -> PermissionStatus {
        #if canImport(Photos)
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        @unknown default:
            return .notDetermined
        }
        #else
        return .notDetermined
        #endif
    }
    
    /// Request photo library permission
    public func requestPhotoLibraryPermission(completion: @escaping (PermissionStatus) -> Void) {
        #if canImport(Photos)
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    completion(.authorized)
                case .denied:
                    completion(.denied)
                case .restricted:
                    completion(.restricted)
                case .notDetermined:
                    completion(.notDetermined)
                @unknown default:
                    completion(.notDetermined)
                }
            }
        }
        #else
        DispatchQueue.main.async {
            completion(.notDetermined)
        }
        #endif
    }
    
    /// Get user-friendly permission description
    public func permissionDescription(for type: PermissionType) -> String {
        switch type {
        case .photoLibrary:
            return "iOS Cleaner needs access to your Photo Library to detect and remove duplicate photos, helping you free up valuable storage space."
        case .files:
            return "iOS Cleaner needs access to your files to analyze storage usage and safely clean temporary files and caches."
        }
    }
    
    /// Check if all required permissions are granted
    public func hasRequiredPermissions() -> Bool {
        // For basic functionality, we don't require all permissions
        // Photo library is optional for enhanced features
        return true
    }
    
    /// Get list of permissions that need to be requested
    public func pendingPermissions() -> [PermissionType] {
        var pending: [PermissionType] = []
        
        if checkPhotoLibraryPermission() == .notDetermined {
            pending.append(.photoLibrary)
        }
        
        return pending
    }
}

/// Permission request information
public struct PermissionRequest {
    public let type: PermissionManager.PermissionType
    public let title: String
    public let description: String
    public let icon: String
    
    public init(type: PermissionManager.PermissionType, title: String, description: String, icon: String) {
        self.type = type
        self.title = title
        self.description = description
        self.icon = icon
    }
    
    public static func photoLibraryRequest() -> PermissionRequest {
        return PermissionRequest(
            type: .photoLibrary,
            title: "Photo Library Access",
            description: "Detect and remove duplicate photos to free up storage space",
            icon: "photo.on.rectangle.angled"
        )
    }
}
