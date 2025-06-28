import SwiftUI

struct JobRow: View {
    let job: Job
    @Binding var selectedJob: Job?
    
    var body: some View {
        Button(action: {
            selectedJob = job
        }) {
            JobListItemView(job: job, isSelected: selectedJob?.id == job.id)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(selectedJob?.id == job.id ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
}

struct JobListView: View {
    let jobs: [Job]
    @Binding var selectedJob: Job?
    @Binding var searchText: String
    @Binding var showingAddJob: Bool
    @Binding var isSidebarVisible: Bool
    let onSort: (ContentView.SortOption) -> Void
    let currentSortOption: ContentView.SortOption
    
    var body: some View {
        List {
            ForEach(jobs) { job in
                JobRow(job: job, selectedJob: $selectedJob)
            }
        }
        .listStyle(.plain)
        .id(currentSortOption)
        .navigationTitle("Job Applications")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                JobListToolbar(
                    selectedJob: $selectedJob,
                    showingAddJob: $showingAddJob,
                    isSidebarVisible: $isSidebarVisible,
                    onSort: onSort,
                    currentSortOption: currentSortOption
                )
            }
        }
        .searchable(text: $searchText, isPresented: .constant(isSidebarVisible), prompt: "Search jobs")
    }
}


