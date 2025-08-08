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
            // A job should be included if any of its events fall within the date range
            // Collect all relevant dates
            var dates = [job.dateApplied]
            
            // Add all interview dates
            dates.append(contentsOf: job.interviews.map { $0.date })
            
            // Add denial date if it exists
            if job.isDenied, let deniedDate = job.deniedDate {
                dates.append(deniedDate)
            }
            
            return dates.contains { date in
                date >= dateRange.start && date <= dateRange.end
            }
        }
        .sorted(by: {
            let date1 = $0.isDenied ? ($0.deniedDate ?? $0.dateApplied) : $0.dateApplied
            let date2 = $1.isDenied ? ($1.deniedDate ?? $1.dateApplied) : $1.dateApplied
            return date1 > date2
        })
    }
    
    struct JobEvent: Identifiable {
        let id = UUID()
        let date: Date
        let status: String
        let job: Job
    }
    
    var jobEvents: [JobEvent] {
        var events: [JobEvent] = []
        
        for job in filteredJobs {
            // Always add the application date
            events.append(JobEvent(date: job.dateApplied, status: "Applied", job: job))
            
            // Add interview date if it exists
            for interview in job.interviews {
                events.append(JobEvent(date: interview.date, status: "Interview", job: job))
            }
            
            // Add denial date if it exists
            if job.isDenied, let deniedDate = job.deniedDate {
                events.append(JobEvent(date: deniedDate, status: "Denied", job: job))
            }
        }
        
        return events.filter { event in
            event.date >= dateRange.start && event.date <= dateRange.end
        }
    }
    
    var periodStats: (applied: Int, interviewed: Int, denied: Int) {
        var stats = (applied: 0, interviewed: 0, denied: 0)
        let events = jobEvents
        
        for event in events {
            switch event.status {
            case "Applied": stats.applied += 1
            case "Interviewed": stats.interviewed += 1
            case "Denied": stats.denied += 1
            default: break
            }
        }
        return stats
    }
    
    var chartContent: some View {
        Chart {
            if jobEvents.isEmpty {
                // Add an invisible mark to force the chart to show axes
                RectangleMark(
                    x: .value("Date", dateRange.start, unit: selectedTimeRange.unit),
                    y: .value("Events", 1)
                )
                .opacity(0)
            } else {
                ForEach(jobEvents) { event in
                    BarMark(
                        x: .value("Date", event.date, unit: selectedTimeRange.unit),
                        y: .value("Events", 1)
                    )
                    .position(by: .value("Status", event.status))
                    .foregroundStyle(by: .value("Status", event.status))
                }
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
