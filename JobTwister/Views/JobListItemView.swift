import SwiftUI

struct JobListItemView: View {
    @Bindable var job: Job
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(job.jobTitle)
                .font(.headline)
            Text(job.companyName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 4) {
                if job.isDenied {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.red)
                }
                if !job.interviews.isEmpty {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(.green)
                    Text("\(job.interviews.count)")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                Spacer()
                Text(job.workplaceType.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.workplaceTypeColor(job.workplaceType))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
