import Foundation
#if os(iOS) || os(macOS)
import Darwin
#endif

/// Manages device performance monitoring and optimization
@available(iOS 15.0, *)
public class PerformanceManager {
    
    /// Performance mode options
    public enum PerformanceMode: String, CaseIterable {
        case speed = "Speed Mode"
        case batterySaver = "Battery Saver"
        case gaming = "Gaming Mode"
        
        public var description: String {
            switch self {
            case .speed:
                return "Optimizes device for maximum performance and responsiveness"
            case .batterySaver:
                return "Reduces background activity to extend battery life"
            case .gaming:
                return "Optimizes CPU and memory for gaming performance"
            }
        }
        
        public var icon: String {
            switch self {
            case .speed:
                return "bolt.fill"
            case .batterySaver:
                return "battery.100"
            case .gaming:
                return "gamecontroller.fill"
            }
        }
    }
    
    /// Performance metrics
    public struct PerformanceMetrics {
        public let memoryUsage: Int64 // bytes
        public let availableMemory: Int64 // bytes
        public let storageUsed: Int64 // bytes
        public let storageAvailable: Int64 // bytes
        public let timestamp: Date
        
        public var memoryUsagePercentage: Double {
            let total = memoryUsage + availableMemory
            return total > 0 ? Double(memoryUsage) / Double(total) * 100 : 0
        }
        
        public var storageUsagePercentage: Double {
            let total = storageUsed + storageAvailable
            return total > 0 ? Double(storageUsed) / Double(total) * 100 : 0
        }
        
        public init(memoryUsage: Int64, availableMemory: Int64, storageUsed: Int64, storageAvailable: Int64, timestamp: Date = Date()) {
            self.memoryUsage = memoryUsage
            self.availableMemory = availableMemory
            self.storageUsed = storageUsed
            self.storageAvailable = storageAvailable
            self.timestamp = timestamp
        }
    }
    
    /// Optimization recommendation
    public struct OptimizationRecommendation {
        public let title: String
        public let description: String
        public let potentialImprovement: String
        public let action: OptimizationAction
        
        public init(title: String, description: String, potentialImprovement: String, action: OptimizationAction) {
            self.title = title
            self.description = description
            self.potentialImprovement = potentialImprovement
            self.action = action
        }
    }
    
    /// Actions that can optimize performance
    public enum OptimizationAction {
        case clearCache
        case removeDuplicates
        case cleanOldFiles
        case closeBackgroundApps
        case reduceAnimations
    }
    
    private var currentMode: PerformanceMode = .speed
    private let userDefaults = UserDefaults.standard
    private let modeKey = "performanceMode"
    
    public init() {
        loadSavedMode()
    }
    
    /// Get current performance metrics
    public func getCurrentMetrics() -> PerformanceMetrics {
        let memoryUsage = getMemoryUsage()
        let availableMemory = getAvailableMemory()
        let (storageUsed, storageAvailable) = getStorageInfo()
        
        return PerformanceMetrics(
            memoryUsage: memoryUsage,
            availableMemory: availableMemory,
            storageUsed: storageUsed,
            storageAvailable: storageAvailable
        )
    }
    
