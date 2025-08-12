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
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
        
        for job in jobs {
            let interviewDates = job.interviews
                .map { interview in
                    let dateStr = dateFormatter.string(from: interview.date)
                    let notesStr = interview.notes.isEmpty ? "(no notes)" : interview.notes
                    return "\(dateStr) - \(notesStr)"
                }
                .joined(separator: " | ")
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
    
    static func importJobs(from csv: String, context: ModelContext) -> [Job] {
        var jobs: [Job] = []
        let rows = csv.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        if rows.count > 1 {
            for row in rows.dropFirst() {
                if let newJob = createJobFromCSV(row) {
                    let jobId = newJob.id
                    let descriptor = FetchDescriptor<Job>(
                        predicate: #Predicate<Job> { job in
                            job.id == jobId
                        }
                    )
                    
                    do {
                        let existingJobs = try context.fetch(descriptor)
                        if let existingJob = existingJobs.first {
                            // Update existing job properties
                            existingJob.dateApplied = newJob.dateApplied
                            existingJob.companyName = newJob.companyName
                            existingJob.jobTitle = newJob.jobTitle
                            existingJob.url = newJob.url
                            existingJob.salaryMin = newJob.salaryMin
                            existingJob.salaryMax = newJob.salaryMax
                            existingJob.isDenied = newJob.isDenied
                            existingJob.deniedDate = newJob.deniedDate
                            existingJob.notes = newJob.notes
                            existingJob.workplaceType = newJob.workplaceType
                            existingJob.lastModified = newJob.lastModified
                            
                            // Update interviews
                            existingJob.interviews.removeAll()
                            existingJob.interviews.append(contentsOf: newJob.interviews)
                            
                            jobs.append(existingJob)
                        } else {
                            // Insert new job
                            context.insert(newJob)
                            jobs.append(newJob)
                        }
                    } catch {
                        print("Error fetching job: \(error)")
                        context.insert(newJob)
                        jobs.append(newJob)
                    }
                }
            }
        }
        
        // Save the context to persist changes
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
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
        
        return createJobFromCSVColumns(columns)
    }
    
    static func createJobFromCSVColumns(_ row: [String]) -> Job? {
        guard row.count >= 11 else {
            print("Row has insufficient columns: \(row.count)")
            return nil
        }
        
        let job = Job()
        
        // Parse date applied with flexible format
        job.dateApplied = parseFlexibleDate(row[0]) ?? Date()
        
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
            let interviews = interviewDatesStr.split(separator: " | ")
            for interview in interviews {
                if let dashIndex = interview.firstIndex(of: "-") {
                    let dateStr = String(interview[..<dashIndex]).trimmingCharacters(in: .whitespaces)
                    let notesStr = String(interview[interview.index(after: dashIndex)...])
                        .trimmingCharacters(in: .whitespaces)
                    
                    if let date = parseFlexibleDate(dateStr) {
                        let interviewObj = Interview()
                        interviewObj.date = date
                        interviewObj.notes = notesStr == "(no notes)" ? "" : notesStr
                        job.interviews.append(interviewObj)
                    }
                }
            }
        }
        
        job.isDenied = row[7].lowercased() == "true"
        
        if !row[8].isEmpty {
            job.deniedDate = parseFlexibleDate(row[8])
        }
        
        // Handle notes (row 9, but check if it exists)
        if row.count > 9 {
            job.notes = row[9].unescapingCSV()
        }
        
        // Handle work type (row 10, but check if it exists)
        if row.count > 10 {
            job.workplaceType = WorkplaceType(rawValue: row[10]) ?? .remote
        } else {
            job.workplaceType = .remote
        }
        
        // Handle last modified (row 11, but check if it exists)
        if row.count > 11 && !row[11].isEmpty {
            job.lastModified = parseFlexibleDate(row[11]) ?? Date()
        } else {
            job.lastModified = Date()
        }
        
        // Handle ID (row 12, but check if it exists and is not blank)
        if row.count > 12 && !row[12].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            job.id = row[12].trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            job.id = UUID().uuidString
        }
        
        return job
    }

    private static func parseFlexibleDate(_ dateString: String) -> Date? {
        let trimmed = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try multiple date formats
        let formatters = [
            // Your current format
            { () -> DateFormatter in
                let f = DateFormatter()
                f.dateFormat = "MMM d, yyyy h:mm a"
                return f
            }(),
            
            // Simple date format (YYYY-MM-DD)
            { () -> DateFormatter in
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                return f
            }(),
            
            // ISO8601 format
            { () -> DateFormatter in
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                return f
            }()
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: trimmed) {
                return date
            }
        }
        
        print("Failed to parse date: '\(trimmed)'")
        return nil
    }
}
