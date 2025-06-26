import SwiftUI
import SwiftData

struct JobFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let job: Job?
    @State private var dateApplied: Date
    @State private var companyName: String
    @State private var jobTitle: String
    @State private var urlString: String
    @State private var salaryMin: Double?
    @State private var salaryMax: Double?
    @State private var hasInterview: Bool
    @State private var interviewDate: Date
    @State private var isDenied: Bool
    @State private var deniedDate: Date?
    @State private var notes: String
    @State private var workplaceType: WorkplaceType
    
    init(job: Job?) {
        self.job = job
        _dateApplied = State(initialValue: job?.dateApplied ?? Date())
        _companyName = State(initialValue: job?.companyName ?? "")
        _jobTitle = State(initialValue: job?.jobTitle ?? "")
        _urlString = State(initialValue: job?.url?.absoluteString ?? "")
        _salaryMin = State(initialValue: job?.salaryMin)
        _salaryMax = State(initialValue: job?.salaryMax)
        _hasInterview = State(initialValue: job?.hasInterview ?? false)
        _interviewDate = State(initialValue: job?.interviewDate ?? Date())
        _isDenied = State(initialValue: job?.isDenied ?? false)
        _deniedDate = State(initialValue: job?.deniedDate)
        _notes = State(initialValue: job?.notes ?? "")
        _workplaceType = State(initialValue: job?.workplaceType ?? .remote)
    }
    
    var body: some View {
        Form {
            Section("Basic Information") {
                DatePicker("Date Applied", selection: $dateApplied, displayedComponents: .date)
                TextField("Company Name", text: $companyName)
                TextField("Job Title", text: $jobTitle)
                TextField("Job URL", text: $urlString)
                HStack {
                    TextField("Minimum Salary", value: $salaryMin, format: .currency(code: "USD"))
                    Text("-")
                    TextField("Maximum Salary", value: $salaryMax, format: .currency(code: "USD"))
                }
                Picker("Work Type", selection: $workplaceType) {
                    ForEach([WorkplaceType.remote, .hybrid, .inOffice], id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
            }
            
            

            
            
            Section("Status") {
                Toggle("Has Interview", isOn: $hasInterview)
                    .toggleStyle(.switch)
                
                if hasInterview {
                    DatePicker("Interview Date", selection: $interviewDate)
                }
                
                Toggle("Application Denied", isOn: $isDenied)
                    .toggleStyle(.switch)
                
                if isDenied {
                    DatePicker("Denied Date", selection: Binding(
                        get: { deniedDate ?? Date() },
                        set: { deniedDate = $0 }
                    ), displayedComponents: [.date])
                }
            }
            
            Section("Notes") {
                TextEditor(text: $notes)
                    .padding(10)
                    .frame(height: 150)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
            }
            .background(Color.white)
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
    }
    
    private func save() {
        let url = URL(string: urlString)
        
        if let existingJob = job {
            existingJob.dateApplied = dateApplied
            existingJob.companyName = companyName
            existingJob.jobTitle = jobTitle
            existingJob.url = url
            existingJob.salaryMin = salaryMin
            existingJob.salaryMax = salaryMax
            existingJob.hasInterview = hasInterview
            existingJob.interviewDate = hasInterview ? interviewDate : nil
            existingJob.isDenied = isDenied
            existingJob.deniedDate = isDenied ? deniedDate : nil
            existingJob.notes = notes
            existingJob.workplaceType = workplaceType
            existingJob.lastModified = Date()
            try? modelContext.save()
        } else {
            let newJob = Job(
                dateApplied: dateApplied,
                companyName: companyName,
                jobTitle: jobTitle,
                url: url,
                salaryMin: salaryMin,
                salaryMax: salaryMax,
                hasInterview: hasInterview,
                interviewDate: hasInterview ? interviewDate : nil,
                isDenied: isDenied,
                deniedDate: isDenied ? deniedDate : nil,
                notes: notes,
                workplaceType: workplaceType
            )
            modelContext.insert(newJob)
            try? modelContext.save()
        }
    }
}
