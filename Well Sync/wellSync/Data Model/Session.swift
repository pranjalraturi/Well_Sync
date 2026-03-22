//
//  Session.swift
//  wellSync
//
//  Created by Vidit Agarwal on 17/02/26.
//

import Foundation

//struct SessionNote:Codable{
//    let sessoinId: UUID?
//    let patientId: UUID?
//    let date: Date?
//    let notes: String?
//    let image:[String]?
//    let voice:[String]?
//}
struct SessionNote: Codable {
    let sessionId: UUID?
    let patientId: UUID?
    let date: Date
    let notes: String
    let images: [String]?
    let voice: String?
    let title: String
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case patientId = "patient_id"
        case date
        case notes
        case images
        case voice
        case title
    }
}

enum SessionStatus {
    case upcoming
    case missed
    case completed
}
