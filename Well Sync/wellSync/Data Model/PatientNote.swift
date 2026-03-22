//
//  PatientNote.swift
//  wellSync
//
//  Created by Vidit Agarwal on 17/02/26.
//

import Foundation

struct PatientNote: Codable{
    let noteId:UUID
    let patientId:UUID
    let date:Date
    let note:String
    
    enum CodingKeys: String, CodingKey {
        case noteId = "note_id"
        case patientId = "patient_id"
        case date
        case note
    }
}
