import Foundation
#if canImport(BackgroundTasks)
import BackgroundTasks
#endif

/// Manages background monitoring and periodic performance checks
@available(iOS 15.0, *)
public class BackgroundMonitor {
    
    /// Background task identifier
    public static let backgroundTaskIdentifier = "com.ioscleaner.performance.monitor"
    
    /// Monitoring frequency
    public enum MonitoringFrequency {
        case daily
        case weekly
        case monthly
        
        var timeInterval: TimeInterval {
            switch self {
            case .daily:
                return 24 * 60 * 60 // 24 hours
            case .weekly:
                return 7 * 24 * 60 * 60 // 7 days
            case .monthly:
                return 30 * 24 * 60 * 60 // 30 days
            }
        }
    }
    
    /// Monitoring result
    public struct MonitoringResult {
        public let timestamp: Date
        public let metrics: PerformanceManager.PerformanceMetrics
        public let recommendations: [PerformanceManager.OptimizationRecommendation]
        public let shouldNotifyUser: Bool
        
        public init(timestamp: Date, metrics: PerformanceManager.PerformanceMetrics, recommendations: [PerformanceManager.OptimizationRecommendation], shouldNotifyUser: Bool) {
            self.timestamp = timestamp
            self.metrics = metrics
            self.recommendations = recommendations
            self.shouldNotifyUser = shouldNotifyUser
        }
    }
    
    private let performanceManager: PerformanceManager
    private let userDefaults = UserDefaults.standard
    private let lastCheckKey = "lastBackgroundCheck"
    private let metricsHistoryKey = "metricsHistory"
    
    public init(performanceManager: PerformanceManager) {
        self.performanceManager = performanceManager
    }
    
    /// Register background tasks
    public func registerBackgroundTasks() {
        // In a real app, this would be called in AppDelegate
        // BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.backgroundTaskIdentifier, using: nil) { task in
        //     self.handleBackgroundTask(task: task as! BGAppRefreshTask)
        // }
    }
    
    /// Schedule next background check
    public func scheduleBackgroundCheck(frequency: MonitoringFrequency = .daily) {
        #if canImport(BackgroundTasks)
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: frequency.timeInterval)
        
        do {
            // try BGTaskScheduler.shared.submit(request)
            // For now, just save the schedule preference
            userDefaults.set(Date(), forKey: lastCheckKey)
        } catch {
            print("Failed to schedule background task: \(error)")
        }
        #else
        // On non-iOS platforms, just save the schedule preference
        userDefaults.set(Date(), forKey: lastCheckKey)
        #endif
    }
    
    /// Handle background task execution
    #if canImport(BackgroundTasks)
    private func handleBackgroundTask(task: BGAppRefreshTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let operation = BlockOperation {
            let result = self.performBackgroundCheck()
            
            if result.shouldNotifyUser {
                self.sendNotification(for: result)
            }
            
            task.setTaskCompleted(success: true)
        }
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        queue.addOperation(operation)
        
        // Schedule next check
        scheduleBackgroundCheck()
    }
    #endif
    
    /// Perform background performance check
    public func performBackgroundCheck() -> MonitoringResult {
        let metrics = performanceManager.getCurrentMetrics()
        let recommendations = performanceManager.getRecommendations()
        
        // Save metrics to history
        saveMetricsToHistory(metrics)
        
        // Determine if user should be notified
        let shouldNotify = shouldNotifyUser(metrics: metrics, recommendations: recommendations)
        
        return MonitoringResult(
            timestamp: Date(),
            metrics: metrics,
            recommendations: recommendations,
            shouldNotifyUser: shouldNotify
        )
    }
    
    /// Determine if user should be notified
    private func shouldNotifyUser(metrics: PerformanceManager.PerformanceMetrics, recommendations: [PerformanceManager.OptimizationRecommendation]) -> Bool {
        // Notify if storage is critically low
        if metrics.storageUsagePercentage > 90 {
            return true
        }
        
        // Notify if there are high-priority recommendations
        if recommendations.count > 2 {
            return true
        }
        
        return false
    }
    
    /// Send notification to user
    private func sendNotification(for result: MonitoringResult) {
        // In a real app, this would use UNUserNotificationCenter
        let content = generateNotificationContent(for: result)
        print("Notification: \(content.title) - \(content.body)")
    }
    
    /// Generate notification content
    private func generateNotificationContent(for result: MonitoringResult) -> (title: String, body: String) {
        let metrics = result.metrics
        
        if metrics.storageUsagePercentage > 90 {
            return (
                "Storage Almost Full",
                "Your device is running out of space. Open iOS Cleaner to free up \(StorageAnalyzer.formatBytes(metrics.storageAvailable))."
            )
        }
        
        if result.recommendations.count > 0 {
            let firstRec = result.recommendations[0]
            return (
                firstRec.title,
                "\(firstRec.description) \(firstRec.potentialImprovement)"
            )
        }
        
        return (
            "Performance Check Complete",
            "Your device is running smoothly. Keep up the good maintenance!"
        )
    }
    
    /// Save metrics to history
    private func saveMetricsToHistory(_ metrics: PerformanceManager.PerformanceMetrics) {
        var history = getMetricsHistory()
        
        // Keep only last 30 entries
        if history.count >= 30 {
            history.removeFirst()
        }
        
        let entry = MetricsHistoryEntry(
            timestamp: metrics.timestamp,
            memoryUsagePercentage: metrics.memoryUsagePercentage,
            storageUsagePercentage: metrics.storageUsagePercentage
        )
        
        history.append(entry)
        
        if let encoded = try? JSONEncoder().encode(history) {
            userDefaults.set(encoded, forKey: metricsHistoryKey)
        }
    }
    
    /// Get metrics history
    public func getMetricsHistory() -> [MetricsHistoryEntry] {
        guard let data = userDefaults.data(forKey: metricsHistoryKey),
              let history = try? JSONDecoder().decode([MetricsHistoryEntry].self, from: data) else {
            return []
        }
        return history
    }
    
    /// Get last check date
    public func getLastCheckDate() -> Date? {
        return userDefaults.object(forKey: lastCheckKey) as? Date
    }
    
    /// Check if subscription is active (placeholder for actual implementation)
    public func isSubscriptionActive() -> Bool {
        // This would check with SubscriptionManager
        // For now, return true for development
        return true
    }
}

/// Metrics history entry for trend tracking
public struct MetricsHistoryEntry: Codable {
    public let timestamp: Date
    public let memoryUsagePercentage: Double
    public let storageUsagePercentage: Double
    
    public init(timestamp: Date, memoryUsagePercentage: Double, storageUsagePercentage: Double) {
        self.timestamp = timestamp
        self.memoryUsagePercentage = memoryUsagePercentage
        self.storageUsagePercentage = storageUsagePercentage
    }
}
