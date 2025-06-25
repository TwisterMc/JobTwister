import SwiftUI

struct JobRow: View {
    let job: Job
    @Binding var selectedJob: Job?
    
    var body: some View {
        Button(action: {
            selectedJob = job
        }) {
            JobListItemView(job: job, isSelected: selectedJob?.id == job.id)
        }
        .buttonStyle(.borderless)
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
        .id(UUID())
        .searchable(text: $searchText, prompt: "Search jobs...")
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
    }
}
