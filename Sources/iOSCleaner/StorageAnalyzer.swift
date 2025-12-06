import Foundation

/// Analyzes storage usage and provides information about file sizes and types
public class StorageAnalyzer {
    
    /// Represents storage information for a specific directory or file type
    public struct StorageInfo {
        public let category: String
        public let size: Int64
        public let fileCount: Int
        public let path: String?
        
        public init(category: String, size: Int64, fileCount: Int, path: String? = nil) {
            self.category = category
            self.size = size
            self.fileCount = fileCount
            self.path = path
        }
    }
    
    public init() {}
    
    /// Analyzes storage usage for common directories
    public func analyzeStorage() -> [StorageInfo] {
        var storageInfos: [StorageInfo] = []
        
        // Get common directories
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        if let documentsURL = urls.first {
            let documentsInfo = analyzeDirectory(at: documentsURL, category: "Documents")
            storageInfos.append(documentsInfo)
        }
        
        // Analyze caches
        if let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let cachesInfo = analyzeDirectory(at: cachesURL, category: "Caches")
            storageInfos.append(cachesInfo)
        }
        
        // Analyze temporary files
        let tempURL = fileManager.temporaryDirectory
        let tempInfo = analyzeDirectory(at: tempURL, category: "Temporary Files")
        storageInfos.append(tempInfo)
        
        return storageInfos
    }
    
    /// Analyzes a specific directory
    public func analyzeDirectory(at url: URL, category: String) -> StorageInfo {
        let fileManager = FileManager.default
        var totalSize: Int64 = 0
        var fileCount = 0
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return StorageInfo(category: category, size: 0, fileCount: 0, path: url.path)
        }
        
        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]),
                  let isRegularFile = resourceValues.isRegularFile,
                  isRegularFile,
                  let fileSize = resourceValues.fileSize else {
                continue
            }
            
            totalSize += Int64(fileSize)
            fileCount += 1
        }
        
        return StorageInfo(category: category, size: totalSize, fileCount: fileCount, path: url.path)
    }
    
    /// Formats bytes to human-readable string
    public static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
