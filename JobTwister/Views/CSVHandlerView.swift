import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct CSVHandlerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var error: String?
    
    let operation: CSVOperation
    
    var body: some View {
        VStack(spacing: 16) {
            Text(operation == .import ? "Importing Jobs..." : "Exporting Jobs...")
                .font(.headline)
            
            if let error = error {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.subheadline)
            }
            
            ProgressView()
        }
        .padding()
        .task {
            // Add a small delay to prevent the breakpoint issue
            try? await Task.sleep(for: .milliseconds(100))
            switch operation {
            case .import:
                await importCSV()
            case .export:
                await exportCSV()
            }
        }
    }
    
    private func importCSV() async {
        await MainActor.run {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            panel.allowedContentTypes = [UTType(filenameExtension: "csv")!]
            
            if panel.runModal() == .OK, let url = panel.url {
                do {
                    let csvString = try String(contentsOf: url)
                    let jobs = CSVHandler.importJobs(from: csvString, context: modelContext)
                    jobs.forEach { modelContext.insert($0) }
                    try modelContext.save()
                    dismiss()
                } catch {
                    self.error = "Error importing CSV: \(error.localizedDescription)"
                }
            } else {
                dismiss()
            }
        }
    }
    
    private func exportCSV() async {
        await MainActor.run {
            let panel = NSSavePanel()
            panel.allowedContentTypes = [UTType(filenameExtension: "csv")!]
            panel.nameFieldStringValue = "jobs.csv"
            
            if panel.runModal() == .OK, let url = panel.url {
                do {
                    let descriptor = FetchDescriptor<Job>()
                    let jobs = try modelContext.fetch(descriptor)
                    let csvString = CSVHandler.exportJobs(jobs)
                    try csvString.write(to: url, atomically: true, encoding: .utf8)
                    dismiss()
                } catch {
                    self.error = "Error exporting CSV: \(error.localizedDescription)"
                }
            } else {
                dismiss()
            }
        }
    }
}
