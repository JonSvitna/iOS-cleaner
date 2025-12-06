import Foundation

/// Cleans various types of cached and temporary files
public class CacheCleaner {
    
    /// Result of a cleaning operation
    public struct CleaningResult {
        public let itemsRemoved: Int
        public let spaceFreed: Int64
        public let category: String
        
        public init(itemsRemoved: Int, spaceFreed: Int64, category: String) {
            self.itemsRemoved = itemsRemoved
            self.spaceFreed = spaceFreed
            self.category = category
        }
    }
    
    public init() {}
    
    /// Cleans temporary files directory
    public func cleanTemporaryFiles() throws -> CleaningResult {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory
        
        var itemsRemoved = 0
        var spaceFreed: Int64 = 0
        
        guard let enumerator = fileManager.enumerator(
            at: tempURL,
            includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
            options: []
        ) else {
            return CleaningResult(itemsRemoved: 0, spaceFreed: 0, category: "Temporary Files")
        }
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
                let fileSize = resourceValues.fileSize ?? 0
                
                try fileManager.removeItem(at: fileURL)
                itemsRemoved += 1
                spaceFreed += Int64(fileSize)
            } catch {
                // Continue with next file if deletion fails
                continue
            }
        }
        
        return CleaningResult(itemsRemoved: itemsRemoved, spaceFreed: spaceFreed, category: "Temporary Files")
    }
    
    /// Cleans cache directory
    public func cleanCaches() throws -> CleaningResult {
        let fileManager = FileManager.default
        guard let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return CleaningResult(itemsRemoved: 0, spaceFreed: 0, category: "Caches")
        }
        
        var itemsRemoved = 0
        var spaceFreed: Int64 = 0
        
        guard let enumerator = fileManager.enumerator(
            at: cacheURL,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return CleaningResult(itemsRemoved: 0, spaceFreed: 0, category: "Caches")
        }
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                let fileSize = resourceValues.fileSize ?? 0
                
                try fileManager.removeItem(at: fileURL)
                itemsRemoved += 1
                spaceFreed += Int64(fileSize)
            } catch {
                // Continue with next file if deletion fails
                continue
            }
        }
        
        return CleaningResult(itemsRemoved: itemsRemoved, spaceFreed: spaceFreed, category: "Caches")
    }
    
    /// Cleans old files that haven't been accessed in a specified number of days
    public func cleanOldFiles(in directory: URL, olderThanDays days: Int) throws -> CleaningResult {
        let fileManager = FileManager.default
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        var itemsRemoved = 0
        var spaceFreed: Int64 = 0
        
        guard let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.contentAccessDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return CleaningResult(itemsRemoved: 0, spaceFreed: 0, category: "Old Files")
        }
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.contentAccessDateKey, .fileSizeKey])
                
                if let accessDate = resourceValues.contentAccessDate,
                   accessDate < cutoffDate {
                    let fileSize = resourceValues.fileSize ?? 0
                    try fileManager.removeItem(at: fileURL)
                    itemsRemoved += 1
                    spaceFreed += Int64(fileSize)
                }
            } catch {
                // Continue with next file if deletion fails
                continue
            }
        }
        
        return CleaningResult(itemsRemoved: itemsRemoved, spaceFreed: spaceFreed, category: "Old Files")
    }
    
    /// Performs a comprehensive cleanup
    public func performFullCleanup() -> [CleaningResult] {
        var results: [CleaningResult] = []
        
        // Clean temporary files
        if let tempResult = try? cleanTemporaryFiles() {
            results.append(tempResult)
        }
        
        // Clean caches
        if let cacheResult = try? cleanCaches() {
            results.append(cacheResult)
        }
        
        return results
    }
}
