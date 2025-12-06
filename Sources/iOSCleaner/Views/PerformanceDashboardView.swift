import SwiftUI

/// Performance monitoring dashboard
@available(iOS 15.0, *)
public struct PerformanceDashboardView: View {
    @StateObject private var performanceManager = PerformanceManager()
    @State private var metrics: PerformanceManager.PerformanceMetrics?
    @State private var recommendations: [PerformanceManager.OptimizationRecommendation] = []
    @State private var isLoading = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Performance Mode Selector
                PerformanceModeSelector(performanceManager: performanceManager)
                
                // Current Metrics
                if let metrics = metrics {
                    MetricsCard(metrics: metrics)
                }
                
                // Recommendations
                if !recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommendations")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(recommendations.indices, id: \.self) { index in
                            RecommendationCard(recommendation: recommendations[index])
                        }
                    }
                }
                
                // Refresh Button
                Button(action: refreshMetrics) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text("Refresh Metrics")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled(isLoading)
            }
            .padding()
        }
        .navigationTitle("Performance")
        .onAppear {
            refreshMetrics()
        }
    }
    
    private func refreshMetrics() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let newMetrics = performanceManager.getCurrentMetrics()
            let newRecommendations = performanceManager.getRecommendations()
            
            DispatchQueue.main.async {
                self.metrics = newMetrics
                self.recommendations = newRecommendations
                self.isLoading = false
            }
        }
    }
}

@available(iOS 15.0, *)
struct PerformanceModeSelector: View {
    let performanceManager: PerformanceManager
    @State private var selectedMode: PerformanceManager.PerformanceMode
    
    init(performanceManager: PerformanceManager) {
        self.performanceManager = performanceManager
        self._selectedMode = State(initialValue: performanceManager.getCurrentMode())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Mode")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PerformanceManager.PerformanceMode.allCases, id: \.self) { mode in
                        ModeButton(
                            mode: mode,
                            isSelected: selectedMode == mode,
                            action: {
                                selectedMode = mode
                                performanceManager.setMode(mode)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

@available(iOS 15.0, *)
struct ModeButton: View {
    let mode: PerformanceManager.PerformanceMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(mode.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(mode.description)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 140, height: 120)
            .padding()
            .background(isSelected ? Color.blue : Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

@available(iOS 15.0, *)
struct MetricsCard: View {
    let metrics: PerformanceManager.PerformanceMetrics
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Current Metrics")
                .font(.headline)
            
            HStack(spacing: 20) {
                MetricItem(
                    title: "Memory",
                    value: "\(Int(metrics.memoryUsagePercentage))%",
                    icon: "memorychip",
                    color: colorForPercentage(metrics.memoryUsagePercentage)
                )
                
                MetricItem(
                    title: "Storage",
                    value: "\(Int(metrics.storageUsagePercentage))%",
                    icon: "internaldrive",
                    color: colorForPercentage(metrics.storageUsagePercentage)
                )
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Available Memory")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(StorageAnalyzer.formatBytes(metrics.availableMemory))
                        .font(.subheadline)
                        .bold()
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Available Storage")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(StorageAnalyzer.formatBytes(metrics.storageAvailable))
                        .font(.subheadline)
                        .bold()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
    
    private func colorForPercentage(_ percentage: Double) -> Color {
        if percentage < 50 {
            return .green
        } else if percentage < 75 {
            return .orange
        } else {
            return .red
        }
    }
}

@available(iOS 15.0, *)
struct MetricItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

@available(iOS 15.0, *)
struct RecommendationCard: View {
    let recommendation: PerformanceManager.OptimizationRecommendation
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconForAction(recommendation.action))
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.headline)
                
                Text(recommendation.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(recommendation.potentialImprovement)
                    .font(.caption)
                    .foregroundColor(.green)
                    .bold()
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
    
    private func iconForAction(_ action: PerformanceManager.OptimizationAction) -> String {
        switch action {
        case .clearCache:
            return "trash.circle"
        case .removeDuplicates:
            return "doc.on.doc"
        case .cleanOldFiles:
            return "clock.arrow.circlepath"
        case .closeBackgroundApps:
            return "app.badge.checkmark"
        case .reduceAnimations:
            return "sparkles"
        }
    }
}
