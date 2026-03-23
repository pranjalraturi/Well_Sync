//
//  Appointment.swift
//  wellSync
//
//  Created by Rishika Mittal on 23/03/26.
//
import Foundation

struct Appointment: Codable {
    let appointmentId: UUID?
    let patientId: UUID
    let doctorId: UUID
    let scheduledAt: Date
    let status: String   // scheduled / completed / missed / cancelled

    enum CodingKeys: String, CodingKey {
        case appointmentId = "appointment_id"
        case patientId = "patient_id"
        case doctorId = "doctor_id"
        case scheduledAt = "scheduled_at"
        case status
    }
}
