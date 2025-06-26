import SwiftUI

struct JobDetailsView: View {
    @Bindable var job: Job
    let onEdit: () -> Void
    let onDelete: () -> Void
    
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
        ScrollView {
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
                
                Divider()
                
                Form {
                    Section {
                        DetailRow(title: "Date Applied", value: job.dateApplied.formatted(date: .long, time: .omitted))
                        
                        if let url = job.url {
                            DetailRow(
                                title: "Job URL",
                                value: "",
                                content: {
                                    Link(url.absoluteString, destination: url)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }
                            )
                        }
                        
                        if let salaryMin = job.salaryMin, let salaryMax = job.salaryMax {
                            DetailRow(title: "Salary", value: formatSalary(salaryMin, salaryMax))
                        }
                        
                        DetailRow(title: "Work Type", value: job.workplaceType.rawValue)
                    }
                    
                    Section("Status") {
                        Toggle("Has Interview", isOn: $job.hasInterview)
                            .toggleStyle(.switch)
                            .onChange(of: job.hasInterview) { oldValue, newValue in
                                job.lastModified = Date()
                            }
                        
                        if job.hasInterview, let date = job.interviewDate {
                            DetailRow(title: "Interview Date", value: date.formatted(date: .long, time: .shortened))
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
                    
                    if !job.notes.isEmpty {
                        Section("Notes") {
                            Text(job.notes)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                
                                .cornerRadius(8)
                        }
                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)
            }
        }
    }
}
