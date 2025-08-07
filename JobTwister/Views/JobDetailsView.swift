import SwiftUI

struct JobDetailsView: View {
    @Bindable var job: Job
    
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSave: () -> Void
    
    // Create a computed property for URL string binding
    private var urlBinding: Binding<String> {
        Binding(
            get: { job.url?.absoluteString ?? "" },
            set: { newValue in
                if newValue.isEmpty {
                    job.url = nil
                } else {
                    job.url = URL(string: newValue)
                }
                job.lastModified = Date()
            }
        )
    }
    
    private var salaryMinBinding: Binding<Double> {
        Binding(
            get: { job.salaryMin ?? 0 },
            set: { newValue in
                job.salaryMin = newValue == 0 ? nil : newValue
                job.lastModified = Date()
            }
        )
    }

    private var salaryMaxBinding: Binding<Double> {
        Binding(
            get: { job.salaryMax ?? 0 },
            set: { newValue in
                job.salaryMax = newValue == 0 ? nil : newValue
                job.lastModified = Date()
            }
        )
    }
    
    private func dateBinding(for keyPath: ReferenceWritableKeyPath<Job, Date?>) -> Binding<Date> {
        Binding(
            get: { job[keyPath: keyPath] ?? Date() },
            set: { newValue in
                job[keyPath: keyPath] = newValue
                job.lastModified = Date()
            }
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    VStack(alignment: .leading) {
                        
                        
                        TextField("Job Title", text: $job.jobTitle)
                            .font(.title)
                            .fontWeight(.semibold)
                            .textFieldStyle(.plain)
                            .focusAwareStyle()
                        
                        TextField("Company Name", text: $job.companyName)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .textFieldStyle(.plain)
                            .focusAwareStyle()
                        
                        
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        //                        Button(action: onSave) {
                        //                            Label("Save", systemImage: "checkmark.circle")
                        //                        }
                        //                        .buttonStyle(.bordered)
                        
//                        Button(action: onEdit) {
//                            Label("Edit", systemImage: "pencil")
//                        }
//                        .buttonStyle(.bordered)
                        
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                
                
                Form {
                    Section {
                        DatePicker(selection: $job.dateApplied, displayedComponents: .date) {
                                            Label("Date Applied", systemImage: "calendar")
                                        }
                        
                        HStack {
                            Image(systemName: "link")
                            TextField("Job URL", text: urlBinding)
                                .textFieldStyle(.plain)
                                        .multilineTextAlignment(.leading)
                                   .focusAwareStyle()
                            // Show link button if URL is valid
                            if let url = job.url {
                                Button(action: {
                                    NSWorkspace.shared.open(url)
                                }) {
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(.accentColor)
                                }
                                .buttonStyle(.plain)
                                .help("Open in browser")
                            }
                        }
                        
                        HStack {
                            Image(systemName: "dollarsign.circle")
                            TextField("Min Salary", value: salaryMinBinding, format: .currency(code: "USD")).focusAwareStyle()
                            Text("-")
                            TextField("Max Salary", value: salaryMaxBinding, format: .currency(code: "USD")).focusAwareStyle()
                        }
                        
                        Picker(selection: $job.workplaceType, label: Label("Work Type", systemImage: "building.2")) {
                            ForEach([WorkplaceType.remote, .hybrid, .inOffice], id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                                       
        
                    }
                    
                    Section("Status") {
                        Toggle(isOn: $job.hasInterview) {
                            Label("Has Interview", systemImage: "calendar.badge.clock")
                        }
                        .toggleStyle(.switch)
                        .onChange(of: job.hasInterview) { oldValue, newValue in
                            if newValue && job.interviewDate == nil {
                                job.interviewDate = Date()
                            }
                            job.lastModified = Date()
                        }
                        
                        if job.hasInterview {
                            DatePicker("Interview Date", selection: dateBinding(for: \.interviewDate))
                                .padding(.leading, 40)
                        }
                        
                        Toggle(isOn: Binding(
                            get: { job.isDenied },
                            set: { newValue in
                                job.isDenied = newValue
                                job.deniedDate = newValue ? Date() : nil
                                job.lastModified = Date()
                            }
                        )) {
                            Label("Application Denied", systemImage: "xmark.circle")
                        }
                        .toggleStyle(.switch)
                        
                        if job.isDenied {
                            DatePicker("Denied Date", selection: dateBinding(for: \.deniedDate))
                                .padding(.leading, 40)
                        }
                        
                        
                    }
                    
                    
                                           
                    
                   
                        Section() {
                            Label("Notes", systemImage: "note.text")
                            TextEditor(text: $job.notes)
                                               .scrollContentBackground(.hidden)
                                                           .padding(5)
                                                           .frame(height: 150)
                                                           .cornerRadius(8)
                                                           .focusAwareStyle()
                        }
                    }
                
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)
            }
            .onTapGesture {
                        // Dismiss focus when clicking outside fields on macOS
                        NSApp.keyWindow?.makeFirstResponder(nil)
                    }
        }
    }
}
