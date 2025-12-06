# iOS Cleaner

A native iOS application for optimizing iPhone storage by cleaning system files, detecting duplicates, and removing unnecessary cached data.

## Features

### 🗂️ Storage Analysis
- Comprehensive analysis of device storage usage
- Breakdown by file categories (Documents, Caches, Temporary Files)
- Real-time storage statistics and file counts

### 🔍 Duplicate Detection
- SHA256-based duplicate file detection
- Identifies duplicate images, documents, and other files
- Shows potential space savings
- Safe removal of duplicate files while preserving originals

### 🧹 Smart Cleaning
- **Quick Clean**: One-tap cleaning of temporary files and caches
- **Cache Management**: Clear app caches that accumulate over time
- **Old Files Cleanup**: Remove files that haven't been accessed in a specified period
- **Safe Operation**: Only removes hidden system files that won't damage iOS

### 📊 Visual Interface
- Modern SwiftUI interface
- Real-time progress updates
- Detailed storage breakdown
- Clear visualization of potential savings

## Architecture

The app is built with a modular architecture using Swift and SwiftUI:

### Core Modules

1. **StorageAnalyzer** (`StorageAnalyzer.swift`)
   - Analyzes disk usage across different directories
   - Provides detailed storage information
   - Formats file sizes in human-readable format

2. **DuplicateDetector** (`DuplicateDetector.swift`)
   - Uses SHA256 hashing for accurate duplicate detection
   - Groups duplicate files by content hash
   - Calculates wasted space from duplicates
   - Safe removal of duplicate files

3. **CacheCleaner** (`CacheCleaner.swift`)
   - Cleans temporary files
   - Removes cached data
   - Cleans old, unused files
   - Provides detailed cleaning results

4. **iOSCleaner** (`iOSCleaner.swift`)
   - Main coordinator class
   - Combines all cleaning operations
   - Provides unified API for the UI

### User Interface

- **ContentView**: Main dashboard showing storage overview and quick actions
- **StorageDetailsView**: Detailed breakdown of storage usage by category
- **DuplicatesView**: Interface for managing and removing duplicate files
- **CleanerViewModel**: SwiftUI view model coordinating operations

## Technology Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Platform**: iOS 15.0+
- **Architecture**: MVVM (Model-View-ViewModel)
- **Testing**: XCTest
- **Security**: CryptoKit for file hashing
- **Package Manager**: Swift Package Manager

## Open Source Approach

This project uses open-source approaches and patterns:

1. **File System Analysis**: Standard FileManager APIs
2. **Hash-based Duplicate Detection**: Industry-standard SHA256 hashing
3. **Safe Cleaning**: Only removes files in sandboxed directories (caches, temp files)
4. **Modular Design**: Each component can be used independently or replaced

## Building and Running

### Requirements
- Xcode 14.0 or later
- iOS 15.0+ deployment target
- macOS for development

### Build with Swift Package Manager
```bash
# Build the package
swift build

# Run tests
swift test
```

### Build with Xcode
1. Open the project in Xcode
2. Select your target device or simulator
3. Press Cmd+R to build and run

## Testing

The project includes comprehensive unit tests:

```bash
swift test
```

Test coverage includes:
- Storage analysis functionality
- Duplicate detection algorithms
- Cache cleaning operations
- File removal safety

## Safety Features

- **Sandboxed Operation**: Only accesses app's own directories
- **Safe Deletion**: Preserves at least one copy of duplicate files
- **Error Handling**: Graceful handling of file system errors
- **User Confirmation**: Requires user action for destructive operations

## Usage

1. **Launch the app** to see your storage overview
2. **Quick Clean** to immediately free up space from caches and temp files
3. **Find Duplicates** to identify and remove duplicate files
4. **Storage Analysis** for detailed breakdown of space usage

## Limitations

Due to iOS sandboxing:
- The app can only access its own sandbox directories
- Cannot access system files or other apps' data
- Limited to user-accessible documents, caches, and temporary files
- Cannot modify iOS system directories (by design for security)

## Future Enhancements

Potential improvements:
- Photo library duplicate detection (with user permission)
- Large file identification
- Storage usage trends over time
- Scheduled automatic cleaning
- Export cleaning reports
- More granular cache control

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit issues, fork the repository, and create pull requests.

## Acknowledgments

Built using Swift and SwiftUI with industry-standard algorithms for file analysis and duplicate detection.
