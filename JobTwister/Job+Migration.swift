import Foundation
import SwiftData

extension Job {
    // Migration helper
    func migrateOldInterviewData() {
        // Only migrate if we have old data and no new interviews
        if hasInterview && interviews.isEmpty, let date = interviewDate {
            let interview = Interview(date: date)
            interviews = [interview]
            // Clear old data after migration
            hasInterview = false
            interviewDate = nil
            lastModified = Date()
        }
    }
    
    // Helper property for views still using old pattern
    var hasAnyInterview: Bool {
        !interviews.isEmpty
    }
    
    // Helper property for latest interview date
    var latestInterviewDate: Date? {
        interviews.max(by: { $0.date < $1.date })?.date
    }
}
