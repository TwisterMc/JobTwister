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
    var companyName: String
    var jobTitle: String
    var url: URL?
    var salary: Double?
    var hasInterview: Bool
    var interviewDate: Date?
    var isDenied: Bool
    var notes: String
    var workplaceType: WorkplaceType
    
    init(dateApplied: Date = Date(),
         companyName: String = "",
         jobTitle: String = "",
         url: URL? = nil,
         salary: Double? = nil,
         hasInterview: Bool = false,
         interviewDate: Date? = nil,
         isDenied: Bool = false,
         notes: String = "",
         workplaceType: WorkplaceType = .remote) {
        self.id = UUID().uuidString
        self.dateApplied = dateApplied
        self.companyName = companyName
        self.jobTitle = jobTitle
        self.url = url
        self.salary = salary
        self.hasInterview = hasInterview
        self.interviewDate = interviewDate
        self.isDenied = isDenied
        self.notes = notes
        self.workplaceType = workplaceType
    }
}
