//
//  dataModel.swift
//  wellSync
//
//  Created by GEU on 09/02/26.
//

import Foundation
import UIKit

//struct PsychologistDashboardStats: Codable {
//    var activePatientsCount: Int
//    var activePatientsDelta: Int
//    var todaysSessionsCount: Int
//}
//
//enum SessionStatus: String, Codable {
//    case upcoming
//    case completed
//    case missed
//}
//
//struct PatientSessionCard: Identifiable {
//    var id: UUID
//    var name: String
//    var profileImage: [String]
//    var disorder: String
//    var sessionCount: Int
//    var lastSessionDate: Date
//    var sessionTimeToday: String
//    var activityCompletionPercent: Int
//    //var statusIndicator: PatientStatus
//    var sessionStatus: SessionStatus
//}

var UserDoctors: [Doctor] = []
struct Doctor{
    var docID: UUID = UUID()
    var username: String?
    var email: String?
    var password: String?

    var name: String?
    var dob: String?
    var address: String?
    var experience: Int?
    var Patients: [Patient] = []
    var contact: String = ""
    var doctorImage: UIImage?
    
    var qualification: String?
    var registrationNumber: String?
    var identityNumber: String?
    var educationImage : UIImage?
    var registrationImage: UIImage?
    var identityImage: UIImage?
}

struct Patient{
    var patientID: UUID
    var docID: UUID
    var name: String
    var email: String
    var password: String
    var contact: String
    var dob: Date
    var nextSessionDAte: Date
    var image: String?
    var adddress: String
}

struct CaseHistory{
    var caseID: UUID
    var patientID: UUID
    var ActivityStatus: [ActivityLog]
    var notes: [String]
    var summarisedReport: [String]
    
}
struct MoodLog{
    var patientId: UUID
    var logId: UUID
    var mood: MoodLevel
    var date: Date
    var time: String
    var selectedFeeling: [Feeling]?
    var moodNote: String?
}

enum MoodLevel :Int{
    case verySad = 1
    case sad
    case neutral
    case happy
    case veryHappy
    var description: String {
        switch self {
        case .verySad: return "Very Sad"
        case .sad: return "Sad"
        case .neutral: return "Neutral"
        case .happy: return "Happy"
        case .veryHappy: return "Very Happy"
        }
    }
}
struct Feeling{
    //var feelingId: UUID
    var moodLevel: MoodLevel
    var name: String
}
//let allFeeling: [Feeling] = [
//    Feeling(feelingId: UUID(), moodLevel: .verySad, name: "Angry"),
//    Feeling(feelingId: UUID(), moodLevel: .verySad, name: "Anxious"),
//    Feeling(feelingId: UUID(), moodLevel: .verySad, name: "Scared"),
//    Feeling(feelingId: UUID(), moodLevel: .verySad, name: "Disappointed"),
//    Feeling(feelingId: UUID(), moodLevel: .verySad, name: "Overwhelmed"),
//    Feeling(feelingId: UUID(), moodLevel: .verySad, name: "Embarrassed"),
//    Feeling(feelingId: UUID(), moodLevel: .verySad, name: "Frustrated"),
//    Feeling(feelingId: UUID(), moodLevel: .verySad, name: "Hopeless"),
//    Feeling(feelingId: UUID(), moodLevel: .verySad, name: "Lonely"),
//    Feeling(feelingId: UUID(), moodLevel: .sad, name: "Jealous"),
//    Feeling(feelingId: UUID(), moodLevel: .sad, name: "Stressed"),
//    Feeling(feelingId: UUID(), moodLevel: .sad, name: "Discouraged"),
//    Feeling(feelingId: UUID(), moodLevel: .sad, name: "Drained"),
//    Feeling(feelingId: UUID(), moodLevel: .sad, name: "Sad"),
//    Feeling(feelingId: UUID(), moodLevel: .sad, name: "Guilty"),
//    Feeling(feelingId: UUID(), moodLevel: .sad, name: "Worried"),
//    Feeling(feelingId: UUID(), moodLevel: .sad, name: "Hopeless"),
//    Feeling(feelingId: UUID(), moodLevel: .sad, name: "Irritated"),
//    Feeling(feelingId: UUID(), moodLevel: .sad, name: "Annoyed"),
//    Feeling(feelingId: UUID(), moodLevel: .neutral, name: "Calm"),
//    Feeling(feelingId: UUID(), moodLevel: .neutral, name: "Balanced"),
//    Feeling(feelingId: UUID(), moodLevel: .neutral, name: "Peaceful"),
//    Feeling(feelingId: UUID(), moodLevel: .neutral, name: "Content"),
//    Feeling(feelingId: UUID(), moodLevel: .neutral, name: "Indifferent"),
//    Feeling(feelingId: UUID(), moodLevel: .happy, name: "Happy"),
//    Feeling(feelingId: UUID(), moodLevel: .happy, name: "Hopeful"),
//    Feeling(feelingId: UUID(), moodLevel: .veryHappy, name: "Amazed"),
//    Feeling(feelingId: UUID(), moodLevel: .veryHappy, name: "Excited"),
//]
let allFeeling: [Feeling] = [
    Feeling(moodLevel: .verySad, name: "Angry"),
    Feeling(moodLevel: .verySad, name: "Anxious"),
    Feeling(moodLevel: .verySad, name: "Scared"),
    Feeling(moodLevel: .verySad, name: "Disappointed"),
    Feeling(moodLevel: .verySad, name: "Overwhelmed"),
    Feeling(moodLevel: .verySad, name: "Embarrassed"),
    Feeling(moodLevel: .verySad, name: "Frustrated"),
    Feeling(moodLevel: .verySad, name: "Hopeless"),
    Feeling(moodLevel: .verySad, name: "Lonely"),
    Feeling(moodLevel: .sad, name: "Jealous"),
    Feeling(moodLevel: .sad, name: "Stressed"),
    Feeling(moodLevel: .sad, name: "Discouraged"),
    Feeling(moodLevel: .sad, name: "Drained"),
    Feeling(moodLevel: .sad, name: "Sad"),
    Feeling(moodLevel: .sad, name: "Guilty"),
    Feeling(moodLevel: .sad, name: "Worried"),
    Feeling(moodLevel: .sad, name: "Hopeless"),
    Feeling(moodLevel: .sad, name: "Irritated"),
    Feeling(moodLevel: .sad, name: "Annoyed"),
    Feeling(moodLevel: .neutral, name: "Calm"),
    Feeling(moodLevel: .neutral, name: "Balanced"),
    Feeling(moodLevel: .neutral, name: "Peaceful"),
    Feeling(moodLevel: .neutral, name: "Content"),
    Feeling(moodLevel: .neutral, name: "Indifferent"),
    Feeling(moodLevel: .happy, name: "Happy"),
    Feeling(moodLevel: .happy, name: "Hopeful"),
    Feeling(moodLevel: .veryHappy, name: "Amazed"),
    Feeling(moodLevel: .veryHappy, name: "Excited"),
]

struct IndivudActivity{
    var activityID: UUID
    var name: String
    var frequency: Int
    var type: String  // not definate till now
    var startDate: Date
    var endDate: Date
    var doctorNote: String?
}
struct ActivityLog {
    var logID: UUID
    var activityID: UUID
    var time: String
    var date: Date
    var image: String?
    var voice: String?
    var duration: String?
}

enum SessionStatus{
    case upcoming
    case done
    case missed
}

