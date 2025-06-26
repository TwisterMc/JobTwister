import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers


class CSVHandler {
    static func exportJobs(_ jobs: [Job]) -> String {
        let header = "Company Name,Job Title,Notes,Has Interview,Is Denied,Work Type,Date Applied,Last Modified\n"
        let rows = jobs.map { job in
            "\(job.companyName),\(job.jobTitle),\"\(job.notes.replacingOccurrences(of: "\"", with: "\"\""))\",\(job.hasInterview),\(job.isDenied),\(job.workplaceType.rawValue),\(formatDate(job.dateApplied)),\(formatDate(job.lastModified))"
        }.joined(separator: "\n")
        return header + rows
    }
    
    static func importJobs(from csv: String) -> [Job] {
        var jobs: [Job] = []
        let rows = csv.components(separatedBy: .newlines)
        
        // Skip header row
        if rows.count > 1 {
            for row in rows.dropFirst() where !row.isEmpty {
                if let job = createJobFromCSV(row) {
                    jobs.append(job)
                }
            }
        }
        
        return jobs
    }
    
    private static func createJobFromCSV(_ row: String) -> Job? {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false
        
        for char in row {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                columns.append(currentColumn)
                currentColumn = ""
            } else {
                currentColumn.append(char)
            }
        }
        columns.append(currentColumn)
        
        guard columns.count >= 8 else { return nil }
        
        let job = Job(
            dateApplied: parseDate(columns[6]) ?? Date(),
            companyName: columns[0].trimmingCharacters(in: .whitespaces),
            jobTitle: columns[1].trimmingCharacters(in: .whitespaces),
            hasInterview: Bool(columns[3]) ?? false,
            isDenied: Bool(columns[4]) ?? false,
            notes: columns[2].trimmingCharacters(in: .whitespaces),
            workplaceType: WorkplaceType(rawValue: columns[5]) ?? .remote
        )
        job.lastModified = Date()  // Set lastModified to current date when importing
        return job
    }
    
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private static func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // If parsing fails, try ISO8601 as fallback
        if let date = formatter.date(from: dateString) {
            return Calendar.current.startOfDay(for: date)
        }
        
        let iso8601Formatter = ISO8601DateFormatter()
        if let date = iso8601Formatter.date(from: dateString) {
            return Calendar.current.startOfDay(for: date)
        }
        
        return nil
    }
}
