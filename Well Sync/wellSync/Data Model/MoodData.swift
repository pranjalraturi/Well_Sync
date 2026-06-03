//
//  MoodData.swift
//  wellSync
//
//  Created by Vidit Agarwal on 17/02/26.
//

import UIKit

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

class MoodColors {
    static let shared = MoodColors()
    
    let colors: [UIColor] = [
        UIColor(red: 51/255,  green: 89/255,  blue: 93/255,  alpha: 1.0),  // 1 – Very Sad (red photo color)
        UIColor(red: 57/255,  green: 118/255, blue: 119/255, alpha: 1.0),  // 2 – Sad (orange photo color)
        UIColor(red: 92/255,  green: 166/255, blue: 169/255, alpha: 1.0),  // 3 – Neutral (yellow photo color)
        UIColor(red: 144/255, green: 196/255, blue: 195/255, alpha: 1.0),  // 4 – Happy (lightGreen photo color)
        UIColor(red: 184/255, green: 224/255, blue: 226/255, alpha: 1.0)   // 5 – Very Happy (green photo color)
    ]
}
