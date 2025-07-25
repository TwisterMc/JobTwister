import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    @Binding var selectedJob: Job?
    @Binding var showingAddJob: Bool
    
    enum SortOption: String, CaseIterable {
        case alphabetical = "Alphabetical - Company "
        case alphabeticalJT = "Alphabetical - Title"
        case dateAdded = "Date Added"
        case dateModified = "Last Modified"
        case workType = "Work Type"
        case interview = "Has Interview"
    }
    
    @Environment(\.modelContext) private var modelContext
    @State private var sortOption: SortOption = .dateAdded
    @State private var isSidebarVisible = true // This state seems unused, consider removing if not needed.
    @Query private var jobs: [Job]
    @State private var searchText = ""
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    private var sortedJobs: [Job] {
        switch sortOption {
        case .dateAdded:
            return jobs.sorted { $0.dateApplied > $1.dateApplied }
        case .dateModified:
            return jobs.sorted { $0.lastModified > $1.lastModified }
        case .alphabetical:
            return jobs.sorted { $0.companyName.localizedCaseInsensitiveCompare($1.companyName) == .orderedAscending }
        case .alphabeticalJT:
            return jobs.sorted { $0.jobTitle.localizedCaseInsensitiveCompare($1.jobTitle) == .orderedAscending }
        case .workType:
            return jobs.sorted { $0.workplaceType.rawValue.localizedCaseInsensitiveCompare($1.workplaceType.rawValue) == .orderedAscending }
        case .interview:
            return jobs.sorted { $0.hasInterview && !$1.hasInterview }
        }
    }
    
    var filteredJobs: [Job] {
        if searchText.isEmpty {
            return sortedJobs
        } else {
            return sortedJobs.filter { job in
                job.companyName.localizedCaseInsensitiveContains(searchText) ||
                job.jobTitle.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var applicationStats: (applied: Int, interviewed: Int, denied: Int) {
        let interviewed = jobs.filter { $0.hasInterview }.count
        let denied = jobs.filter { $0.isDenied }.count
        return (jobs.count, interviewed, denied)
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            JobListView(
                jobs: filteredJobs,
                selectedJob: $selectedJob,
                searchText: $searchText,
                showingAddJob: $showingAddJob,
                isSidebarVisible: Binding(
                    get: { columnVisibility == .doubleColumn },
                    set: { columnVisibility = $0 ? .doubleColumn : .detailOnly }
                ),
                onSort: { option in
                    sortOption = option
                },
                currentSortOption: sortOption
            )
            .navigationSplitViewColumnWidth(min: 275, ideal: 300)
        } detail: {
            ScrollView {
                if selectedJob == nil {
                    DashboardView(stats: applicationStats, jobs: jobs)
                        .frame(maxWidth: 800)  // Limit maximum width for better readability
                } else {
                    JobDetailsView(
                        job: selectedJob!,
                        onEdit: { showingAddJob = true },
                        onDelete: {
                            if let selectedJob = selectedJob {
                                modelContext.delete(selectedJob)
                                try? modelContext.save()
                                self.selectedJob = nil
                            }
                        }
                    )
                    .frame(maxWidth: 800)  // Limit maximum width for better readability
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
            .scrollIndicators(.automatic)
            .frame(minWidth: 500, minHeight: 150)
        }
        .onChange(of: searchText) { _, newValue in
            if !newValue.isEmpty {
                columnVisibility = .doubleColumn
            }
        }
        .sheet(isPresented: $showingAddJob) {
            NavigationStack {
                JobFormView(job: selectedJob)
                    .navigationTitle(selectedJob == nil ? "New Job Application" : "Edit Job")
                    .frame(minWidth: 500, minHeight: 650)
            }
        }
    }
    
    private func workplaceTypeColor(_ type: WorkplaceType) -> Color {
        switch type {
        case .remote:
            return .blue
        case .hybrid:
            return .purple
        case .inOffice:
            return .orange
        }
    }
    
    private func deleteJobs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredJobs[index])
            }
            try? modelContext.save()
        }
    }
    
    private func formatSalary(_ min: Double?, _ max: Double?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        
        if let min = min {
            if let max = max {
                return "\(formatter.string(from: NSNumber(value: min)) ?? "$\(Int(min))") - \(formatter.string(from: NSNumber(value: max)) ?? "$\(Int(max))")"
            }
            return formatter.string(from: NSNumber(value: min)) ?? "$\(Int(min))"
        }
        return "Not specified"
    }
}

#Preview {
    // @Previewable @State variables must be at the very beginning
    @Previewable @State var previewSelectedJob: Job? = nil
    @Previewable @State var previewShowingAddJob: Bool = false

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Job.self, configurations: config)
    
    return ContentView(selectedJob: $previewSelectedJob, showingAddJob: $previewShowingAddJob)
        .modelContainer(container)
}
