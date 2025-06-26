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
        } else if let max = max {
            // If min is nil but max exists, default min to 0
            return "\(formatter.string(from: NSNumber(value: 0)) ?? "$0") - \(formatter.string(from: NSNumber(value: max)) ?? "$\(Int(max))")"
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
                        .buttonStyle(.bordered)

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
                        DetailRow(title: "Date Applied", value: job.dateApplied.formatted(date: .long, time: .omitted))
                            .icon("calendar")

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
                            .icon("link")
                        }

                        // --- MODIFIED SECTION BELOW ---
                        // We still call formatSalary with the optional values
                        // but now the condition for showing the row is less strict.
                        if job.salaryMin != nil || job.salaryMax != nil {
                            DetailRow(title: "Salary", value: formatSalary(job.salaryMin, job.salaryMax))
                                .icon("dollarsign.circle")
                        }
                        // --- END MODIFIED SECTION ---

                        DetailRow(title: "Work Type", value: job.workplaceType.rawValue)
                            .icon("building.2")
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

                        if job.hasInterview, let date = job.interviewDate {
                            DetailRow(title: "Interview Date", value: date.formatted(date: .long, time: .shortened))
                                .bold(false)
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

                        if job.isDenied, let date = job.deniedDate {
                            DetailRow(title: "Denied Date", value: date.formatted(date: .long, time: .omitted))
                                .bold(false)
                                .padding(.leading, 40)
                        }
                    }

                    if !job.notes.isEmpty {
                        Section() {
                            Label("Notes", systemImage: "note.text")
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
