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
    var scheduledAt: Date
    var status: status   // scheduled / completed / missed / cancelled

    enum CodingKeys: String, CodingKey {
        case appointmentId = "appointment_id"
        case patientId = "patient_id"
        case doctorId = "doctor_id"
        case scheduledAt = "scheduled_at"
        case status = "status"
    }
    enum status: String, Codable {
        case scheduled
        case missed
        case completed
    }
}


struct AppointmentWithPatient: Decodable {
    let appointmentId: UUID
    let patientId: UUID
    let doctorId: UUID
    let scheduledAt: Date
    let status: Appointment.status
    let patient: Patient

    enum CodingKeys: String, CodingKey {
        case appointmentId = "appointment_id"
        case patientId = "patient_id"
        case doctorId = "doctor_id"
        case scheduledAt = "scheduled_at"
        case status
        case patient = "patients"
    }
}

enum doctorAction{
    case nextSession
    case addNote
    case reschedule
    case markDone
    case notify
}
enum PatientNavigationIntent {
    case nextSession
    case reschedule
}

struct PatientNotification: Codable {
    let notificationId: UUID
    let patientId: UUID
    let doctorId: UUID?
    let title: String
    let body: String
    let kind: String
    let isRead: Bool
    let createdAt: Date
    let readAt: Date?

    enum CodingKeys: String, CodingKey {
        case notificationId = "notification_id"
        case patientId = "patient_id"
        case doctorId = "doctor_id"
        case title
        case body
        case kind
        case isRead = "is_read"
        case createdAt = "created_at"
        case readAt = "read_at"
    }
}
