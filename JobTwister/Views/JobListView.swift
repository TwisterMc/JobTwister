import SwiftUI

struct JobListView: View {
    let jobs: [Job]
    @Binding var selectedJob: Job?
    @Binding var searchText: String
    @Binding var showingAddJob: Bool
    let onSort: (ContentView.SortOption) -> Void
    let currentSortOption: ContentView.SortOption
    
    var body: some View {
        List {
            ForEach(jobs) { job in
                Button(action: {
                    selectedJob = job
                }) {
                    JobListItemView(job: job, isSelected: selectedJob?.id == job.id)
                }
                .buttonStyle(.borderless)
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
                    onSort: onSort,
                    currentSortOption: currentSortOption
                )
            }
        }
    }
}
