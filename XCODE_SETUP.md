# Xcode Project Setup Guide

This guide explains how to set up and build the iOS Cleaner app in Xcode on macOS.

## Prerequisites

- **macOS**: 12.0 (Monterey) or later
- **Xcode**: 14.0 or later
- **iOS Simulator or Device**: iOS 15.0 or later

## Option 1: Using Swift Package Manager

The project includes a `Package.swift` file that defines the core modules. However, to build the complete iOS app with the UI, you'll need to create an Xcode project.

### Step 1: Create New Xcode Project

1. Open Xcode
2. Select "Create a new Xcode project"
3. Choose "iOS" → "App"
4. Fill in the details:
   - **Product Name**: iOS Cleaner
   - **Team**: Select your development team
   - **Organization Identifier**: com.yourcompany
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None (we'll use our custom implementation)
5. Save the project in a separate directory (not in this repository)

### Step 2: Add Source Files

1. In Xcode, right-click on the project navigator
2. Select "Add Files to 'iOS Cleaner'..."
3. Navigate to this repository's `Sources/iOSCleaner` directory
4. Select all `.swift` files and add them (make sure "Copy items if needed" is unchecked if you want to keep them in the repo)

### Step 3: Configure Build Settings

1. Select your project in the navigator
2. Under "Targets" → "iOS Cleaner" → "General":
   - Set **Minimum Deployments** to iOS 15.0
3. Under "Build Settings":
   - Ensure **Swift Language Version** is set to Swift 5

### Step 4: Update App Entry Point

Replace the default `@main` app struct with the one from `Sources/iOSCleaner/App/iOSCleanerApp.swift`

### Step 5: Build and Run

1. Select a simulator or connected device
2. Press Cmd+R to build and run
3. The app should launch with the main dashboard

## Option 2: Generate Xcode Project from Package

If you prefer to generate an Xcode project directly from the Swift Package:

```bash
cd /path/to/iOS-cleaner
swift package generate-xcodeproj
```

Then open the generated `.xcodeproj` file. Note: This approach may require additional configuration for the SwiftUI app target.

## Option 3: Using Xcode with Swift Package

1. Open Xcode
2. Select "Open" and choose the entire iOS-cleaner folder
3. Xcode will recognize it as a Swift Package
4. To create an app target:
   - Click on the package in the navigator
   - Select "Add Target" → "iOS" → "App"
   - Configure as described in Option 1

## Project Structure in Xcode

Once set up, your project should look like this:

```
iOS Cleaner
├── App
│   └── iOSCleanerApp.swift (Main app entry point)
├── Views
│   ├── ContentView.swift (Main dashboard)
│   ├── CleanerViewModel.swift (View model)
│   ├── StorageDetailsView.swift (Storage details)
│   └── DuplicatesView.swift (Duplicates view)
├── Core Modules
│   ├── StorageAnalyzer.swift
│   ├── DuplicateDetector.swift
│   ├── CacheCleaner.swift
│   └── iOSCleaner.swift (Main coordinator)
├── Tests
│   └── iOSCleanerTests
└── Assets.xcassets
```

## Required Capabilities

The app requires the following capabilities in your project:

1. **File System Access**: Automatically available within the app sandbox
2. **No special entitlements needed**: The app only accesses its own sandbox

## Info.plist Configuration

No special permissions are required in Info.plist since the app only accesses its own sandbox directories.

## Building for Release

1. Select "Any iOS Device (arm64)" as the build destination
2. Product → Archive
3. Follow the App Store distribution process
4. Or use TestFlight for beta testing

## Troubleshooting

### "No such module 'SwiftUI'" Error

- Ensure you're building for iOS target (not macOS or Linux)
- Check that the deployment target is iOS 15.0 or later

### Build Errors in Views

- Make sure all View files are included in the app target
- Check that SwiftUI is properly imported

### Test Failures

- Tests are designed for the core modules only
- Run tests from the Test navigator (Cmd+U)

## Running Tests in Xcode

1. Open the Test navigator (Cmd+6)
2. Click the play button next to "iOSCleanerTests"
3. All tests should pass

## Simulator Testing

The app works best when tested on a real device, but you can use the simulator:

1. Select an iPhone simulator (iOS 15.0+)
2. Build and run
3. Note: Actual space cleaning is limited in simulator

## Device Testing

For full functionality testing:

1. Connect an iPhone or iPad (iOS 15.0+)
2. Select it as the build destination
3. Trust your developer account on the device
4. Build and run

The app will have limited access on a real device due to iOS sandboxing, which is intentional for security.

## Next Steps

After setup:

1. Customize the UI in the Views directory
2. Add app icon in Assets.xcassets
3. Configure launch screen
4. Add localization if needed
5. Implement additional features

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [iOS File System Guide](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/)
- [Swift Package Manager Guide](https://swift.org/package-manager/)
