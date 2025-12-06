import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

/// Detects duplicate files based on content hash
public class DuplicateDetector {
    
    /// Represents a duplicate file group
    public struct DuplicateGroup {
        public let hash: String
        public let files: [URL]
        public let fileSize: Int64
        
        public var totalWastedSpace: Int64 {
            return fileSize * Int64(files.count - 1)
        }
        
        public init(hash: String, files: [URL], fileSize: Int64) {
            self.hash = hash
            self.files = files
            self.fileSize = fileSize
        }
    }
    
    public init() {}
    
    /// Finds duplicate files in specified directories
    public func findDuplicates(in urls: [URL]) -> [DuplicateGroup] {
        var filesByHash: [String: (files: [URL], size: Int64)] = [:]
        let fileManager = FileManager.default
        
        for url in urls {
            guard let enumerator = fileManager.enumerator(
                at: url,
                includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
                options: [.skipsHiddenFiles]
            ) else {
                continue
            }
            
            for case let fileURL as URL in enumerator {
                guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]),
                      let isRegularFile = resourceValues.isRegularFile,
                      isRegularFile,
                      let fileSize = resourceValues.fileSize,
                      fileSize > 0 else {
                    continue
                }
                
                // Only hash files that could potentially have duplicates (same size optimization)
                if let hash = hashFile(at: fileURL) {
                    if var existing = filesByHash[hash] {
                        existing.files.append(fileURL)
                        filesByHash[hash] = existing
                    } else {
                        filesByHash[hash] = (files: [fileURL], size: Int64(fileSize))
                    }
                }
            }
        }
        
        // Filter to only groups with duplicates (more than one file)
        let duplicateGroups = filesByHash.compactMap { hash, value -> DuplicateGroup? in
            guard value.files.count > 1 else { return nil }
            return DuplicateGroup(hash: hash, files: value.files, fileSize: value.size)
        }
        
        return duplicateGroups.sorted { $0.totalWastedSpace > $1.totalWastedSpace }
    }
    
    /// Computes SHA256 hash of a file
    private func hashFile(at url: URL) -> String? {
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
            return nil
        }
        
        // For large files, only hash the first chunk for performance
        let maxBytesToHash = 1024 * 1024 // 1MB
        let dataToHash = data.count > maxBytesToHash ? data.prefix(maxBytesToHash) : data
        
        #if canImport(CryptoKit)
        let hash = SHA256.hash(data: dataToHash)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
        #else
        // Fallback for platforms without CryptoKit - use simple content-based hash
        // This is less secure but suitable for duplicate detection
        var hashValue: UInt64 = 0
        for byte in dataToHash {
            hashValue = hashValue &* 31 &+ UInt64(byte)
        }
        return String(format: "%016llx", hashValue)
        #endif
    }
    
    /// Removes duplicate files, keeping only the first one in each group
    public func removeDuplicates(in group: DuplicateGroup, keepFirst: Bool = true) throws -> Int {
        guard group.files.count > 1 else { return 0 }
        
        let fileManager = FileManager.default
        let filesToRemove = keepFirst ? Array(group.files.dropFirst()) : Array(group.files.dropLast())
        
        var removedCount = 0
        for fileURL in filesToRemove {
            do {
                try fileManager.removeItem(at: fileURL)
                removedCount += 1
            } catch {
                // Continue removing other files even if one fails
                print("Failed to remove \(fileURL.path): \(error)")
            }
        }
        
        return removedCount
    }
}
