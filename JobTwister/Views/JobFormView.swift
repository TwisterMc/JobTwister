import SwiftUI
import SwiftData

struct JobFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var job: Job
    @State private var showingAddInterview = false
    
    // New interview state
    @State private var newInterviewDate = Date()
    @State private var newInterviewNotes = ""
    
    init(job: Job?) {
        self.job = job ?? Job()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    DatePicker("Date Applied", selection: $job.dateApplied, displayedComponents: .date)
                    TextField("Company Name", text: $job.companyName)
                    TextField("Job Title", text: $job.jobTitle)
                    TextField("Job URL", text: Binding(
                        get: { job.url?.absoluteString ?? "" },
                        set: { job.url = URL(string: $0) }
                    ))
                }
                
                Section("Details") {
                    HStack {
                        TextField("Minimum Salary", value: $job.salaryMin, format: .currency(code: "USD"))
                        Text("-")
                        TextField("Maximum Salary", value: $job.salaryMax, format: .currency(code: "USD"))
                    }
                    Picker("Work Type", selection: $job.workplaceType) {
                        ForEach([WorkplaceType.remote, .hybrid, .inOffice], id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Status") {
                    Toggle("Application Denied", isOn: $job.isDenied)
                        .toggleStyle(.switch)
                    
                    if job.isDenied {
                        DatePicker("Denied Date", selection: Binding(
                            get: { editedJob.deniedDate ?? Date() },
                            set: { job.deniedDate = $0 }
                        ), displayedComponents: [.date])
                    }
                }
                
                Section {
                    let sortedInterviews = job.interviews.sorted { $0.date > $1.date }
                    ForEach(sortedInterviews, id: \.id) { interview in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Round \(interview.round)")
                                    .font(.headline)
                                Spacer()
                                Text(interview.date.formatted(date: .abbreviated, time: .shortened))
                                    .foregroundStyle(.secondary)
                            }
                            if !interview.notes.isEmpty {
                                Text(interview.notes)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)
                            }
                        }
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button(role: .destructive) {
                                modelContext.delete(interview)
                                job.interviews.removeAll(where: { $0.id == interview.id })
                                job.lastModified = Date()
                                try? modelContext.save()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    
                    Button(action: {
                        showingAddInterview = true
                    }) {
                        Label("Add Interview", systemImage: "plus")
                    }
                } header: {
                    Label("Interviews (\(editedJob.interviews.count))", systemImage: "calendar")
                }
                }
                
                Section("Notes") {
                    TextEditor(text: $editedJob.notes)
                        .frame(height: 150)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .formStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddInterview) {
                NavigationStack {
                    Form {
                        DatePicker("Interview Date", selection: $newInterviewDate, displayedComponents: [.date, .hourAndMinute])
                        TextField("Interview Notes", text: $newInterviewNotes)
                            .textFieldStyle(.roundedBorder)
                    }
                    .navigationTitle("Add Interview")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                newInterviewDate = Date()
                                newInterviewNotes = ""
                                showingAddInterview = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                let nextRound = (job.interviews.map(\.round).max() ?? 0) + 1
                                let newInterview = Interview(
                                    date: newInterviewDate,
                                    notes: newInterviewNotes.trimmingCharacters(in: .whitespacesAndNewlines),
                                    round: nextRound
                                )
                                // No need to insert interview individually since it will be tracked via the job
                                editedJob.interviews.append(newInterview)
                                editedJob.lastModified = Date()
                                try? modelContext.save()
                                
                                newInterviewDate = Date()
                                newInterviewNotes = ""
                                showingAddInterview = false
                            }
                        }
                    }
                }
                .frame(idealWidth: 400, idealHeight: 300)
                .presentationDetents([.medium])
            }
        }
    }
    
    private func save() {
        withAnimation {
            job.lastModified = Date()
            
            if !modelContext.hasChanges(for: job) {
                modelContext.insert(job)
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving job: \(error.localizedDescription)")
            }
        }
    }
}
