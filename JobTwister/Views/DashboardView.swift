import SwiftUI
import Charts

struct DashboardView: View {
    let stats: (applied: Int, interviewed: Int, denied: Int)
    let jobs: [Job]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Job Search Dashboard")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack(spacing: 16) {
                    StatCardView(
                        value: stats.applied,
                        label: "Applications",
                        systemImage: "doc.text",
                        color: .blue
                    )
                    
                    StatCardView(
                        value: stats.interviewed,
                        label: "Interviews",
                        systemImage: "person.2",
                        color: .green
                    )
                    
                    StatCardView(
                        value: stats.denied,
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
    }
}
