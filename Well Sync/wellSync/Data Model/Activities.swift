//
//  Activities.swift
//  wellSync
//
//  Created by Vidit Agarwal on 17/02/26.
//
import Foundation

struct Activity{
    let activityID: UUID
    let doctorID: UUID
    let name: String
    let type: String  // not definate till now
    let doctorNote: String?
    let iconName: String
}

struct Activities{
    let activityID: UUID
    let patientID: UUID
    let frequency: Int
    let startDate: Date
    let endDate: Date
    let completed: Float
}

struct ActivityLog {
    let logID: UUID
    let activityID: UUID
    let pateintID:UUID
    let time: String
    let date: Date
    let uploadPath: String?
    let duration:Int?
}
