import SwiftUI

struct JobDetailsView: View {
    @Bindable var job: Job
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddInterview = false
    @State private var interviewDate = Date()
    @State private var interviewNotes = ""
    var onEdit: () -> Void
    var onDelete: () -> Void
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text(job.jobTitle)
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text(job.companyName)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    .buttonStyle(.link)
                    
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                    .buttonStyle(.borderless)
                    .tint(.red)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            Form {
                Section {
                    DetailRow(title: "Date Applied", value: job.dateApplied.formatted(date: .long, time: .omitted))
                    
                    if let url = job.url {
                        HStack {
                            Text("Job URL").bold()
                            Link(url.absoluteString, destination: url)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                    
                    if let salaryMin = job.salaryMin, let salaryMax = job.salaryMax {
                        DetailRow(title: "Salary", value: formatSalary(salaryMin, salaryMax))
                    }
                    
                    DetailRow(title: "Work Type", value: job.workplaceType.rawValue)
                }
                
                Section("Status") {
                    Toggle("Has Interview", isOn: Binding(
                        get: { job.hasInterview },
                        set: { newValue in
                            if newValue && !job.hasInterview {
                                showingAddInterview = true
                            } else if !newValue && job.hasInterview {
                                job.interviews.removeAll()
                                job.lastModified = Date()
                            }
                        }
                    ))
                        .toggleStyle(.switch)
                    
                    if job.hasInterview, let date = job.latestInterviewDate {
                        DetailRow(title: "Latest Interview", value: date.formatted(date: .long, time: .shortened))
                    }
                    
                    Toggle("Application Denied", isOn: Binding(
                        get: { job.isDenied },
                        set: { newValue in
                            job.isDenied = newValue
                            job.deniedDate = newValue ? Date() : nil
                            job.lastModified = Date()
                        }
                    ))
                    .toggleStyle(.switch)
                    
                    if job.isDenied, let date = job.deniedDate {
                        DetailRow(title: "Denied Date", value: date.formatted(date: .long, time: .omitted))
                    }
                }
                
                Section("Interviews") {
                    ForEach(job.interviews.sorted(by: { $0.date > $1.date })) { interview in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Round \(interview.round)")
                                .font(.headline)
                            Text(interview.date.formatted(date: .long, time: .omitted))
                                .foregroundStyle(.secondary)
                            if !interview.notes.isEmpty {
                                Text(interview.notes)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        let sortedInterviews = job.interviews.sorted(by: { $0.date > $1.date })
                        indexSet.forEach { index in
                            if let interviewToDelete = job.interviews.first(where: { $0.id == sortedInterviews[index].id }) {
                                job.interviews.removeAll(where: { $0.id == interviewToDelete.id })
                            }
                        }
                        job.lastModified = Date()
                    }
                    
                    Button(action: {
                        showingAddInterview = true
                    }) {
                        Label("Add Interview", systemImage: "plus")
                    }
                }
                
                if !job.notes.isEmpty {
                    Section("Notes") {
                        Text(job.notes)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(8)
                    }
                }
            }
            .formStyle(.grouped)
        }
        .sheet(isPresented: $showingAddInterview) {
            NavigationStack {
                Form {
                    DatePicker("Interview Date", selection: $interviewDate, displayedComponents: [.date, .hourAndMinute])
                    TextField("Interview Notes", text: $interviewNotes)
                        .textFieldStyle(.roundedBorder)
                }
                .onAppear {
                    // Initialize with current date and empty notes when sheet opens
                    interviewDate = Date()
                    interviewNotes = ""
                }
                .navigationTitle("Add Interview")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            interviewDate = Date()
                            interviewNotes = ""
                            showingAddInterview = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            // Calculate next round number
                            let nextRound = (job.interviews.map(\.round).max() ?? 0) + 1
                            
                            // Create and add the new interview
                            let newInterview = Interview(
                                date: interviewDate,
                                notes: interviewNotes.trimmingCharacters(in: .whitespacesAndNewlines),
                                round: nextRound
                            )
                            job.interviews.append(newInterview)
                            
                            // Update job
                            job.lastModified = Date()
                            
                            // Reset and close
                            interviewDate = Date()
                            interviewNotes = ""
                            showingAddInterview = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}
