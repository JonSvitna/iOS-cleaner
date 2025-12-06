# iOS Cleaner - Architecture Documentation

## Overview

iOS Cleaner is built with a modular, testable architecture following Swift best practices and MVVM pattern for the UI layer.

## Project Structure

```
iOSCleaner/
├── Sources/
│   └── iOSCleaner/
│       ├── App/
│       │   └── iOSCleanerApp.swift      # App entry point
│       ├── Views/
│       │   ├── ContentView.swift         # Main dashboard
│       │   ├── CleanerViewModel.swift    # UI coordination
│       │   ├── StorageDetailsView.swift  # Storage breakdown
│       │   └── DuplicatesView.swift      # Duplicate management
│       ├── StorageAnalyzer.swift         # Storage analysis
│       ├── DuplicateDetector.swift       # Duplicate detection
│       ├── CacheCleaner.swift            # Cache cleaning
│       └── iOSCleaner.swift              # Main coordinator
└── Tests/
    └── iOSCleanerTests/
        ├── StorageAnalyzerTests.swift
        ├── DuplicateDetectorTests.swift
        └── CacheCleanerTests.swift
```

## Core Components

### 1. StorageAnalyzer

**Purpose**: Analyzes file system storage usage

**Key Features**:
- Scans directories recursively
- Calculates file sizes and counts
- Categorizes files by location
- Formats byte sizes for display

**API**:
```swift
func analyzeStorage() -> [StorageInfo]
func analyzeDirectory(at: URL, category: String) -> StorageInfo
static func formatBytes(_ bytes: Int64) -> String
```

### 2. DuplicateDetector

**Purpose**: Identifies and manages duplicate files

**Algorithm**:
1. Scan directories for files
2. Compute SHA256 hash of file content
3. Group files by hash
4. Calculate wasted space
5. Provide safe removal

**Key Features**:
- Content-based duplicate detection (SHA256)
- Performance optimization (1MB limit for large files)
- Preserves originals when removing duplicates
- Calculates space savings

**API**:
```swift
func findDuplicates(in: [URL]) -> [DuplicateGroup]
func removeDuplicates(in: DuplicateGroup, keepFirst: Bool) throws -> Int
```

### 3. CacheCleaner

**Purpose**: Removes temporary and cached files

**Operations**:
- Clean temporary directory
- Clear cache directory
- Remove old, unused files
- Track cleaning results

**API**:
```swift
func cleanTemporaryFiles() throws -> CleaningResult
func cleanCaches() throws -> CleaningResult
func cleanOldFiles(in: URL, olderThanDays: Int) throws -> CleaningResult
func performFullCleanup() -> [CleaningResult]
```

### 4. iOSCleaner (Main Coordinator)

**Purpose**: Unifies all operations and provides high-level API

**Responsibilities**:
- Coordinates between modules
- Provides simplified interface
- Aggregates results
- Estimates savings

**API**:
```swift
func analyzeDevice() -> DeviceAnalysisResult
func findDuplicates() -> [DuplicateGroup]
func quickClean() -> CleanupSummary
func estimateSavings() -> SpaceSavingsEstimate
```

## UI Architecture (MVVM)

### Views
- **ContentView**: Main dashboard with storage overview
- **StorageDetailsView**: Detailed storage breakdown
- **DuplicatesView**: Duplicate file management

### ViewModel
- **CleanerViewModel**: Manages state and coordinates operations
  - Uses `@Published` properties for reactive updates
  - Performs operations on background threads
  - Updates UI on main thread

### Data Flow

```
User Action → View → ViewModel → Core Module → FileSystem
                ↓                      ↓
             Update ← Published State ← Result
```

## Design Patterns

### 1. Dependency Injection
All core modules are injected into the main coordinator:
```swift
public init() {
    self.storageAnalyzer = StorageAnalyzer()
    self.duplicateDetector = DuplicateDetector()
    self.cacheCleaner = CacheCleaner()
}
```

### 2. Result Types
Structured result types for all operations:
- `StorageInfo`
- `DuplicateGroup`
- `CleaningResult`
- `DeviceAnalysisResult`
- `CleanupSummary`
- `SpaceSavingsEstimate`

### 3. Error Handling
- Optional results for non-critical failures
- Throwing functions for critical operations
- Graceful degradation in UI

### 4. Concurrency
- Background processing for heavy operations
- Main thread updates for UI
- Async/await ready architecture

## Security Considerations

### Sandboxing
- Only accesses app's own directories
- Cannot access system files
- Cannot access other apps' data

### Safe Operations
- Always preserves at least one file when removing duplicates
- Validates file existence before deletion
- Error recovery for failed deletions

### Hashing
- Uses CryptoKit's SHA256 for secure, collision-resistant hashing
- Only hashes first 1MB of large files for performance

## Performance Optimizations

1. **Lazy Loading**: Files are only read when needed
2. **Batch Operations**: Multiple files processed in single pass
3. **Limited Hashing**: Large files only hash first 1MB
4. **Background Threading**: Heavy operations off main thread
5. **Resource Value Caching**: File attributes cached during enumeration

## Testing Strategy

### Unit Tests
- Core business logic tested independently
- File system operations use temporary directories
- Mock-friendly architecture

### Test Coverage
- Storage analysis operations
- Duplicate detection algorithm
- Cache cleaning functions
- Edge cases and error conditions

## Future Extensibility

The modular architecture allows for easy extension:

1. **New Cleaning Modules**: Implement same interface pattern
2. **Additional Views**: Add to Views/ directory
3. **Custom Analyzers**: Extend StorageAnalyzer
4. **Plugin System**: Core modules are decoupled

## Dependencies

### Standard Library
- Foundation (File system operations)
- SwiftUI (User interface)
- CryptoKit (SHA256 hashing)
- XCTest (Testing)

### No Third-Party Dependencies
The project intentionally avoids external dependencies for:
- Reduced attack surface
- Simplified maintenance
- Better control over behavior
- Easier auditing

## Build Configuration

### Swift Package Manager
- Minimum iOS version: 15.0
- Swift version: 5.9+
- No external dependencies

### Xcode Project (Optional)
Can be generated from Package.swift:
```bash
swift package generate-xcodeproj
```

## Deployment

### Requirements
- iOS 15.0+
- iPhone/iPad device or simulator
- Xcode 14.0+ for development

### Distribution
- TestFlight for beta testing
- App Store distribution
- Enterprise distribution

## Monitoring and Analytics

### Current Implementation
- Console logging for development
- Error messages for debugging

### Recommended Additions
- Analytics for usage patterns
- Crash reporting
- Performance monitoring
- User feedback collection

## Conclusion

The iOS Cleaner architecture is designed for:
- **Modularity**: Independent, testable components
- **Maintainability**: Clear separation of concerns
- **Safety**: Sandboxed operation with error handling
- **Performance**: Optimized file operations
- **Extensibility**: Easy to add new features