//
//  vitals.swift
//  wellSync
//
//  Created by Vidit Agarwal on 11/04/26.
//
import UIKit

struct sleepVital:Codable{
    let id:UUID?
    let patient_id:UUID
    let start_time:Date
    let end_time:Date
    let duration_minutes:Double
    let quality:String
}

struct StepsVital: Codable {
    var id:         UUID?
    var patient_id: UUID
    var log_date:   Date
    var step_count: Double
}
