//
//  Activities.swift
//  wellSync
//
//  Created by Vidit Agarwal on 17/02/26.
//
import Foundation
//
//struct Activity{
//    let activityID: UUID
//    let doctorID: UUID
//    let name: String
//    let type: String  // not definate till now
//    let doctorNote: String?
//    let iconName: String
//}
//
//struct Activities{
//    let activityID: UUID
//    let patientID: UUID
//    let frequency: Int
//    let startDate: Date
//    let endDate: Date
//    let completed: Float
//}
//
//struct ActivityLog {
//    let logID: UUID
//    let activityID: UUID
//    let pateintID:UUID
//    let time: String
//    let date: Date
//    let uploadPath: String?
//    let duration:Int?
//}

// MARK: - Enums

enum ActivityType: String, Codable {
    case timer   // patient runs a countdown timer and submits duration
    case upload  // patient uploads a photo or video as proof
}

enum AssignmentStatus: String, Codable {
    case active
    case completed
    case cancelled
}

// MARK: - Activity
// The master definition of an activity (like a library/catalog entry).
// Created and owned by a doctor. Reusable across multiple patients.

struct Activity: Codable {
    let activityID: UUID
    let doctorID: UUID
    let name: String
    let type: ActivityType
    let iconName: String
    let description: String       // what the activity is
}

// MARK: - AssignedActivity
// When a doctor assigns an Activity to a specific patient.
// This is what drives both the patient dashboard and the doctor view.

struct AssignedActivity: Codable {
    let assignedID: UUID
    let activityID: UUID          // references Activity
    let patientID: UUID
    let doctorID: UUID
    let frequency: Int            // times per day the patient must do it
    let startDate: Date
    let endDate: Date
    let doctorNote: String?
    let status: AssignmentStatus  // active / completed / cancelled

    // Computed — does this assignment apply today?
    var isActiveToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let start = Calendar.current.startOfDay(for: startDate)
        let end   = Calendar.current.startOfDay(for: endDate)
        return today >= start && today <= end && status == .active
    }
}

// MARK: - ActivityLog
// One entry every time a patient completes a single session of an assigned activity.
// This is the source of truth for completion tracking.

struct ActivityLog: Codable {
    let logID: UUID
    let assignedID: UUID          // references AssignedActivity
    let activityID: UUID          // references Activity (for quick lookup)
    let patientID: UUID
    let date: Date                // the calendar day this log belongs to
    let time: String              // e.g. "08:30 AM" — display string
    let duration: Int?            // in seconds — filled when type == .timer
    let uploadPath: String?       // file path / URL — filled when type == .upload
}
