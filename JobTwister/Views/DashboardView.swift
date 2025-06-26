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
    let jobs: [Job]
    @State private var selectedTimeRange: TimeRange = .week
    @State private var offsetPeriods: Int = 0
    
    var filteredJobs: [JobEvent] {
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate the date range based on selected range and offset
        let endDate: Date
        let startDate: Date
        
        switch selectedTimeRange {
        case .week:
            endDate = calendar.date(byAdding: .weekOfYear, value: -offsetPeriods, to: now) ?? now
            startDate = calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate
        case .month:
            endDate = calendar.date(byAdding: .month, value: -offsetPeriods, to: now) ?? now
            startDate = calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        case .year:
            endDate = calendar.date(byAdding: .year, value: -offsetPeriods, to: now) ?? now
            startDate = calendar.date(byAdding: .day, value: -364, to: endDate) ?? endDate
        }
        
        // Create events for applications, interviews, and denials
        var events: [JobEvent] = []
        
        for job in jobs {
            // Add application event
            if job.dateApplied >= startDate && job.dateApplied <= endDate {
                events.append(JobEvent(date: job.dateApplied, type: .applied))
            }
            
            // Add interview events
            for interview in job.interviews {
                if interview.date >= startDate && interview.date <= endDate {
                    events.append(JobEvent(date: interview.date, type: .interviewed))
                }
            }
            
            // Add denial event
            if let deniedDate = job.deniedDate, deniedDate >= startDate && deniedDate <= endDate {
                events.append(JobEvent(date: deniedDate, type: .denied))
            }
        }
        
        return events.sorted(by: { $0.date < $1.date })
    }
    
    var periodStats: (applied: Int, interviewed: Int, denied: Int) {
        var stats = (applied: 0, interviewed: 0, denied: 0)
        
        for event in filteredJobs {
            switch event.type {
            case .applied:
                stats.applied += 1
            case .interviewed:
                stats.interviewed += 1
            case .denied:
                stats.denied += 1
            }
        }
        
        return stats
    }
    
    var dateRange: String {
        let calendar = Calendar.current
        let now = Date()
        let endDate: Date
        let startDate: Date
        
        switch selectedTimeRange {
        case .week:
            endDate = calendar.date(byAdding: .weekOfYear, value: -offsetPeriods, to: now) ?? now
            startDate = calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate
        case .month:
            endDate = calendar.date(byAdding: .month, value: -offsetPeriods, to: now) ?? now
            startDate = calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        case .year:
            endDate = calendar.date(byAdding: .year, value: -offsetPeriods, to: now) ?? now
            startDate = calendar.date(byAdding: .day, value: -364, to: endDate) ?? endDate
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = selectedTimeRange == .year ? "yyyy" : "MMM d, yyyy"
        
        if selectedTimeRange == .year {
            return formatter.string(from: startDate)
        }
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCardView(value: periodStats.applied, label: "Applications", systemImage: "paperplane", color: .blue)
                StatCardView(value: periodStats.interviewed, label: "Interviews", systemImage: "calendar.badge.clock", color: .green)
                StatCardView(value: periodStats.denied, label: "Denials", systemImage: "xmark.circle", color: .red)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Recent Activity")
                        .font(.headline)
                    
                    Spacer()
                    
                    Picker("", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedTimeRange) { _, _ in
                        offsetPeriods = 0
                    }
                }
                .padding(.horizontal)
                
                Chart {
                    ForEach(filteredJobs) { event in
                        BarMark(
                            x: .value("Date", event.date, unit: selectedTimeRange.unit),
                            y: .value("Events", 1)
                        )
                        .foregroundStyle(by: .value("Status", event.type.rawValue))
                    }
                    
                    if filteredJobs.isEmpty {
                        RectangleMark(
                            x: .value("Date", Date()),
                            y: .value("Events", 0)
                        )
                        .opacity(0)
                    }
                }
                .chartForegroundStyleScale([
                    "Applied": Color.blue,
                    "Interviewed": Color.green,
                    "Denied": Color.red
                ])
                .frame(height: 200)
                .padding()
                
                HStack {
                    Spacer()
                    Button(action: {
                        offsetPeriods += 1
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.borderless)
                    
                    Text(dateRange)
                        .font(.headline)
                        .frame(minWidth: 150)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        offsetPeriods = max(0, offsetPeriods - 1)
                    }) {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.borderless)
                    .disabled(offsetPeriods == 0)
                    Spacer()
                }
            }
        }
        .padding(.vertical)
    }
}

struct JobEvent: Identifiable {
    let id = UUID()
    let date: Date
    let type: EventType
    
    enum EventType: String {
        case applied = "Applied"
        case interviewed = "Interviewed"
        case denied = "Denied"
    }
}
