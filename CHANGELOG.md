# Changelog

All notable changes to the iOS Cleaner project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial iOS Cleaner application implementation
- Storage analysis functionality
  - Categorized storage breakdown (Documents, Caches, Temporary Files)
  - File count tracking
  - Human-readable size formatting
- Duplicate file detection
  - Content-based duplicate detection using SHA256 hashing
  - Duplicate groups sorted by wasted space
  - Safe removal keeping at least one copy
  - Performance optimization for large files
- Cache cleaning operations
  - Quick clean for temporary files and caches
  - Old files cleanup with configurable age threshold
  - Detailed cleaning results tracking
- SwiftUI user interface
  - Main dashboard with storage overview
  - Storage details view with category breakdown
  - Duplicates management interface
  - Modern card-based design
- MVVM architecture with CleanerViewModel
- Comprehensive unit tests
  - StorageAnalyzer tests
  - DuplicateDetector tests
  - CacheCleaner tests
  - All tests passing
- Documentation
  - Comprehensive README
  - Architecture documentation
  - Xcode setup guide
  - Feature documentation
  - Contributing guidelines
  - MIT License
- Swift Package Manager support
- Cross-platform core (iOS and macOS)
- .gitignore for Xcode and Swift projects

### Technical Details
- Swift 5.9+ support
- iOS 15.0+ target
- No external dependencies
- Uses Foundation, SwiftUI, and CryptoKit (iOS only)
- Modular, testable architecture
- Background processing for heavy operations
- Error handling and recovery
- iOS sandboxing compliant

### Safety Features
- Only accesses app sandbox directories
- Always preserves at least one file when removing duplicates
- User confirmation for destructive operations
- Graceful error handling
- No system file access (by design)

## [1.0.0] - TBD

Initial release planned features:
- Storage analysis
- Duplicate detection
- Cache cleaning
- SwiftUI interface
- iOS 15.0+ support

---

## Future Versions

### Planned for 1.1.0
- Photo library duplicate detection
- Large file finder
- More granular cache control

### Planned for 1.2.0
- Storage usage trends
- Scheduled automatic cleaning
- Export cleaning reports

### Planned for 2.0.0
- Widget support
- Shortcuts integration
- Advanced filtering options
- Localization support

---

## Version History

- **Unreleased**: Initial implementation
- **1.0.0**: TBD - First public release
