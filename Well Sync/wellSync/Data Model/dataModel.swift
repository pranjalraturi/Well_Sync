//
//  dataModel.swift
//  wellSync
//
//  Created by GEU on 09/02/26.
//

import Foundation

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


struct Doctor: Codable {
    // Persisted/decoded properties
    var docID: UUID? // generate if missing during decode
    let username: String?
    let email: String?
    let password: String?

    let name: String?
    let dob: Date
    let address: String?
    let experience: Int

    // Avoid UIKit types in Codable models; store base64 strings or URLs/paths instead
    let doctorImage: String?

    let qualification: String?
    let registrationNumber: String?
    let identityNumber: String?
    let educationImageData: String?
    let registrationImageData: String?
    let identityImageData: String?

    // Non-persisted/derived properties (ignored by Codable)
    var Patients: [Patient] = []
    var contact: String = ""

    enum CodingKeys: String, CodingKey {
        case docID = "doc_id"
        case username, email, password
        case name, dob, address, experience
        case doctorImage = "doctor_image"
        case qualification, registrationNumber = "registration_number", identityNumber = "identity_number"
        case educationImageData = "education_image", registrationImageData = "registration_image", identityImageData = "identity_image"
        // Exclude Patients and contact from coding
    }
}
struct Patient: Codable {
    var patientID: UUID
    var docID: UUID

    var name: String
    var email: String?
    var password: String?

    var contact: String?
    var dob: Date
    var address: String?
    var condition: String?
    var sessionStatus: Bool?
    var nextSessionDate: Date?
    var imageURL: String?
    var previousSessionDate: Date?

    enum CodingKeys: String, CodingKey {
        case patientID = "patient_id"
        case docID = "doc_id"
        case name
        case email
        case password
        case contact
        case dob
        case address
        case condition
        case sessionStatus = "session_status"
        case nextSessionDate = "next_session_date"
        case imageURL = "image_url"
        case previousSessionDate = "previous_session_date"
    }
}

