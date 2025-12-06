import SwiftUI

/// View for managing duplicate files
@available(iOS 15.0, *)
public struct DuplicatesView: View {
    @ObservedObject var viewModel: CleanerViewModel
    
    public init(viewModel: CleanerViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            if viewModel.duplicateGroups.isEmpty {
                if viewModel.isLoading {
                    ProgressView("Searching for duplicates...")
                        .padding()
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("No Duplicates Found")
                            .font(.headline)
                        Text("Your files are already optimized")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Scan Again") {
                            viewModel.findDuplicates()
                        }
                        .padding()
                    }
                    .padding()
                }
            } else {
                List {
                    Section(header: Text("Duplicate Groups")) {
                        ForEach(viewModel.duplicateGroups, id: \.hash) { group in
                            DuplicateGroupRow(group: group, onRemove: {
                                viewModel.removeDuplicateGroup(group)
                            })
                        }
                    }
                    
                    Section(header: Text("Summary")) {
                        let totalWasted = viewModel.duplicateGroups.reduce(0) { $0 + $1.totalWastedSpace }
                        HStack {
                            Text("Total Wasted Space")
                            Spacer()
                            Text(StorageAnalyzer.formatBytes(totalWasted))
                                .foregroundColor(.red)
                                .bold()
                        }
                    }
                }
            }
        }
        .navigationTitle("Duplicate Files")
        .onAppear {
            if viewModel.duplicateGroups.isEmpty {
                viewModel.findDuplicates()
            }
        }
    }
}

@available(iOS 15.0, *)
struct DuplicateGroupRow: View {
    let group: DuplicateDetector.DuplicateGroup
    let onRemove: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(group.files.count) duplicate files")
                        .font(.headline)
                    Text("Wasting \(StorageAnalyzer.formatBytes(group.totalWastedSpace))")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Files:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(group.files, id: \.path) { fileURL in
                        Text(fileURL.lastPathComponent)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 8)
                    }
                }
            }
            
            Button(action: { isExpanded.toggle() }) {
                Text(isExpanded ? "Show Less" : "Show Files")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 4)
    }
}
