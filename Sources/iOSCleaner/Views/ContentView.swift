import SwiftUI

/// Main content view for the iOS Cleaner app
@available(iOS 15.0, *)
public struct ContentView: View {
    @StateObject private var viewModel = CleanerViewModel()
    @State private var showPermissionRequest = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Storage Overview
                    StorageOverviewCard(viewModel: viewModel)
                    
                    // Quick Actions
                    VStack(spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        QuickCleanButton(viewModel: viewModel)
                        
                        NavigationLink(destination: DuplicatesView(viewModel: viewModel)) {
                            ActionCard(
                                title: "Find Duplicates",
                                subtitle: "Detect and remove duplicate files",
                                icon: "doc.on.doc",
                                color: .orange
                            )
                        }
                        
                        NavigationLink(destination: StorageDetailsView(viewModel: viewModel)) {
                            ActionCard(
                                title: "Storage Analysis",
                                subtitle: "Detailed breakdown of space usage",
                                icon: "chart.pie",
                                color: .purple
                            )
                        }
                    }
                    
                    // Performance & Subscription Section
                    VStack(spacing: 12) {
                        Text("Performance & Premium")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: PerformanceDashboardView()) {
                            ActionCard(
                                title: "Performance Monitor",
                                subtitle: "Optimize device performance",
                                icon: "speedometer",
                                color: .green
                            )
                        }
                        
                        NavigationLink(destination: SubscriptionView()) {
                            ActionCard(
                                title: "Subscription",
                                subtitle: "Unlock premium features",
                                icon: "crown.fill",
                                color: .purple
                            )
                        }
                    }
                    
                    // Status Messages
                    if let message = viewModel.statusMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("iOS Cleaner")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showPermissionRequest = true
                    }) {
                        Image(systemName: "lock.shield")
                    }
                }
            }
            .sheet(isPresented: $showPermissionRequest) {
                PermissionRequestView()
            }
            .onAppear {
                viewModel.analyzeStorage()
            }
        }
    }
}

@available(iOS 15.0, *)
struct StorageOverviewCard: View {
    @ObservedObject var viewModel: CleanerViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "internaldrive")
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("Storage Used")
                        .font(.headline)
                    if let analysis = viewModel.analysisResult {
                        Text(StorageAnalyzer.formatBytes(analysis.totalSize))
                            .font(.title2)
                            .bold()
                        Text("\(analysis.totalFiles) files")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Analyzing...")
                            .font(.caption)
                    }
                }
                
                Spacer()
            }
            
            if let estimate = viewModel.savingsEstimate {
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text("Potential Savings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(StorageAnalyzer.formatBytes(estimate.totalPotentialSavings))
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

@available(iOS 15.0, *)
struct QuickCleanButton: View {
    @ObservedObject var viewModel: CleanerViewModel
    
    var body: some View {
        Button(action: {
            viewModel.performQuickClean()
        }) {
            ActionCard(
                title: "Quick Clean",
                subtitle: "Clear temporary files and caches",
                icon: "trash",
                color: .blue
            )
        }
        .disabled(viewModel.isLoading)
    }
}

@available(iOS 15.0, *)
struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
