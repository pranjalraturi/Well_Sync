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

var UserDoctors: [Doctor] = [] // education table view controller


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

enum SessionStatus {
    case upcoming
    case missed
    case completed
}

