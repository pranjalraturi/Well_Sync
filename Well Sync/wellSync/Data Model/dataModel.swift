//
//  dataModel.swift
//  wellSync
//
//  Created by GEU on 09/02/26.
//

import Foundation
var UserDoctors: [Doctor] = [] // education table view controller


//struct Doctor: Codable {
//    // Persisted/decoded properties
//    var docID: UUID? // generate if missing during decode
//    let username: String?
//    let email: String?
//    let password: String?
//
//    let name: String?
//    let dob: Date
//    let address: String?
//    let experience: Int
//
//    // Avoid UIKit types in Codable models; store base64 strings or URLs/paths instead
//    let doctorImage: String?
//
//    let qualification: String?
//    let registrationNumber: String?
//    let identityNumber: String?
//    let educationImageData: String?
//    let registrationImageData: String?
//    let identityImageData: String?
//
//    // Non-persisted/derived properties (ignored by Codable)
//    var Patients: [Patient] = []
//    var contact: String = ""
//
//    enum CodingKeys: String, CodingKey {
//        case docID = "doc_id"
//        case username, email, password
//        case name, dob, address, experience
//        case doctorImage = "doctor_image"
//        case qualification, registrationNumber = "registration_number", identityNumber = "identity_number"
//        case educationImageData = "education_image", registrationImageData = "registration_image", identityImageData = "identity_image"
//        // Exclude Patients and contact from coding
//    }
//}

struct Doctor: Codable {
    var docID: UUID?
    var authID: UUID?        // ← ADD THIS
    let username: String?
    var email: String?
    // REMOVE: let password: String?   ← DELETE this line

    var name: String?
    let dob: Date
    var address: String?
    var experience: Int
    var doctorImage: String?
    let qualification: String?
    let registrationNumber: String?
    let identityNumber: String?
    let educationImageData: String?
    let registrationImageData: String?
    let identityImageData: String?

    var Patients: [Patient] = []
    var contact: String = ""

    enum CodingKeys: String, CodingKey {
        case docID = "doc_id"
        case authID = "auth_id"   // ← ADD THIS
        case username, email
        // REMOVE password from here
        case name, dob, address, experience
        case doctorImage = "doctor_image"
        case qualification
        case registrationNumber = "registration_number"
        case identityNumber = "identity_number"
        case educationImageData = "education_image"
        case registrationImageData = "registration_image"
        case identityImageData = "identity_image"
    }
}
//
//struct Patient: Codable {
//    var patientID: UUID
//    var docID: UUID
//
//    var name: String
//    var email: String?
//    var password: String?
//
//    var contact: String?
//    var dob: Date
//    var address: String?
//    var condition: String?
//    var sessionStatus: Bool?
//    var nextSessionDate: Date?
//    var imageURL: String?
//    var previousSessionDate: Date?
//
//    enum CodingKeys: String, CodingKey {
//        case patientID = "patient_id"
//        case docID = "doc_id"
//        case name
//        case email
//        case password
//        case contact
//        case dob
//        case address
//        case condition
//        case sessionStatus = "session_status"
//        case nextSessionDate = "next_session_date"
//        case imageURL = "image_url"
//        case previousSessionDate = "previous_session_date"
//    }
//}
//

struct Patient: Codable {
    var patientID: UUID
    var docID: UUID
    var authID: UUID?         // ← ADD THIS
    var name: String
    var email: String?
    // REMOVE: var password: String?   ← DELETE this line
    var contact: String?
    var dob: Date
    var address: String?
    var condition: String?
    var sessionStatus: Bool?
    var nextSessionDate: Date?
    var imageURL: String?
    var previousSessionDate: Date?
    var gender: String?

    enum CodingKeys: String, CodingKey {
        case patientID = "patient_id"
        case docID = "doc_id"
        case authID = "auth_id"   // ← ADD THIS
        case name, email
        // REMOVE password from here
        case contact, dob, address, condition
        case sessionStatus = "session_status"
        case nextSessionDate = "next_session_date"
        case imageURL = "image_url"
        case previousSessionDate = "previous_session_date"
        case gender = "gender"
    }
    
    enum gender: String{
        case Male
        case Female
        case Other
    }
}
