import SwiftUI
import SwiftData

struct InterviewRowView: View {
    @Binding var interview: Interview
    var onDelete: () -> Void
    
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
        

            
            Button(role: .destructive, action: onDelete) {
                Label("Remove Interview", systemImage: "minus.circle")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.red)
        }
        .padding(.vertical, 4)
    }
}

