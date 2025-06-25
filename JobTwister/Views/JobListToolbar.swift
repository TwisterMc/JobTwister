import SwiftUI

struct JobListToolbar: View {
    @Binding var selectedJob: Job?
    @Binding var showingAddJob: Bool
    @Binding var isSidebarVisible: Bool
    let onSort: (ContentView.SortOption) -> Void
    let currentSortOption: ContentView.SortOption
    @State private var showingSortMenu = false
    
    var body: some View {
        Group {
            Button {
                if !isSidebarVisible {
                    isSidebarVisible = true
                }
                showingSortMenu = true
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
            .popover(isPresented: $showingSortMenu) {
                VStack {
                    ForEach(ContentView.SortOption.allCases, id: \.self) { option in
                        Button(action: {
                            onSort(option)
                            showingSortMenu = false
                        }) {
                            HStack {
                                Text(option.rawValue)
                                if currentSortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .frame(minWidth: 150)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 4)
                    }
                }
                .padding()
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
