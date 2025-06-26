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
    static func exportJobs(_ jobs: [Job]) throws -> String {
        var csv = "ID,Date Applied,Company Name,Job Title,URL,Salary Min,Salary Max,Is Denied,Denied Date,Notes,Work Type,Last Modified,Interviews\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for job in jobs {
            // Sort interviews by date
            let sortedInterviews = job.interviews.sorted(by: { $0.date < $1.date })
            
            // Format each interview as a string
            let interviewStrings = sortedInterviews.map { interview in
                let dateString = dateFormatter.string(from: interview.date)
                let roundString = String(interview.round)
                let escapedNotes = interview.notes.escapingCSV()
                return "\(dateString)|\(roundString)|\(escapedNotes)"
            }
            
            // Join all interview strings
            let interviews = interviewStrings.joined(separator: ";")
            
            // Prepare individual fields
            let dateApplied = dateFormatter.string(from: job.dateApplied)
            let deniedDate = job.deniedDate.map { dateFormatter.string(from: $0) } ?? ""
            let lastModifiedDate = dateFormatter.string(from: job.lastModified)
            let salaryMinString = job.salaryMin.map { String($0) } ?? ""
            let salaryMaxString = job.salaryMax.map { String($0) } ?? ""
            let urlString = job.url?.absoluteString ?? ""
            
            // Create array of fields
            let fields = [
                job.id,
                dateApplied,
                job.companyName.escapingCSV(),
                job.jobTitle.escapingCSV(),
                urlString,
                salaryMinString,
                salaryMaxString,
                String(job.isDenied),
                deniedDate,
                job.notes.escapingCSV(),
                job.workplaceType.rawValue,
                lastModifiedDate,
                interviews.escapingCSV()
            ]
            
            // Join fields into a row
            let row = fields.joined(separator: ",")
            
            csv += row + "\n"
        }
        
        return csv
    }
    
    static func importJobs(_ csv: String, modelContext: ModelContext) throws {
        let rows = csv.components(separatedBy: .newlines)
        guard rows.count > 1 else { throw CSVError.emptyFile }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Skip header row
        for row in rows.dropFirst() where !row.isEmpty {
            let columns = row.components(separatedBy: ",")
            guard columns.count >= 12 else { continue }
            
            let id = columns[0]
            let dateApplied = dateFormatter.date(from: columns[1]) ?? Date()
            let companyName = columns[2].unescapingCSV()
            let jobTitle = columns[3].unescapingCSV()
            let url = URL(string: columns[4])
            let salaryMin = Double(columns[5])
            let salaryMax = Double(columns[6])
            let isDenied = columns[7].lowercased() == "true"
            let deniedDate = columns[8].isEmpty ? nil : dateFormatter.date(from: columns[8])
            let notes = columns[9].unescapingCSV()
            let workplaceType = WorkplaceType(rawValue: columns[10]) ?? .remote
            let lastModified = dateFormatter.date(from: columns[11]) ?? Date()
            
            let job = Job(
                dateApplied: dateApplied,
                companyName: companyName,
                jobTitle: jobTitle,
                url: url,
                salaryMin: salaryMin,
                salaryMax: salaryMax,
                isDenied: isDenied,
                deniedDate: deniedDate,
                notes: notes,
                workplaceType: workplaceType
            )
            job.id = id
            job.lastModified = lastModified
            
            // Parse interviews if they exist
            if columns.count > 12 {
                let interviewsData = columns[12].unescapingCSV()
                let interviews = interviewsData.components(separatedBy: ";")
                
                for interviewData in interviews where !interviewData.isEmpty {
                    let parts = interviewData.components(separatedBy: "|")
                    if parts.count >= 3,
                       let date = dateFormatter.date(from: parts[0]),
                       let round = Int(parts[1]) {
                        let notes = parts[2].unescapingCSV()
                        let interview = Interview(date: date, notes: notes, round: round)
                        job.interviews.append(interview)
                    }
                }
            }
            
            modelContext.insert(job)
        }
        
        try modelContext.save()
    }
}

enum CSVError: Error {
    case emptyFile
    case invalidFormat
}
