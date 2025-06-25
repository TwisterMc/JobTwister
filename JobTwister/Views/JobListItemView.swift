import SwiftUI

struct JobListItemView: View {
    let job: Job
    let isSelected: Bool
    
    var body: some View {
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
                        .foregroundStyle(.secondary)
                    
                    Text(job.workplaceType.rawValue)
                        .font(.caption)
                                                               .padding(.horizontal, 6)
                                                               .padding(.vertical, 2)
                                                               .background(
                                                                   RoundedRectangle(cornerRadius: 4)
                                                                       .fill(Color.workplaceTypeColor(job.workplaceType).opacity(0.2))
                                                               )
                                                               .foregroundColor(Color.workplaceTypeColor(job.workplaceType))
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
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
