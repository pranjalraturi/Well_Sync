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
    let dob: String?
    let address: String?
    let experience: Int?

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
        case docID
        case username, email, password
        case name, dob, address, experience
        case doctorImage
        case qualification, registrationNumber, identityNumber
        case educationImageData, registrationImageData, identityImageData
        // Exclude Patients and contact from coding
    }

    init(docID: UUID? = nil,
         username: String?,
         email: String?,
         password: String?,
         name: String?,
         dob: String?,
         address: String?,
         experience: Int?,
         doctorImage: String?,
         qualification: String?,
         registrationNumber: String?,
         identityNumber: String?,
         educationImageData: String?,
         registrationImageData: String?,
         identityImageData: String?,
         Patients: [Patient] = [],
         contact: String = "") {
        self.docID = docID
        self.username = username
        self.email = email
        self.password = password
        self.name = name
        self.dob = dob
        self.address = address
        self.experience = experience
        self.doctorImage = doctorImage
        self.qualification = qualification
        self.registrationNumber = registrationNumber
        self.identityNumber = identityNumber
        self.educationImageData = educationImageData
        self.registrationImageData = registrationImageData
        self.identityImageData = identityImageData
        self.Patients = Patients
        self.contact = contact
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.docID = try container.decodeIfPresent(UUID.self, forKey: .docID)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.password = try container.decodeIfPresent(String.self, forKey: .password)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.dob = try container.decodeIfPresent(String.self, forKey: .dob)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.experience = try container.decodeIfPresent(Int.self, forKey: .experience)
        self.doctorImage = try container.decodeIfPresent(String.self, forKey: .doctorImage)
        self.qualification = try container.decodeIfPresent(String.self, forKey: .qualification)
        self.registrationNumber = try container.decodeIfPresent(String.self, forKey: .registrationNumber)
        self.identityNumber = try container.decodeIfPresent(String.self, forKey: .identityNumber)
        self.educationImageData = try container.decodeIfPresent(String.self, forKey: .educationImageData)
        self.registrationImageData = try container.decodeIfPresent(String.self, forKey: .registrationImageData)
        self.identityImageData = try container.decodeIfPresent(String.self, forKey: .identityImageData)
        // Defaults for non-coded properties
        self.Patients = []
        self.contact = ""
        // Ensure we always have an ID
        if self.docID == nil { self.docID = UUID() }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(docID, forKey: .docID)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(dob, forKey: .dob)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(experience, forKey: .experience)
        try container.encodeIfPresent(doctorImage, forKey: .doctorImage)
        try container.encodeIfPresent(qualification, forKey: .qualification)
        try container.encodeIfPresent(registrationNumber, forKey: .registrationNumber)
        try container.encodeIfPresent(identityNumber, forKey: .identityNumber)
        try container.encodeIfPresent(educationImageData, forKey: .educationImageData)
        try container.encodeIfPresent(registrationImageData, forKey: .registrationImageData)
        try container.encodeIfPresent(identityImageData, forKey: .identityImageData)
    }
}

struct Patient: Codable {
    var patientID: UUID
    var docID: UUID

    var name: String
    var email: String
    var password: String

    var contact: String
    var dob: Date
    var nextSessionDate: Date
    var imageURL: String?
    var address: String

    enum CodingKeys: String, CodingKey {
        case patientID, docID, name, email, password, contact, dob, nextSessionDate, imageURL, address
    }
}
