import SwiftUI

struct JobDetailsView: View {
    let job: Job
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
                    Toggle("Has Interview", isOn: .constant(job.hasInterview))
                        .toggleStyle(.switch)
                        .disabled(true)
                    
                    if job.hasInterview, let date = job.interviewDate {
                        DetailRow(title: "Interview Date", value: date.formatted(date: .long, time: .shortened))
                    }
                    
                    Toggle("Application Denied", isOn: .constant(job.isDenied))
                        .toggleStyle(.switch)
                        .disabled(true)
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
    }
}
