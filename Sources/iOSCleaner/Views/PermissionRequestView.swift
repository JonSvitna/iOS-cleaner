import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// View for requesting necessary permissions
@available(iOS 15.0, *)
public struct PermissionRequestView: View {
    @StateObject private var permissionManager = PermissionManager()
    @State private var photoLibraryStatus: PermissionManager.PermissionStatus = .notDetermined
    @State private var isRequesting = false
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Permissions Required")
                            .font(.title2)
                            .bold()
                        
                        Text("iOS Cleaner needs certain permissions to provide you with the best cleaning and optimization experience.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Permission Cards
                    VStack(spacing: 16) {
                        PermissionCard(
                            request: PermissionRequest.photoLibraryRequest(),
                            status: photoLibraryStatus,
                            onRequest: requestPhotoLibraryPermission
                        )
                    }
                    .padding(.horizontal)
                    
                    // Continue Button
                    if allPermissionsGranted() {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Continue")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Skip Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Skip for Now")
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkPermissions()
            }
        }
    }
    
    private func checkPermissions() {
        photoLibraryStatus = permissionManager.checkPhotoLibraryPermission()
    }
    
    private func requestPhotoLibraryPermission() {
        isRequesting = true
        
        permissionManager.requestPhotoLibraryPermission { status in
            photoLibraryStatus = status
            isRequesting = false
        }
    }
    
    private func allPermissionsGranted() -> Bool {
        return photoLibraryStatus == .authorized
    }
}

@available(iOS 15.0, *)
struct PermissionCard: View {
    let request: PermissionRequest
    let status: PermissionManager.PermissionStatus
    let onRequest: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: request.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.title)
                        .font(.headline)
                    
                    Text(request.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack {
                StatusBadge(status: status)
                
                Spacer()
                
                if status == .notDetermined {
                    Button(action: onRequest) {
                        Text("Grant Access")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                } else if status == .denied {
                    Button(action: openSettings) {
                        Text("Open Settings")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func openSettings() {
        #if canImport(UIKit)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

@available(iOS 15.0, *)
struct StatusBadge: View {
    let status: PermissionManager.PermissionStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption)
            Text(statusText)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .foregroundColor(textColor)
        .cornerRadius(6)
    }
    
    private var iconName: String {
        switch status {
        case .authorized:
            return "checkmark.circle.fill"
        case .denied:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        case .restricted:
            return "lock.circle.fill"
        }
    }
    
    private var statusText: String {
        switch status {
        case .authorized:
            return "Granted"
        case .denied:
            return "Denied"
        case .notDetermined:
            return "Not Set"
        case .restricted:
            return "Restricted"
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .authorized:
            return Color.green.opacity(0.2)
        case .denied:
            return Color.red.opacity(0.2)
        case .notDetermined:
            return Color.gray.opacity(0.2)
        case .restricted:
            return Color.orange.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        switch status {
        case .authorized:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .gray
        case .restricted:
            return .orange
        }
    }
}
