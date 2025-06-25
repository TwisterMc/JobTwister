import SwiftUI

struct JobListItemView: View {
    let job: Job
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(job.jobTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(job.companyName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    Text(job.dateApplied, format: .dateTime.month().day().year())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 4) {
                        if job.hasInterview {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundStyle(.green)
                        }
                        if job.isDenied {
                            Image(systemName: "xmark.circle")
                                .foregroundStyle(.red)
                        }
                        Text(job.workplaceType.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.quaternary.opacity(0.5))
                            .clipShape(Capsule())
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
