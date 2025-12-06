import SwiftUI

/// Detailed storage analysis view
@available(iOS 15.0, *)
public struct StorageDetailsView: View {
    @ObservedObject var viewModel: CleanerViewModel
    
    public init(viewModel: CleanerViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        List {
            if let analysis = viewModel.analysisResult {
                Section(header: Text("Storage Breakdown")) {
                    ForEach(analysis.storageInfos, id: \.category) { info in
                        StorageInfoRow(info: info)
                    }
                }
                
                Section(header: Text("Summary")) {
                    HStack {
                        Text("Total Files")
                        Spacer()
                        Text("\(analysis.totalFiles)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Total Size")
                        Spacer()
                        Text(StorageAnalyzer.formatBytes(analysis.totalSize))
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text("No analysis data available")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Storage Details")
    }
}

@available(iOS 15.0, *)
struct StorageInfoRow: View {
    let info: StorageAnalyzer.StorageInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(info.category)
                    .font(.headline)
                Spacer()
                Text(StorageAnalyzer.formatBytes(info.size))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("\(info.fileCount) files")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let path = info.path {
                    Spacer()
                    Text(path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
