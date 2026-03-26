//
//  CaseHistory.swift
//  wellSync
//
//  Created by Vidit Agarwal on 18/02/26.
//

//import Foundation

//struct CaseHistory{
//    let caseId: UUID
//    let patientId: UUID
//    let timeline: [Timeline]?
//    let report: [Report]?
//}
//
//struct Timeline{
//    let caseID: UUID
//    let title: String
//    let date: Date
//    let Description: String
//}
//
//struct Report{
//    let caseId: UUID
//    let title: String
//    let date: Date
//    let reportPath: [String]
//}

import Foundation

struct CaseHistory: Codable {
    let caseId: UUID
    let patientId: UUID
    let timeline: [Timeline]?
    let report: [Report]?

    enum CodingKeys: String, CodingKey {
        case caseId = "case_id"
        case patientId = "patient_id"
        case timeline
        case report
    }
}

struct Timeline: Codable {
    let timelineId: UUID?
    let caseID: UUID
    let title: String
    let date: Date
    let description: String

    enum CodingKeys: String, CodingKey {
        case timelineId = "timeline_id"
        case caseID = "case_id"
        case title
        case date
        case description
    }
}

struct Report: Codable {
    let reportId: UUID?
    let caseId: UUID
    let title: String
    let date: Date
    let reportPath: [String]

    enum CodingKeys: String, CodingKey {
        case reportId = "report_id"
        case caseId = "case_id"
        case title
        case date
        case reportPath = "report_paths"
    }
}
