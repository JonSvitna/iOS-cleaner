import Foundation
import SwiftUI

/// ViewModel for coordinating cleaner operations
@available(iOS 15.0, *)
public class CleanerViewModel: ObservableObject {
    @Published public var analysisResult: DeviceAnalysisResult?
    @Published public var savingsEstimate: SpaceSavingsEstimate?
    @Published public var duplicateGroups: [DuplicateDetector.DuplicateGroup] = []
    @Published public var cleanupSummary: CleanupSummary?
    @Published public var statusMessage: String?
    @Published public var isLoading = false
    
    private let cleaner = iOSCleaner()
    
    public init() {}
    
    public func analyzeStorage() {
        isLoading = true
        statusMessage = "Analyzing storage..."
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let result = self?.cleaner.analyzeDevice()
            let estimate = self?.cleaner.estimateSavings()
            
            DispatchQueue.main.async {
                self?.analysisResult = result
                self?.savingsEstimate = estimate
                self?.isLoading = false
                self?.statusMessage = "Analysis complete"
            }
        }
    }
    
    public func findDuplicates() {
        isLoading = true
        statusMessage = "Searching for duplicates..."
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let duplicates = self?.cleaner.findDuplicates() ?? []
            
            DispatchQueue.main.async {
                self?.duplicateGroups = duplicates
                self?.isLoading = false
                self?.statusMessage = "Found \(duplicates.count) duplicate groups"
            }
        }
    }
    
    public func performQuickClean() {
        isLoading = true
        statusMessage = "Cleaning..."
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let summary = self?.cleaner.quickClean()
            
            DispatchQueue.main.async {
                self?.cleanupSummary = summary
                self?.isLoading = false
                if let summary = summary {
                    let freedSpace = StorageAnalyzer.formatBytes(summary.totalSpaceFreed)
                    self?.statusMessage = "Cleaned \(summary.totalItemsRemoved) items, freed \(freedSpace)"
                }
                // Re-analyze after cleaning
                self?.analyzeStorage()
            }
        }
    }
    
    public func removeDuplicateGroup(_ group: DuplicateDetector.DuplicateGroup) {
        isLoading = true
        statusMessage = "Removing duplicates..."
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let removed = try? self?.cleaner.duplicateDetector.removeDuplicates(in: group, keepFirst: true)
            
            DispatchQueue.main.async {
                self?.isLoading = false
                if let removed = removed {
                    self?.statusMessage = "Removed \(removed) duplicate files"
                    self?.findDuplicates()
                }
            }
        }
    }
}
