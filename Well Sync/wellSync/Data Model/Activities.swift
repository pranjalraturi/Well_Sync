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
    let iconName: String
    
    enum CodingKeys: String, CodingKey {
        case activityID = "activity_id"
        case doctorID = "doctor_id"
        case name
        case iconName = "icon_name"
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
    
    // NEW: Tracking method flags (moved from Activity)
    let hasImage: Bool
    let hasRecording: Bool
    let hasTimer: Bool

    var isActiveToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let start = Calendar.current.startOfDay(for: startDate)
        let end   = Calendar.current.startOfDay(for: endDate)
        return today >= start && today <= end && status == .active
    }
    
    // Helper computed properties
    var isUploadType: Bool {
        return hasImage || hasRecording
    }
    
    var isTimerType: Bool {
        return hasTimer
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
        case hasImage = "has_image"
        case hasRecording = "has_recording"
        case hasTimer = "has_timer"
    }
}
//struct ActivityLogWithDetails: Codable {
//    let log: ActivityLog
//    let activity: Activity
//    
//    // Helper computed properties
//    var activityName: String { activity.name }
//    var activityType: ActivityType { activity.type }
//    var iconName: String { activity.iconName }
//    
//    // Determine if this is a timed activity or upload activity
//    var hasFile: Bool { log.uploadPath != nil }
//    var hasDuration: Bool { log.duration != nil }
//}
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

//extension ActivityLogWithDetails {
//    func toJournalEntry() -> JournalEntry {
//        // STEP 1: Format the date for title (e.g., "Monday, Oct 23")
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEEE, MMM d"
//        let titleDate = dateFormatter.string(from: log.date)
//        
//        // STEP 2: Determine JournalType based on activity type AND file type
//        let journalType: JournalType
//        
//        switch activityType {
//        case .timer:
//            // Timer activities (breathing, meditation, walking)
//            // These show with a timer icon - we'll use .audio type for the icon
//            journalType = .audio
//            
//        case .upload:
//            // Upload activities - determine type from file extension
//            if let uploadPath = log.uploadPath {
//                journalType = determineJournalType(from: uploadPath)
//            } else {
//                // Default to written if no file path
//                journalType = .written
//            }
//        }
//        
//        // STEP 3: Create subtitle with time and activity name
//        let subtitle = "\(log.time) • \(activityName)"
//        
//        // STEP 4: Generate summary based on activity type
//        let summary = generateSummary()
//        
//        // STEP 5: Determine image/audio file paths
//        let journalImage: String?
//        let audioFile: String?
//        
//        if activityType == .upload {
//            // For upload activities, assign path based on file type
//            if journalType == .audio {
//                audioFile = log.uploadPath
//                journalImage = nil
//            } else {
//                journalImage = log.uploadPath
//                audioFile = nil
//            }
//        } else {
//            // Timer activities don't have files
//            journalImage = nil
//            audioFile = nil
//        }
//        
//        return JournalEntry(
//            title: titleDate,
//            subtitle: subtitle,
//            summary: summary,
//            type: journalType,
//            journalImage: journalImage,
//            audioFile: audioFile,
//            date: log.date
//        )
//    }
    
    /// Determine JournalType from file extension
private func determineJournalType(from path: String) -> JournalType {
    let lowercased = path.lowercased()
        
        // Audio file extensions
    if lowercased.hasSuffix(".mp3") ||
        lowercased.hasSuffix(".m4a") ||
        lowercased.hasSuffix(".wav") ||
        lowercased.hasSuffix(".aac") ||
        lowercased.contains("/audio/") {
        return .audio
    }
        
        // Everything else (images, PDFs, documents) is treated as written
    return .written
}
    
//    private func generateSummary() -> String {
//        switch activityType {
//        case .timer:
//            // For timer activities, show duration if available
//            if let duration = log.duration {
//                return "\(activityName) • \(formatDuration(duration))"
//            } else {
//                return "\(activityName) completed"
//            }
//            
//        case .upload:
//            // For upload activities, show file type if available
//            if let uploadPath = log.uploadPath {
//                let fileType = determineFileType(from: uploadPath)
//                return "\(activityName) • \(fileType)"
//            } else {
//                return "\(activityName) entry"
//            }
//        }
//    }
//    
//    /// Format duration in minutes/seconds
//    private func formatDuration(_ seconds: Int) -> String {
//        if seconds < 60 {
//            return "\(seconds) sec"
//        } else {
//            let minutes = seconds / 60
//            let remainingSeconds = seconds % 60
//            if remainingSeconds == 0 {
//                return "\(minutes) min"
//            } else {
//                return "\(minutes) min \(remainingSeconds) sec"
//            }
//        }
//    }
//    
//    /// Determine file type from upload path for display
//    private func determineFileType(from path: String) -> String {
//        let lowercased = path.lowercased()
//        
//        if lowercased.hasSuffix(".pdf") {
//            return "PDF document"
//        } else if lowercased.hasSuffix(".jpg") || lowercased.hasSuffix(".jpeg") || lowercased.hasSuffix(".png") || lowercased.hasSuffix(".heic") {
//            return "Image"
//        } else if lowercased.hasSuffix(".mp3") || lowercased.hasSuffix(".m4a") || lowercased.hasSuffix(".wav") {
//            return "Audio recording"
//        } else if lowercased.hasSuffix(".mp4") || lowercased.hasSuffix(".mov") {
//            return "Video"
//        } else {
//            return "File"
//        }
//    }
//}