    /// Get memory usage in bytes
    private func getMemoryUsage() -> Int64 {
        #if os(iOS) || os(macOS)
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int64(info.resident_size)
        }
        #endif
        return 0
    }
    
    /// Get available memory in bytes
    private func getAvailableMemory() -> Int64 {
        #if os(iOS) || os(macOS)
        let hostPort = mach_host_self()
        var hostSize = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)
        var pageSize: vm_size_t = 0
        
        host_page_size(hostPort, &pageSize)
        
        var vmStat = vm_statistics64()
        let result = withUnsafeMutablePointer(to: &vmStat) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(hostSize)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &hostSize)
            }
        }
        
        if result == KERN_SUCCESS {
            let freeMemory = Int64(vmStat.free_count) * Int64(pageSize)
            return freeMemory
        }
        #endif
        return 0
    }
    
    /// Get storage information
    private func getStorageInfo() -> (used: Int64, available: Int64) {
        guard let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) else {
            return (0, 0)
        }
        
        let totalSpace = (attributes[.systemSize] as? NSNumber)?.int64Value ?? 0
        let freeSpace = (attributes[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
        let usedSpace = totalSpace - freeSpace
        
        return (usedSpace, freeSpace)
    }
    
    /// Get current performance mode
    public func getCurrentMode() -> PerformanceMode {
        return currentMode
    }
    
    /// Set performance mode
    public func setMode(_ mode: PerformanceMode) {
        currentMode = mode
        userDefaults.set(mode.rawValue, forKey: modeKey)
        applyModeOptimizations(mode)
    }
    
    /// Load saved mode from preferences
    private func loadSavedMode() {
        if let savedMode = userDefaults.string(forKey: modeKey),
           let mode = PerformanceMode(rawValue: savedMode) {
            currentMode = mode
        }
    }
    
    /// Apply optimizations based on mode
    private func applyModeOptimizations(_ mode: PerformanceMode) {
        // In a real app, this would apply system-level optimizations
        // For iOS, this is limited due to sandboxing, but we can:
        // - Adjust app behavior
        // - Provide recommendations to user
        // - Optimize background tasks scheduling
        
        switch mode {
        case .speed:
            // Prioritize performance over battery
            scheduleBackgroundTasks(priority: .high)
        case .batterySaver:
            // Reduce background activity
            scheduleBackgroundTasks(priority: .low)
        case .gaming:
            // Optimize for sustained performance
            scheduleBackgroundTasks(priority: .medium)
        }
    }
    
    /// Schedule background tasks based on priority
    private func scheduleBackgroundTasks(priority: TaskPriority) {
        // This would integrate with BackgroundTasks framework
        // Implementation would vary based on actual background task setup
    }
    
    /// Task priority levels
    private enum TaskPriority {
        case low, medium, high
    }
    
    /// Get optimization recommendations based on current metrics
    public func getRecommendations() -> [OptimizationRecommendation] {
        let metrics = getCurrentMetrics()
        var recommendations: [OptimizationRecommendation] = []
        
        // Storage-based recommendations
        if metrics.storageUsagePercentage > 80 {
            recommendations.append(OptimizationRecommendation(
                title: "Storage Almost Full",
                description: "Your device storage is over 80% full. Clear cache and remove duplicates to free up space.",
                potentialImprovement: "Up to 2-5 GB",
                action: .clearCache
            ))
        }
        
        // Memory-based recommendations
        if metrics.memoryUsagePercentage > 75 {
            recommendations.append(OptimizationRecommendation(
                title: "High Memory Usage",
                description: "Memory usage is high. Clearing cache and old files can help improve responsiveness.",
                potentialImprovement: "Faster app performance",
                action: .clearCache
            ))
        }
        
        // Mode-specific recommendations
        switch currentMode {
        case .batterySaver:
            recommendations.append(OptimizationRecommendation(
                title: "Battery Saver Active",
                description: "Background tasks are minimized to extend battery life. Consider switching modes for better performance.",
                potentialImprovement: "Extended battery life",
                action: .reduceAnimations
            ))
        case .gaming:
            recommendations.append(OptimizationRecommendation(
                title: "Gaming Mode Active",
                description: "Device optimized for gaming. Clear cache before starting games for best performance.",
                potentialImprovement: "Smoother gaming",
                action: .clearCache
            ))
        case .speed:
            break
        }
        
        return recommendations
    }
    
    /// Estimate performance impact of cleaning
    public func estimatePerformanceImpact(cleaningSize: Int64) -> String {
        if cleaningSize > 5_000_000_000 { // > 5GB
            return "Significant improvement - faster app launches and better responsiveness"
        } else if cleaningSize > 1_000_000_000 { // > 1GB
            return "Moderate improvement - noticeable speed increase"
        } else if cleaningSize > 100_000_000 { // > 100MB
            return "Minor improvement - slightly better performance"
        } else {
            return "Minimal impact - maintenance cleanup"
        }
    }
}
