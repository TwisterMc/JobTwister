import SwiftUI
import SwiftData

struct InterviewRowView: View {
    @Binding var interview: Interview
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DatePicker("Interview Date", selection: $interview.date)
                .labelsHidden()
            
            TextField("Notes (optional)", text: $interview.notes)
                .textFieldStyle(.roundedBorder)
            
            Button(role: .destructive, action: onDelete) {
                Label("Remove Interview", systemImage: "minus.circle")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.red)
        }
        .padding(.vertical, 4)
    }
}

