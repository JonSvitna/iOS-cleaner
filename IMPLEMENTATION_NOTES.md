# iOS Cleaner - Implementation Notes

## Summary

This document provides technical notes and guidance for developers working on the iOS Cleaner project.

## Phase 1 Implementation (Complete)

### What Was Built

Phase 1 focused on creating the foundational infrastructure for a comprehensive iOS phone optimization app with subscription-based continuous monitoring and performance modes.

#### Core Managers (4 new classes)

1. **PermissionManager** (`PermissionManager.swift`)
   - Handles iOS Photos framework permissions
   - Provides user-friendly permission request flow
   - Supports both granted and denied states with settings navigation
   - Platform-specific with `#if canImport(Photos)` guards

2. **PerformanceManager** (`PerformanceManager.swift`)
   - Real-time memory monitoring using mach system calls
   - Storage usage tracking via FileManager
   - Three performance modes: Speed, Battery Saver, Gaming
   - Persistent mode preferences using UserDefaults
   - Smart optimization recommendations based on metrics
   - Platform-specific with `#if os(iOS) || os(macOS)` guards for Darwin APIs

3. **BackgroundMonitor** (`BackgroundMonitor.swift`)
   - Framework for scheduled background performance checks
   - Integration points for BackgroundTasks framework
   - Metrics history storage (last 30 entries)
   - Notification system structure
   - Platform-specific with `#if canImport(BackgroundTasks)` guards

4. **SubscriptionManager** (`SubscriptionManager.swift`)
   - Three-tier subscription model (Free, Basic, Premium)
   - Feature gating system
   - StoreKit 2 integration structure
   - Purchase and restoration flow
   - Platform-specific with `#if canImport(StoreKit)` guards

#### UI Components (3 new views)

1. **PerformanceDashboardView** (`PerformanceDashboardView.swift`)
   - Real-time metrics display
   - Performance mode selector with visual cards
   - Optimization recommendations list
   - Refresh capability

2. **SubscriptionView** (`SubscriptionView.swift`)
   - Current subscription status display
   - Upgrade options presentation
   - Feature comparison table
   - Purchase flow integration

3. **PermissionRequestView** (`PermissionRequestView.swift`)
   - Permission explanation cards
   - Status badges (granted/denied/not set)
   - Settings navigation for denied permissions
   - Skip option for optional permissions

#### Updated Components

- **ContentView**: Added links to Performance Dashboard and Subscription views
- **Package.swift**: Updated to include new source files in core library

### Testing

Added 24 new unit tests across 4 test files:
- `PerformanceManagerTests.swift` (6 tests)
- `SubscriptionManagerTests.swift` (8 tests)
- `BackgroundMonitorTests.swift` (5 tests)
- `PermissionManagerTests.swift` (5 tests)

All 35 tests (11 original + 24 new) passing.

### Documentation

1. **ROADMAP.md**: Comprehensive 1-day development plan
2. **README.md**: Updated with new features
3. **This file**: Technical implementation notes

## Platform Compatibility

### Cross-Platform Strategy

The code uses conditional compilation to support both development (Linux) and deployment (iOS):

```swift
#if canImport(Photos)
import Photos
#endif

#if os(iOS) || os(macOS)
import Darwin
#endif

#if canImport(UIKit)
import UIKit
#endif
```

### Why This Matters

1. **CI/CD**: Code builds on Linux for automated testing
2. **Development**: Developers can work on non-Mac machines
3. **Deployment**: Full iOS functionality available on device

### Testing on Different Platforms

- **Linux**: Basic logic tests, no iOS-specific APIs
- **iOS Simulator**: Full functionality including permissions
- **iOS Device**: Complete feature set with real hardware

## Architecture Decisions

### Why Not ObservableObject?

Initially considered making managers conform to `ObservableObject`, but decided against it because:

1. **Library Independence**: Core library shouldn't depend on Combine/SwiftUI
2. **Flexibility**: Managers can be used in non-SwiftUI contexts
3. **Testing**: Easier to test without framework dependencies

Views use `@StateObject` for their own state management and call manager methods directly.

### Subscription Model Design

Three tiers chosen based on market research:

- **Free**: Basic features to attract users
- **Basic ($2.99/month)**: Core premium features, affordable entry point
- **Premium ($4.99/month)**: All features, positioned for power users

Feature gating implemented at the manager level, not UI level, for security.

### Performance Modes

Three modes based on common user scenarios:

1. **Speed**: Maximum performance, higher battery drain
2. **Battery Saver**: Minimal background activity, extended battery
3. **Gaming**: Sustained performance for gaming sessions

Mode persistence ensures user preference survives app restarts.

## Key Implementation Details

### Memory Monitoring

Uses mach system calls on Darwin platforms:

