import Foundation

/// Main iOS Cleaner class that coordinates all cleaning operations
public class iOSCleaner {
    
    public let storageAnalyzer: StorageAnalyzer
    public let duplicateDetector: DuplicateDetector
    public let cacheCleaner: CacheCleaner
    
    public init() {
        self.storageAnalyzer = StorageAnalyzer()
        self.duplicateDetector = DuplicateDetector()
        self.cacheCleaner = CacheCleaner()
    }
    
    /// Performs a comprehensive analysis of the device storage
    public func analyzeDevice() -> DeviceAnalysisResult {
        let storageInfos = storageAnalyzer.analyzeStorage()
        
        let totalSize = storageInfos.reduce(0) { $0 + $1.size }
        let totalFiles = storageInfos.reduce(0) { $0 + $1.fileCount }
        
        return DeviceAnalysisResult(
            storageInfos: storageInfos,
            totalSize: totalSize,
            totalFiles: totalFiles
        )
    }
    
    /// Finds all duplicate files that can be cleaned
    public func findDuplicates() -> [DuplicateDetector.DuplicateGroup] {
        let fileManager = FileManager.default
        var searchURLs: [URL] = []
        
        // Add documents directory
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            searchURLs.append(documentsURL)
        }
        
        return duplicateDetector.findDuplicates(in: searchURLs)
    }
    
    /// Performs a quick cleanup of temporary files and caches
    public func quickClean() -> CleanupSummary {
        let results = cacheCleaner.performFullCleanup()
        
        let totalItemsRemoved = results.reduce(0) { $0 + $1.itemsRemoved }
        let totalSpaceFreed = results.reduce(0) { $0 + $1.spaceFreed }
        
        return CleanupSummary(
            results: results,
            totalItemsRemoved: totalItemsRemoved,
            totalSpaceFreed: totalSpaceFreed
        )
    }
    
    /// Estimates potential space savings
    public func estimateSavings() -> SpaceSavingsEstimate {
        let duplicates = findDuplicates()
        let duplicateSpace = duplicates.reduce(0) { $0 + $1.totalWastedSpace }
        
        // Estimate cache and temp space (would need actual analysis)
        let storageInfos = storageAnalyzer.analyzeStorage()
        let cacheSpace = storageInfos.first(where: { $0.category == "Caches" })?.size ?? 0
        let tempSpace = storageInfos.first(where: { $0.category == "Temporary Files" })?.size ?? 0
        
        return SpaceSavingsEstimate(
            duplicateFilesSpace: duplicateSpace,
            cacheSpace: cacheSpace,
            temporaryFilesSpace: tempSpace,
            totalPotentialSavings: duplicateSpace + cacheSpace + tempSpace
        )
    }
}

// MARK: - Result Types

public struct DeviceAnalysisResult {
    public let storageInfos: [StorageAnalyzer.StorageInfo]
    public let totalSize: Int64
    public let totalFiles: Int
    
    public init(storageInfos: [StorageAnalyzer.StorageInfo], totalSize: Int64, totalFiles: Int) {
        self.storageInfos = storageInfos
        self.totalSize = totalSize
        self.totalFiles = totalFiles
    }
}

public struct CleanupSummary {
    public let results: [CacheCleaner.CleaningResult]
    public let totalItemsRemoved: Int
    public let totalSpaceFreed: Int64
    
    public init(results: [CacheCleaner.CleaningResult], totalItemsRemoved: Int, totalSpaceFreed: Int64) {
        self.results = results
        self.totalItemsRemoved = totalItemsRemoved
        self.totalSpaceFreed = totalSpaceFreed
    }
}

public struct SpaceSavingsEstimate {
    public let duplicateFilesSpace: Int64
    public let cacheSpace: Int64
    public let temporaryFilesSpace: Int64
    public let totalPotentialSavings: Int64
    
    public init(duplicateFilesSpace: Int64, cacheSpace: Int64, temporaryFilesSpace: Int64, totalPotentialSavings: Int64) {
        self.duplicateFilesSpace = duplicateFilesSpace
        self.cacheSpace = cacheSpace
        self.temporaryFilesSpace = temporaryFilesSpace
        self.totalPotentialSavings = totalPotentialSavings
    }
}
