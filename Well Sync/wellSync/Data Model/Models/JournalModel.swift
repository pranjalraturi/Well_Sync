//
//  JournalModel.swift
//  wellSync
//
//  Created by Pranjal on 07/02/26.
//

import Foundation

enum JournalType {
    case written   // Image upload
    case audio     // Recording upload
}

struct JournalEntry {
    let logID: UUID
    let assignmentID: UUID  // NEW: Track which assignment this log belongs to
    let title: String
    let subtitle: String
    let summary: String
    let type: JournalType
    let uploadPath: String?
    let date: Date
    let time: String
    
    // Initializer from ActivityLog
    init(from log: ActivityLog, assignment: AssignedActivity) {
        self.logID = log.logID
        self.assignmentID = log.assignedID  // NEW
        self.date = log.date
        self.time = log.time
        self.uploadPath = log.uploadPath
        
        // Determine type based on BOTH assignment flags AND file extension
        self.type = Self.determineType(
            uploadPath: log.uploadPath,
            assignment: assignment
        )
        
        // Format title: "Monday, Oct 23"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        self.title = dateFormatter.string(from: log.date)
        
        // Format subtitle: "9:41 AM • Written Journal" or "9:41 AM • Voice Journal"
        let typeText = self.type == .audio ? "Voice Journal" : "Written Journal"
        self.subtitle = "\(log.time) • \(typeText)"
        
        // Summary - empty for now
        self.summary = "sample summary"
    }
    
    // MARK: - Type Determination Logic
    
    private static func determineType(
        uploadPath: String?,
        assignment: AssignedActivity
    ) -> JournalType {
        
        // Method 1: Check assignment flags first
        if assignment.hasRecording {
            return .audio
        }
        if assignment.hasImage {
            return .written
        }
        
        // Method 2: If flags are ambiguous, check file extension
        guard let path = uploadPath else {
            // No upload path, default based on assignment
            return assignment.hasRecording ? .audio : .written
        }
        
        let lowercasePath = path.lowercased()
        
        // Audio extensions
        let audioExtensions = [".mp3", ".m4a", ".wav", ".aac", ".ogg"]
        if audioExtensions.contains(where: { lowercasePath.hasSuffix($0) }) {
            return .audio
        }
        
        // Image extensions
        let imageExtensions = [".jpg", ".jpeg", ".png", ".gif", ".heic", ".webp"]
        if imageExtensions.contains(where: { lowercasePath.hasSuffix($0) }) {
            return .written
        }
        
        // Default fallback
        return assignment.hasRecording ? .audio : .written
    }
}
