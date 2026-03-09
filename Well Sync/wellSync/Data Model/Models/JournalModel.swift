//
//  JournalModel.swift
//  wellSync
//
//  Created by Pranjal on 07/02/26.
//

import Foundation

enum JournalType {
    case written
    case audio
}

struct JournalEntry {
    let title: String
    let subtitle: String
    let summary: String
    let type: JournalType
    let journalImage: String?
    let audioFile: String?
    let date: Date
}
