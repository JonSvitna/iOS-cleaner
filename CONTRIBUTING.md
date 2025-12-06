# Contributing to iOS Cleaner

Thank you for your interest in contributing to iOS Cleaner! This document provides guidelines and information for contributors.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/iOS-cleaner.git
   cd iOS-cleaner
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Requirements

- macOS 12.0+ (for iOS development)
- Xcode 14.0+
- Swift 5.9+
- iOS 15.0+ SDK

### Building the Project

```bash
# Build the core modules
swift build

# Run tests
swift test
```

For full iOS app development, see [XCODE_SETUP.md](XCODE_SETUP.md).

## Code Style

### Swift Style Guidelines

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use clear, descriptive names for variables and functions
- Add documentation comments for public APIs
- Keep functions focused and single-purpose

### Example:

```swift
/// Analyzes storage usage for a specific directory
/// - Parameters:
///   - url: The directory URL to analyze
///   - category: The category name for this directory
/// - Returns: StorageInfo containing size and file count
public func analyzeDirectory(at url: URL, category: String) -> StorageInfo {
    // Implementation
}
```

## Testing

- Write tests for all new functionality
- Ensure all existing tests pass before submitting PR
- Test coverage should be maintained or improved
- Use descriptive test names that explain what is being tested

### Running Tests

```bash
swift test
```

### Writing Tests

Tests should be in the `Tests/iOSCleanerTests/` directory:

```swift
import XCTest
@testable import iOSCleanerCore

final class YourFeatureTests: XCTestCase {
    func testYourFeature() {
        // Test implementation
    }
}
```

## Making Changes

### Core Modules

Located in `Sources/iOSCleaner/`:

- **StorageAnalyzer.swift**: Storage analysis functionality
- **DuplicateDetector.swift**: Duplicate file detection
- **CacheCleaner.swift**: Cache cleaning operations
- **iOSCleaner.swift**: Main coordinator

### UI Components

Located in `Sources/iOSCleaner/Views/`:

- **ContentView.swift**: Main dashboard
- **CleanerViewModel.swift**: UI state management
- **StorageDetailsView.swift**: Storage details screen
- **DuplicatesView.swift**: Duplicates management screen

### Adding New Features

1. Create feature in appropriate module
2. Add unit tests
3. Update UI if needed
4. Update documentation
5. Add to CHANGELOG.md

## Submitting Changes

### Before Submitting

1. **Run tests**: Ensure all tests pass
   ```bash
   swift test
   ```

2. **Build successfully**: Ensure the project builds
   ```bash
   swift build
   ```

3. **Update documentation**: If you've changed APIs or added features

4. **Write good commit messages**:
   ```
   Add feature: Brief description
   
   Longer explanation of what changed and why.
   Fixes #123
   ```

### Pull Request Process

1. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open a Pull Request** on GitHub

3. **Fill in the PR template** with:
   - Description of changes
   - Related issues
   - Testing done
   - Screenshots (if UI changes)

4. **Wait for review**: Maintainers will review your PR

5. **Address feedback**: Make requested changes if needed

6. **Merge**: Once approved, your PR will be merged

## Areas for Contribution

### High Priority

- [ ] Photo library duplicate detection
- [ ] Large file identification
- [ ] Storage usage trends over time
- [ ] Scheduled automatic cleaning
- [ ] Export cleaning reports

### Medium Priority

- [ ] More granular cache control
- [ ] Additional file type support
- [ ] Performance optimizations
- [ ] Accessibility improvements
- [ ] Localization support

### Documentation

- [ ] Tutorial videos
- [ ] More code examples
- [ ] API documentation
- [ ] User guide
- [ ] Developer guide

## Bug Reports

When reporting bugs, please include:

1. **Description**: Clear description of the bug
2. **Steps to Reproduce**: How to reproduce the issue
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Environment**: iOS version, device model, app version
6. **Screenshots**: If applicable
7. **Logs**: Any relevant console output

### Bug Report Template

```markdown
## Bug Description
[Clear description]

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- iOS Version: 15.0
- Device: iPhone 12
- App Version: 1.0.0

## Screenshots
[If applicable]

## Additional Context
[Any other relevant information]
```

## Feature Requests

For feature requests, please include:

1. **Use Case**: Why is this feature needed?
2. **Proposed Solution**: How should it work?
3. **Alternatives**: Other approaches considered?
4. **Additional Context**: Any other relevant details?

## Code Review Process

1. At least one maintainer must approve
2. All tests must pass
3. Code must follow style guidelines
4. Documentation must be updated
5. No merge conflicts

## Community Guidelines

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Follow the code of conduct

## Questions?

- Open an issue for discussion
- Check existing issues and PRs
- Review documentation
- Ask in pull request comments

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- CHANGELOG.md

Thank you for contributing to iOS Cleaner!
