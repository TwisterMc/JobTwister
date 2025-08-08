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

extension String.Iterator {
    mutating func peek() -> Character? {
        var copy = self
        return copy.next()
    }
}

class CSVHandler {
    static func exportJobs(_ jobs: [Job]) -> String {
        let headers = ["Date Applied", "Company", "Title", "URL", "Salary Min", "Salary Max", "Interview Dates", "Is Denied", "Denied Date", "Notes", "Work Type", "Last Modified", "ID"]
        var rows = [headers.joined(separator: ",")]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for job in jobs {
            let interviewDates = job.interviews
                .map { dateFormatter.string(from: $0.date) }
                .joined(separator: ";")
                .escapingCSV()
            
            let row = [
                dateFormatter.string(from: job.dateApplied),
                job.companyName.escapingCSV(),
                job.jobTitle.escapingCSV(),
                job.url?.absoluteString ?? "",
                job.salaryMin?.description ?? "",
                job.salaryMax?.description ?? "",
                interviewDates,
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
        let rows = csv.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        // Skip header row
        if rows.count > 1 {
            for row in rows.dropFirst() {
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
        var iterator = row.makeIterator()
        
        while let char = iterator.next() {
            if char == "\"" {
                if insideQuotes {
                    if let nextChar = iterator.peek(), nextChar == "\"" {
                        _ = iterator.next() // consume second quote
                        currentColumn.append("\"")
                    } else {
                        insideQuotes = false
                    }
                } else {
                    insideQuotes = true
                }
            } else if char == "," && !insideQuotes {
                columns.append(currentColumn)
                currentColumn = ""
            } else {
                currentColumn.append(char)
            }
        }
        columns.append(currentColumn)
        
        return createJobFromCSV(columns)
    }
    
    static func createJobFromCSV(_ row: [String]) -> Job? {
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
        
        // Handle interview dates
        let interviewDatesStr = row[6].unescapingCSV()
        if !interviewDatesStr.isEmpty {
            let dateStrings = interviewDatesStr.split(separator: ";")
            for dateStr in dateStrings {
                if let date = dateFormatter.date(from: String(dateStr)) {
                    let interview = Interview(date: date)
                    job.interviews.append(interview)
                }
            }
        }
        
        job.isDenied = row[7].lowercased() == "true"
        if !row[8].isEmpty {
            job.deniedDate = dateFormatter.date(from: row[8])
        }
        job.notes = row[9].unescapingCSV()
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
