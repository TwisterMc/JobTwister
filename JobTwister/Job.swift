//
//  Job.swift
//  JobTwister
//
//  Created by Thomas McMahon on 6/25/25.
//

import Foundation
import SwiftData

enum WorkplaceType: String, Codable {
    case remote = "Remote"
    case hybrid = "Hybrid"
    case inOffice = "In-Office"
}

@Model
final class Job {
    @Attribute(.unique) var id: String
    var dateApplied: Date
    var lastModified: Date
    var companyName: String
    var jobTitle: String
    var url: URL?
    var salaryMin: Double?
    var salaryMax: Double?
    var hasInterview: Bool
    var interviewDate: Date?
    var isDenied: Bool
    var deniedDate: Date?
    var notes: String
    var workplaceType: WorkplaceType
    
    init(dateApplied: Date = Date(),
         companyName: String = "",
         jobTitle: String = "",
         url: URL? = nil,
         salaryMin: Double? = nil,
         salaryMax: Double? = nil,
         hasInterview: Bool = false,
         interviewDate: Date? = nil,
         isDenied: Bool = false,
         deniedDate: Date? = nil,
         notes: String = "",
         workplaceType: WorkplaceType = .remote) {
        self.id = UUID().uuidString
        self.dateApplied = dateApplied
        self.lastModified = Date()
        self.companyName = companyName
        self.jobTitle = jobTitle
        self.url = url
        self.salaryMin = salaryMin
        self.salaryMax = salaryMax
        self.hasInterview = hasInterview
        self.interviewDate = interviewDate
        self.isDenied = isDenied
        self.deniedDate = deniedDate
        self.notes = notes
        self.workplaceType = workplaceType
    }
}
