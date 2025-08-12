import SwiftUI
import SwiftData

struct InterviewRowView: View {
    @Binding var interview: Interview
    var onDelete: () -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DatePicker("Interview Date", selection: $interview.date)
            
            Label("Notes", systemImage: "note.text")
            TextEditor(text: $interview.notes)
                               .scrollContentBackground(.hidden)
                                           .padding(5)
                                           .frame(height: 50)
                                           .cornerRadius(8)
                                           .focusAwareStyle()
                                           .background(
                                               RoundedRectangle(cornerRadius: 4)     // Smaller corner radius
                                                   .fill(Color.clear)
                                                   .overlay(
                                                       RoundedRectangle(cornerRadius: 4)
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                   )
                                           )
        

            
            Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Remove Interview", systemImage: "minus.circle")
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.red)
                        .confirmationDialog(
                            "Remove Interview?",
                            isPresented: $showingDeleteAlert,
                            actions: {
                                Button("Delete", role: .destructive, action: onDelete)
                                Button("Cancel", role: .cancel) { }
                            },
                            message: {
                                Text("Are you sure you want to remove this interview?")
                            }
                        )
                    }
                    .padding(.vertical, 4)
    }
}

