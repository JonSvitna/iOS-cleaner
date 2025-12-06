# Quick Start Guide

Get started with iOS Cleaner development in 5 minutes!

## Prerequisites

- macOS 12.0+ (for iOS development)
- Xcode 14.0+
- Basic Swift knowledge

## Quick Setup

### 1. Clone the Repository

```bash
git clone https://github.com/JonSvitna/iOS-cleaner.git
cd iOS-cleaner
```

### 2. Test the Core Modules

```bash
# Build the project
swift build

# Run tests
swift test
```

You should see output like:
```
Build complete! (0.75s)
Test Suite 'All tests' passed
Executed 11 tests, with 0 failures
```

### 3. Open in Xcode

```bash
# Option 1: Open the entire directory
open .

# Option 2: Generate Xcode project
swift package generate-xcodeproj
open iOS-cleaner.xcodeproj
```

### 4. Build the iOS App

Since this is a Swift Package, you need to create an iOS app target:

1. In Xcode: File → New → Target
2. Choose "iOS" → "App"
3. Add all files from `Sources/iOSCleaner` to the target
4. Build and run!

For detailed instructions, see [XCODE_SETUP.md](XCODE_SETUP.md).

## Project Structure

```
iOS-cleaner/
├── Sources/iOSCleaner/          # Source code
│   ├── App/                     # App entry point
│   ├── Views/                   # SwiftUI views
│   ├── StorageAnalyzer.swift    # Storage analysis
│   ├── DuplicateDetector.swift  # Duplicate detection
│   ├── CacheCleaner.swift       # Cache cleaning
│   └── iOSCleaner.swift         # Main coordinator
├── Tests/                       # Unit tests
├── Package.swift                # Swift Package manifest
└── README.md                    # Main documentation
```

## Quick Usage Examples

### Example 1: Analyze Storage

```swift
import iOSCleanerCore

let analyzer = StorageAnalyzer()
let results = analyzer.analyzeStorage()

for info in results {
    print("\(info.category): \(StorageAnalyzer.formatBytes(info.size))")
    print("Files: \(info.fileCount)")
}
```

### Example 2: Find Duplicates

```swift
import iOSCleanerCore

let detector = DuplicateDetector()
let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let duplicates = detector.findDuplicates(in: [documentsURL])

for group in duplicates {
    print("Found \(group.files.count) duplicates")
    print("Wasting \(StorageAnalyzer.formatBytes(group.totalWastedSpace))")
}
```

### Example 3: Clean Caches

```swift
import iOSCleanerCore

let cleaner = CacheCleaner()
let results = cleaner.performFullCleanup()

for result in results {
    print("\(result.category): removed \(result.itemsRemoved) items")
    print("Freed \(StorageAnalyzer.formatBytes(result.spaceFreed))")
}
```

### Example 4: Use the Main Coordinator

```swift
import iOSCleanerCore

let cleaner = iOSCleaner()

// Analyze device
let analysis = cleaner.analyzeDevice()
print("Total size: \(StorageAnalyzer.formatBytes(analysis.totalSize))")

// Quick clean
let summary = cleaner.quickClean()
print("Cleaned \(summary.totalItemsRemoved) items")

// Estimate savings
let estimate = cleaner.estimateSavings()
print("Can save: \(StorageAnalyzer.formatBytes(estimate.totalPotentialSavings))")
```

## Running Tests

```bash
# Run all tests
swift test

# Run specific test
swift test --filter StorageAnalyzerTests

# Run tests with verbose output
swift test --verbose
```

## Building for iOS

Since we're in a Linux environment (for CI), the SwiftUI views won't compile. To build the full iOS app:

1. Open project on macOS
2. Use Xcode to build
3. Select iOS simulator or device
4. Press Cmd+R

See [XCODE_SETUP.md](XCODE_SETUP.md) for detailed instructions.

## Common Tasks

### Add a New Feature

1. Create feature in appropriate module
2. Add unit tests
3. Update UI if needed
4. Update documentation

### Run Linter (Optional)

```bash
# Install SwiftLint
brew install swiftlint

# Run linter
swiftlint
```

### Format Code

```bash
# Install swift-format
brew install swift-format

# Format all Swift files
swift-format -i -r Sources/ Tests/
```

## Troubleshooting

### "No such module 'SwiftUI'"

This is expected on Linux. SwiftUI is only available on macOS/iOS. The core modules (without UI) will build fine.

### "No such module 'CryptoKit'"

This is expected on Linux. The code has fallback for platforms without CryptoKit.

### Tests Failing

Make sure you're running from the project root:
```bash
cd /path/to/iOS-cleaner
swift test
```

## Next Steps

1. Read [FEATURES.md](FEATURES.md) to understand all features
2. Check [ARCHITECTURE.md](ARCHITECTURE.md) for design details
3. See [CONTRIBUTING.md](CONTRIBUTING.md) to contribute
4. Review [XCODE_SETUP.md](XCODE_SETUP.md) for iOS development

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/JonSvitna/iOS-cleaner/issues)
- **Discussions**: [GitHub Discussions](https://github.com/JonSvitna/iOS-cleaner/discussions)
- **Documentation**: See all `.md` files in the repository

## Resources

- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [iOS File System Guide](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/)

Happy coding! 🚀
