//
//  Activities.swift
//  wellSync
//
//  Created by Vidit Agarwal on 17/02/26.
//
import Foundation


enum ActivityType: String, Codable {
    case timer
    case upload
}

enum AssignmentStatus: String, Codable {
    case active
    case completed
    case cancelled
}


struct Activity: Codable {
    let activityID: UUID
    let doctorID: UUID
    let name: String
    let type: ActivityType
    let iconName: String
    let description: String
    enum CodingKeys: String, CodingKey {
        case activityID = "activity_id"
        case doctorID = "doctor_id"
        case name, type
        case iconName = "icon_name"
        case description
    }

}

struct AssignedActivity: Codable {
    let assignedID: UUID
    let activityID: UUID
    let patientID: UUID
    let doctorID: UUID
    let frequency: Int
    let startDate: Date
    let endDate: Date
    let doctorNote: String?
    let status: AssignmentStatus

    var isActiveToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let start = Calendar.current.startOfDay(for: startDate)
        let end   = Calendar.current.startOfDay(for: endDate)
        return today >= start && today <= end && status == .active
    }
    
    enum CodingKeys: String, CodingKey {
        case assignedID = "assigned_id"
        case activityID = "activity_id"
        case patientID = "patient_id"
        case doctorID = "doctor_id"
        case frequency
        case startDate = "start_date"
        case endDate = "end_date"
        case doctorNote = "doctor_note"
        case status
    }

}

struct ActivityLog: Codable {
    let logID: UUID
    let assignedID: UUID
    let activityID: UUID
    let patientID: UUID
    let date: Date
    let time: String
    let duration: Int?
    let uploadPath: String?
    
    enum CodingKeys: String, CodingKey {
        case logID = "log_id"
        case assignedID = "assigned_id"
        case activityID = "activity_id"
        case patientID = "patient_id"
        case date, time, duration
        case uploadPath = "upload_path"
    }
}
