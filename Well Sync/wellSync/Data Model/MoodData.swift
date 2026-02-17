//
//  MoodData.swift
//  wellSync
//
//  Created by Vidit Agarwal on 17/02/26.
//

import Foundation

struct moodLogFeelings{
    let id:UUID
    let logId:UUID
    let feelingId:UUID
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

struct Feeling{
    var feelingId: UUID
    var moodLevel: MoodLevel
    var name: String
}

enum MoodLevel :Int{
    case verySad = 1
    case sad
    case neutral
    case happy
    case veryHappy
}
