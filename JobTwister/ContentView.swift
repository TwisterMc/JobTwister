import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Job.dateApplied, order: .reverse) private var jobs: [Job]
    @State private var selectedJob: Job?
    @State private var showingAddJob = false
    @State private var searchText = ""
    
    var filteredJobs: [Job] {
        if searchText.isEmpty {
            return jobs
        } else {
            return jobs.filter { job in
                job.companyName.localizedCaseInsensitiveContains(searchText) ||
                job.jobTitle.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var applicationStats: (applied: Int, interviewed: Int, denied: Int) {
        let interviewed = jobs.filter { $0.hasInterview }.count
        let denied = jobs.filter { $0.isDenied }.count
        return (jobs.count, interviewed, denied)
    }

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(filteredJobs) { job in
                    Button(action: {
                        selectedJob = job
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(job.jobTitle)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(job.companyName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 8) {
                                    Text(job.dateApplied, format: .dateTime.month().day().year())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    
                                    Text(job.workplaceType.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(workplaceTypeColor(job.workplaceType).opacity(0.2))
                                        )
                                        .foregroundColor(workplaceTypeColor(job.workplaceType))
                                }
                                HStack(spacing: 8) {
                                    
                                    if job.hasInterview {
                                        Label("Interview", systemImage: "calendar.badge.clock")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                    
                                    if job.isDenied {
                                        Label("Denied", systemImage: "xmark.circle")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                    
                                    
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity)
                        .background(selectedJob?.id == job.id ? Color.accentColor.opacity(0.1) : Color.accentColor.opacity(0))
                        .cornerRadius(8)
                        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                            return -viewDimensions.width
                        }
                    }
                    .buttonStyle(.borderless)
                }
            }
            .listStyle(.plain)
            .id(UUID())  // This forces the List to recreate and scroll to top when data changes
            .searchable(text: $searchText, prompt: "Search jobs...")
            .navigationTitle("Job Applications")
            .toolbar {
                // Place each button in its own ToolbarItem for better visibility on macOS
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        selectedJob = nil // Show dashboard when chart button is tapped
                    } label: {
                        Image(systemName: "chart.bar.fill")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        selectedJob = nil // Ensure no job is selected when adding a new one
                        showingAddJob.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        } detail: {
            ScrollView {
                if selectedJob == nil {
                    VStack(spacing: 0) {
                        // Dashboard summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Job Search Dashboard")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 16) {
                                StatCardView(
                                    value: applicationStats.applied,
                                    label: "Applications",
                                    systemImage: "doc.text",
                                    color: .blue
                                )
                                
                                StatCardView(
                                    value: applicationStats.interviewed,
                                    label: "Interviews",
                                    systemImage: "person.2",
                                    color: .green
                                )
                                
                                StatCardView(
                                    value: applicationStats.denied,
                                    label: "Denials",
                                    systemImage: "xmark.circle",
                                    color: .red
                                )
                            }
                            
                            if !jobs.isEmpty {
                                VStack(alignment: .leading) {
                                    Text("Recent Activity")
                                        .font(.headline)
                                        .padding(.top)
                                    
                                    Chart(jobs.prefix(5)) { job in
                                        BarMark(
                                            x: .value("Date", job.dateApplied, unit: .day),
                                            y: .value("Applications", 1)
                                        )
                                        .foregroundStyle(by: .value("Status", job.hasInterview ? "Interviewed" : (job.isDenied ? "Denied" : "Applied")))
                                    }
                                    .chartForegroundStyleScale([
                                        "Applied": Color.blue,
                                        "Interviewed": Color.green,
                                        "Denied": Color.red
                                    ])
                                    .frame(height: 200)
                                    .chartXAxis {
                                        AxisMarks(values: .stride(by: .day)) { _ in
                                            AxisGridLine()
                                            AxisTick()
                                            AxisValueLabel(format: .dateTime.month().day())
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    // Show job details view
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(selectedJob!.jobTitle)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                
                                Text(selectedJob!.companyName)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    showingAddJob = true
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .buttonStyle(.link)
                                
                                Button(role: .destructive, action: {
                                    if let selectedJob = selectedJob {
                                        modelContext.delete(selectedJob)
                                        try? modelContext.save()
                                        self.selectedJob = nil
                                    }
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                .buttonStyle(.borderless)
                                .tint(.red)
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        
                        Divider()
                        
                        // Job details in a form
                        Form {
                            Section {
                                DetailRow(title: "Date Applied", value: selectedJob!.dateApplied.formatted(date: .long, time: .omitted))
                                
                                if let url = selectedJob!.url {
                                    HStack {
                                        Text("Job URL").bold()
                                        Link(url.absoluteString, destination: url)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                    }
                                }
                                
                                if let salaryMin = selectedJob!.salaryMin, let salaryMax = selectedJob!.salaryMax {
                                    DetailRow(title: "Salary", value: formatSalary(salaryMin, salaryMax))
                                }
                                
                                DetailRow(title: "Work Type", value: selectedJob!.workplaceType.rawValue)
                                    
                            }
                            
                            Section("Status") {
                                Toggle("Has Interview", isOn: Binding(
                                    get: { selectedJob!.hasInterview },
                                    set: {
                                        selectedJob!.hasInterview = $0
                                        try? modelContext.save()
                                    }
                                ))
                                .toggleStyle(.switch)
                                
                                if selectedJob!.hasInterview, let date = selectedJob!.interviewDate {
                                    DetailRow(title: "Interview Date", value: date.formatted(date: .long, time: .shortened))
                                }
                                
                                Toggle("Application Denied", isOn: Binding(
                                    get: { selectedJob!.isDenied },
                                    set: {
                                        selectedJob!.isDenied = $0
                                        try? modelContext.save()
                                    }
                                ))
                                .toggleStyle(.switch)
                            }
                            
                            if !selectedJob!.notes.isEmpty {
                                Section("Notes") {
                                    Text(selectedJob!.notes)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color(NSColor.textBackgroundColor))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .formStyle(.grouped)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .sheet(isPresented: $showingAddJob) {
            NavigationStack {
                JobFormView(job: showingAddJob && selectedJob != nil ? selectedJob : nil)
                    .navigationTitle(selectedJob == nil ? "New Job Application" : "Edit Job")
                    .frame(minWidth: 500, minHeight: 650)
            }
        }
    }
    
    private func workplaceTypeColor(_ type: WorkplaceType) -> Color {
        switch type {
        case .remote:
            return .blue
        case .hybrid:
            return .purple
        case .inOffice:
            return .orange
        }
    }
    
    private func deleteJobs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredJobs[index])
            }
            try? modelContext.save()
        }
    }
    
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
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .bold()
                .frame(width: 120, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}

struct StatCardView: View {
    let value: Int
    let label: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text("\(value)")
                    .font(.title)
                    .fontWeight(.semibold)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// Rest of the JobFormView remains unchanged
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
            }
            
            Section("Details") {
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
            }
            
            Section("Notes") {
                TextEditor(text: $notes)
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
            existingJob.notes = notes
            existingJob.workplaceType = workplaceType
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
                notes: notes,
                workplaceType: workplaceType
            )
            modelContext.insert(newJob)
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Job.self, inMemory: true)
}
