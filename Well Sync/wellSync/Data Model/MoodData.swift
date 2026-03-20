//
//  MoodData.swift
//  wellSync
//
//  Created by Vidit Agarwal on 17/02/26.
//

import Foundation

struct MoodLogFeeling: Codable {
    let id: UUID
    let logId: UUID
    let feelingId: UUID

    enum CodingKeys: String, CodingKey {
        case id
        case logId = "log_id"
        case feelingId = "feeling_id"
    }
}
struct MoodLog: Codable {
    var logId: UUID?
    var patientId: UUID?
    var mood: Int
    var date: Date
    var moodNote: String?
    var selectedFeeling: [Feeling]?

    enum CodingKeys: String, CodingKey {
        case logId = "log_id"
        case patientId = "patient_id"
        case mood
        case date
        case moodNote = "mood_note"
    }
}
struct Feeling: Codable {
    var feelingId: UUID
    var name: String
    var moodLevel: MoodLevel

    enum CodingKeys: String, CodingKey {
        case feelingId = "feeling_id"
        case moodLevel = "mood_level"
        case name
    }
}
enum MoodLevel: Int, Codable {
    case verySad = 0
    case sad = 1
    case neutral = 2
    case happy = 3
    case veryHappy = 4
}
