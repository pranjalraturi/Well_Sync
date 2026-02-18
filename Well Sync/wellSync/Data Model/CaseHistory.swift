//
//  CaseHistory.swift
//  wellSync
//
//  Created by Vidit Agarwal on 18/02/26.
//

import Foundation

struct CaseHistory{
    let caseId: UUID
    let patientId: UUID
    let timeline: [Timeline]?
    let report: [Report]?
}

struct Timeline{
    let caseID: UUID
    let title: String
    let date: Date
    let Description: String
}

struct Report{
    let caseId: UUID
    let title: String
    let date: Date
    let reportPath: [String]
}
