import SwiftUI
import Charts

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var unit: Calendar.Component {
        switch self {
        case .week: return .day
        case .month: return .day
        case .year: return .month
        }
    }
    
    var filterDays: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
}

struct DashboardView: View {
    let stats: (applied: Int, interviewed: Int, denied: Int)
    let jobs: [Job]
    @State private var selectedTimeRange: TimeRange = .week
    @State private var offsetPeriods: Int = 0
    
    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .week:
            // Get the start of the current week
            var current = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            // Move back to the start of the week by offset weeks
            current = calendar.date(byAdding: .weekOfYear, value: -offsetPeriods, to: current)!
            let end = calendar.date(byAdding: .day, value: 6, to: current)!
            return (current, end)
            
        case .month:
            // Get the start of the current month
            var components = calendar.dateComponents([.year, .month], from: now)
            // Move back by offset months
            components.month = components.month! - offsetPeriods
            let start = calendar.date(from: components)!
            let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start)!
            return (start, end)
            
        case .year:
            // Get the start of the current year
            var components = calendar.dateComponents([.year], from: now)
            // Move back by offset years
            components.year = components.year! - offsetPeriods
            let start = calendar.date(from: components)!
            let end = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: start)!
            return (start, end)
        }
    }
    
    var dateRangeText: String {
        let formatter = DateFormatter()
        
        switch selectedTimeRange {
        case .week:
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: dateRange.start)) - \(formatter.string(from: dateRange.end))"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: dateRange.start)
        case .year:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: dateRange.start)
        }
    }
    
    var filteredJobs: [Job] {
        jobs.filter { job in
            job.dateApplied >= dateRange.start && job.dateApplied <= dateRange.end
        }
        .sorted(by: { $0.dateApplied > $1.dateApplied })
    }
    
    var cumulativeJobs: [(date: Date, count: Int, status: String)] {
        var runningCount = 0
        return filteredJobs
            .sorted(by: { $0.dateApplied < $1.dateApplied })
            .map { job in
                runningCount += 1
                return (
                    date: job.dateApplied,
                    count: runningCount,
                    status: job.isDenied ? "Denied" :
                        (job.hasInterview ? "Interviewed" : "Applied")
                )
            }
    }
    
    var periodStats: (applied: Int, interviewed: Int, denied: Int) {
        var stats = (applied: 0, interviewed: 0, denied: 0)
        for job in filteredJobs {
            if job.isDenied {
                stats.denied += 1
            } else if job.hasInterview {
                stats.interviewed += 1
            } else {
                stats.applied += 1
            }
        }
        return stats
    }
    
    var chartContent: some View {
        Chart {
            ForEach(filteredJobs) { job in
                BarMark(
                    x: .value("Date", job.dateApplied, unit: selectedTimeRange.unit),
                    y: .value("Applications", 1)
                )
                .position(by: .value("Status",
                    job.isDenied ? "Denied" :
                    (job.hasInterview ? "Interviewed" : "Applied")
                ))
                .foregroundStyle(by: .value("Status",
                    job.isDenied ? "Denied" :
                    (job.hasInterview ? "Interviewed" : "Applied")
                ))
            }
        }
        .chartForegroundStyleScale([
            "Applied": Color.blue,
            "Interviewed": Color.green,
            "Denied": Color.red
        ])
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(values: .stride(by: selectedTimeRange.unit)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: selectedTimeRange == .year ?
                    .dateTime.month() : .dateTime.month().day()
                )
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Section
            Text("Job Search Dashboard")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 4)
            
            // Stats Section
            HStack(spacing: 16) {
                StatCardView(
                    value: periodStats.applied,
                    label: "Applications",
                    systemImage: "doc.text",
                    color: .blue
                )
                
                StatCardView(
                    value: periodStats.interviewed,
                    label: "Interviews",
                    systemImage: "person.2",
                    color: .green
                )
                
                StatCardView(
                    value: periodStats.denied,
                    label: "Denials",
                    systemImage: "xmark.circle",
                    color: .red
                )
            }
            
            if !jobs.isEmpty {
                // Chart Section
                VStack(alignment: .leading, spacing: 16) {
                    // Time Range Picker
                    Picker("", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue)
                                .font(.headline)
                                .tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedTimeRange) { _, _ in
                        offsetPeriods = 0
                    }
                    
                    // Chart
                    chartContent
                        .padding(.vertical, 8)
                    
                    // Time Navigation
                    HStack {
                        Spacer()
                        
                        Button(action: { offsetPeriods += 1 }) {
                            Image(systemName: "chevron.left")
                        }
                        .buttonStyle(.plain)
                        
                        Text(dateRangeText)
                            .font(.subheadline)
                            .frame(minWidth: 120)
                        
                        Button(action: {
                            offsetPeriods = max(0, offsetPeriods - 1)
                        }) {
                            Image(systemName: "chevron.right")
                        }
                        .buttonStyle(.plain)
                        .disabled(offsetPeriods == 0)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
