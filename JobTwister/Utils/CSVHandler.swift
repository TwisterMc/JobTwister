import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

extension String {
    func escapingCSV() -> String {
        if self.contains(",") || self.contains("\"") || self.contains("\n") {
            return "\"\(self.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return self
    }
    
    func unescapingCSV() -> String {
        if self.hasPrefix("\"") && self.hasSuffix("\"") {
            let withoutQuotes = String(self.dropFirst().dropLast())
            return withoutQuotes.replacingOccurrences(of: "\"\"", with: "\"")
        }
        return self
    }
}

class CSVHandler {
    static func exportJobs(_ jobs: [Job]) -> String {
        let headers = ["Date Applied", "Company", "Title", "URL", "Salary Min", "Salary Max", "Has Interview", "Interview Date", "Is Denied", "Denied Date", "Notes", "Work Type", "Last Modified", "ID"]
        var rows = [headers.joined(separator: ",")]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for job in jobs {
            let row = [
                dateFormatter.string(from: job.dateApplied),
                job.companyName.escapingCSV(),
                job.jobTitle.escapingCSV(),
                job.url?.absoluteString ?? "",
                job.salaryMin?.description ?? "",
                job.salaryMax?.description ?? "",
                job.hasInterview.description,
                job.interviewDate.map { dateFormatter.string(from: $0) } ?? "",
                job.isDenied.description,
                job.deniedDate.map { dateFormatter.string(from: $0) } ?? "",
                job.notes.escapingCSV(),
                job.workplaceType.rawValue,
                dateFormatter.string(from: job.lastModified),
                job.id
            ]
            rows.append(row.joined(separator: ","))
        }
        
        return rows.joined(separator: "\n")
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
        
        // Pad array with empty strings if we don't have enough columns
        while columns.count < 9 {
            columns.append("")
        }
        
        let job = Job(
            dateApplied: parseDate(columns[7]) ?? Date(),
            companyName: columns[1].trimmingCharacters(in: .whitespaces),
            jobTitle: columns[2].trimmingCharacters(in: .whitespaces),
            hasInterview: columns[4].lowercased() == "true",
            isDenied: columns[5].lowercased() == "true",
            notes: columns[3].trimmingCharacters(in: .whitespaces),
            workplaceType: WorkplaceType(rawValue: columns[6]) ?? .remote
        )
        
        // If ID exists in CSV, use it, otherwise Job init will create a new one
        if !columns[0].isEmpty {
            job.id = columns[0]
        }
        
        job.lastModified = Date()
        return job
    }
    
    static func createJobFromCSV(_ row: [String], context: ModelContext) -> Job? {
        guard row.count >= 14 else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let job = Job()
        
        if let date = dateFormatter.date(from: row[0]) {
            job.dateApplied = date
        }
        
        job.companyName = row[1].unescapingCSV()
        job.jobTitle = row[2].unescapingCSV()
        if !row[3].isEmpty {
            job.url = URL(string: row[3])
        }
        if !row[4].isEmpty {
            job.salaryMin = Double(row[4])
        }
        if !row[5].isEmpty {
            job.salaryMax = Double(row[5])
        }
        job.hasInterview = row[6].lowercased() == "true"
        if !row[7].isEmpty {
            job.interviewDate = dateFormatter.date(from: row[7])
        }
        job.isDenied = row[8].lowercased() == "true"
        if !row[9].isEmpty {
            job.deniedDate = dateFormatter.date(from: row[9])
        }
        job.notes = row[10].unescapingCSV()
        job.workplaceType = WorkplaceType(rawValue: row[11]) ?? .remote
        if let date = dateFormatter.date(from: row[12]) {
            job.lastModified = date
        } else {
            job.lastModified = Date()
        }
        if !row[13].isEmpty {
            job.id = row[13]
        }
        
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
