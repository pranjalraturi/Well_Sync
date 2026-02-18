//
//  Session.swift
//  wellSync
//
//  Created by Vidit Agarwal on 17/02/26.
//

import Foundation

struct SessionNote{
    let sessoinId: UUID
    let patientId: UUID
    let date: Date
    let notes: String?
    let image:[String]?
    let voice:[String]?
}

enum SessionStatus {
    case upcoming
    case missed
    case completed
}
