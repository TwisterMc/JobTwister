import SwiftUI

struct JobListToolbar: View {
    @Binding var selectedJob: Job?
    @Binding var showingAddJob: Bool
    let onSort: (ContentView.SortOption) -> Void
    let currentSortOption: ContentView.SortOption
    
    var body: some View {
        Group {
            Menu {
                ForEach(ContentView.SortOption.allCases, id: \.self) { option in
                    Button(action: { onSort(option) }) {
                        HStack {
                            Text(option.rawValue)
                            if currentSortOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
            
            Button {
                selectedJob = nil
            } label: {
                Image(systemName: "tachometer")
            }
            
            Button {
                selectedJob = nil
                showingAddJob.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}