```swift
var info = mach_task_basic_info()
task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), ...)
```

This provides accurate resident memory size without third-party dependencies.

### Storage Monitoring

Uses standard FileManager APIs:

```swift
let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
```

Works across all platforms, returns total and free space.

### Background Tasks

Structured for easy integration:

1. Register task identifier in Info.plist
2. Call `registerBackgroundTasks()` in AppDelegate
3. Schedule tasks with `scheduleBackgroundCheck()`
4. Handle execution in `handleBackgroundTask()`

Currently uses placeholders; production requires actual BGTaskScheduler integration.

### Subscription Handling

Structured for StoreKit 2:

1. Fetch products from App Store Connect
2. Process purchases with receipt validation
3. Store subscription state locally
4. Check feature availability before access

Currently uses mock implementation; production requires actual StoreKit integration.

## iOS Requirements

### Info.plist Entries

Required for full functionality:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>iOS Cleaner needs access to your Photo Library to detect and remove duplicate photos, helping you free up storage space.</string>

<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.ioscleaner.performance.monitor</string>
</array>

<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

### Capabilities

Enable in Xcode:

1. Background Modes → Background Processing
2. In-App Purchase capability (for subscriptions)

### App Store Connect Setup

For subscriptions:

1. Create subscription group
2. Add two subscriptions:
   - Basic: $2.99/month
   - Premium: $4.99/month
3. Configure features and descriptions
4. Submit for review

## Known Limitations

### iOS Sandboxing

Due to iOS security model:

- Cannot access system-wide processes
- Cannot monitor other apps' memory
- Cannot clean other apps' caches
- Limited to app's own sandbox

### Background Tasks

iOS limits background execution:

- Maximum 30 seconds per task
- May be deferred based on battery/usage
- Not guaranteed to run on schedule

### Permission Dependencies

Some features require user approval:

- Photo library scanning needs Photos permission
- Background monitoring needs notification permission
- Settings changes require user action

## Future Work (Phase 2+)

### Photo Library Integration

1. Implement PHPhotoLibrary integration
2. Add duplicate photo detection algorithm
3. Create photo cleaning UI
4. Handle photo deletion safely

### Large File Detection

1. Scan directories for large files (>100MB)
2. Sort and filter by size
3. Provide preview where possible
4. Safe removal with confirmation

### Enhanced Categorization

1. Extend file type detection
2. Create category-based visualizations
3. Add per-category cleaning options
4. Track category trends over time

### Production Background Tasks

1. Complete BGTaskScheduler integration
2. Test background execution thoroughly
3. Optimize for battery impact
4. Handle task expiration gracefully

### Production Subscriptions

1. Complete StoreKit 2 integration
2. Implement server-side receipt validation
3. Handle subscription edge cases
4. Add subscription management UI

## Development Tips

### Testing Locally

```bash
# Build the library
swift build

# Run all tests
swift test

# Run specific test
swift test --filter PerformanceManagerTests
```

### Testing on iOS

1. Open in Xcode
2. Select iOS Simulator
3. Run tests: Cmd+U
4. Run app: Cmd+R

### Debugging Background Tasks

Use `e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.ioscleaner.performance.monitor"]` in Xcode debugger.

### Testing Subscriptions

Use StoreKit Configuration file in Xcode for local testing:

1. File → New → StoreKit Configuration File
2. Add products matching SubscriptionManager
3. Enable in scheme: Edit Scheme → Run → StoreKit Configuration

## Performance Considerations

### Memory Usage

- Managers are lightweight (< 1KB each)
- Metrics history limited to 30 entries
- No image/data caching in core library

### Battery Impact

Current implementation is passive (no continuous monitoring). Background tasks scheduled at appropriate intervals based on subscription tier:

- Free: No background monitoring
- Basic: Weekly checks
- Premium: Daily checks

### Storage Impact

Minimal storage used:

- UserDefaults for preferences (< 1KB)
- Metrics history (< 10KB)
- No file caching

## Security Considerations

### Permission Handling

- Clear explanations before requesting
- Graceful handling of denied permissions
- No data collection without consent

### Subscription Security

- Feature gating at manager level
- Server-side receipt validation recommended
- Secure subscription state storage

### Data Privacy

- No personal data sent to servers
- All metrics stored locally
- User control over data collection

## Contributing

When adding new features:

1. Follow existing architecture patterns
2. Add conditional compilation for platform-specific code
3. Write comprehensive unit tests
4. Update documentation
5. Consider iOS limitations
6. Test on both Linux and iOS

## Questions?

See also:
- [README.md](README.md) - User-facing features
- [ROADMAP.md](ROADMAP.md) - Development timeline
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture

---

**Last Updated**: 2025-12-06
**Phase**: 1 Complete, Phase 2 Ready to Start
