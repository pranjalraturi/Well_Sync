//
//  Supabase.swift
//  wellSync
//
//  Created by Rishika Mittal on 20/03/26.
//
import Foundation
import Supabase
import UIKit

final class AccessSupabase {
    static let shared = AccessSupabase()
    private let supabase = SupabaseManager.shared.client

    private init() {}

    func saveDoctor(doctor: Doctor) async throws {
        let saved: Doctor = try await supabase
            .from("doctors")
            .insert(doctor)
            .select()
            .single()
            .execute()
            .value
    }

    func fetchDoctor(by docID: UUID) async throws -> Doctor {
        let doctor: Doctor = try await supabase
            .from("doctors")
            .select()
            .eq("doc_id", value: docID.uuidString)
            .single()
            .execute()
            .value
        return doctor
    }

    func fetchAllDoctors() async throws -> [Doctor] {
        let doctors: [Doctor] = try await supabase
            .from("doctors")
            .select()
            .execute()
            .value
        return doctors
    }

//    func updateDoctor(_ doctor: Doctor) async throws -> Doctor {
//        let updated: Doctor = try await supabase
//            .from("doctors")
//            .update([
//                "username": doctor.username,
//                "email": doctor.email,
//                "password": doctor.password,
//                "name": doctor.name,
//                "dob": doctor.dob,
//                "address": doctor.address,
//                "experience": doctor.experience,
//                "doctor_image": doctor.doctorImage,
//                "qualification": doctor.qualification,
//                "registration_number": doctor.registrationNumber,
//                "identity_number": doctor.identityNumber,
//                "education_image_data": doctor.educationImageData,
//                "registration_image_data": doctor.registrationImageData,
//                "identity_image_data": doctor.identityImageData
//            ])
//            .eq("doc_id", value: doctor.docID.uuidString)
//            .select()
//            .single()
//            .execute()
//            .value
//        return updated
//    }

    func savePatient(_ patients:Patient) async throws {
        let saved: Patient = try await supabase
            .from("patients")
            .insert(patients)
            .select()
            .single()
            .execute()
            .value
    }

    func fetchPatient(by patientID: UUID) async throws -> Patient {
        let patient: Patient = try await supabase
            .from("patients")
            .select()
            .eq("patient_id", value: patientID.uuidString)
            .single()
            .execute()
            .value
        return patient
    }

    func fetchPatients(for doctorID: UUID) async throws -> [Patient] {
        let patients: [Patient] = try await supabase
            .from("patients")
            .select()
            .eq("doc_id", value: doctorID.uuidString)
            .execute()
            .value
        return patients
    }

    func saveActivity(_ activity: Activity) async throws -> Activity {
        let saved: Activity = try await supabase
            .from("activities")
            .insert(activity)
            .select()
            .single()
            .execute()
            .value
        return saved
    }
    func assignActivity(_ assignment: AssignedActivity) async throws -> AssignedActivity {
        let saved: AssignedActivity = try await supabase
            .from("assigned_activities")
            .insert(assignment)
            .select()
            .single()
            .execute()
            .value
        return saved
    }
    func saveActivityLog(_ log: ActivityLog) async throws -> ActivityLog {
        let saved: ActivityLog = try await supabase
            .from("activity_logs")
            .insert(log)
            .select()
            .single()
            .execute()
            .value
        return saved
    }
    func fetchActivities(for doctorID: UUID) async throws -> [Activity] {
        let data: [Activity] = try await supabase
            .from("activities")
            .select()
            .eq("doctor_id", value: doctorID.uuidString)
            .execute()
            .value
        return data
    }
    func fetchAssignments(for patientID: UUID) async throws -> [AssignedActivity] {
        let data: [AssignedActivity] = try await supabase
            .from("assigned_activities")
            .select()
            .eq("patient_id", value: patientID.uuidString)
            .execute()
            .value
        return data
    }
    func fetchActivity(byName name: String) async throws -> Activity? {
        let results: [Activity] = try await supabase
            .from("activities")
            .select()
            .ilike("name", value: name)   // case-insensitive match by name only
            .limit(1)
            .execute()
            .value
        return results.first
    }
//    func fetchActivity(byName name: String, doctorID: UUID) async throws -> Activity? {
//        let results: [Activity] = try await supabase
//            .from("activities")
//            .select()
//            .eq("doctor_id", value: doctorID.uuidString)
//            .ilike("name", value: name)   // case-insensitive match
//            .limit(1)
//            .execute()
//            .value
//        return results.first
//    }
    func fetchLogs(for patientID: UUID) async throws -> [ActivityLog] {
        let data: [ActivityLog] = try await supabase
            .from("activity_logs")
            .select()
            .eq("patient_id", value: patientID.uuidString)
            .order("date", ascending: false)
            .execute()
            .value
        return data
    }
    func fetchActivityByID(_ activityID: UUID) async throws -> Activity? {
        let results: [Activity] = try await supabase
            .from("activities")
            .select()
            .eq("activity_id", value: activityID.uuidString)  // searches by ID
            .limit(1)
            .execute()
            .value
        return results.first
    }
    
    func saveMoodLog(_ log: MoodLog) async throws {

        let savedLog: MoodLog = try await supabase
            .from("mood_logs")
            .insert(log)
            .select("*")
            .single()
            .execute()
            .value

        guard let logID = savedLog.logId else {
            throw NSError(domain: "Missing logID", code: 0)
        }
        
        if let feelings = log.selectedFeeling {

            let mappings: [MoodLogFeeling] = feelings.map {
                MoodLogFeeling(
                    id: UUID(),
                    logId: logID,
                    feelingId: $0.feelingId
                )
            }

            try await supabase
                .from("mood_log_feelings")
                .insert(mappings)
                .execute()
        }
    }
    func fetchMoodLogs(patientID: UUID) async throws -> [MoodLog] {
        
        let response = try await SupabaseManager.shared.client
            .from("mood_logs")
            .select("""
                log_id,
                patient_id,
                mood,
                date,
                mood_note,
                mood_log_feelings (
                    feelings (
                        feeling_id,
                        name,
                        mood_level
                    )
                )
            """)
            .eq("patient_id", value: patientID.uuidString)
            .order("date", ascending: false)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let raw = try JSONSerialization.jsonObject(with: response.data) as! [[String: Any]]

        return raw.map { item in
            var log = try! decoder.decode(MoodLog.self, from: JSONSerialization.data(withJSONObject: item))

            // Extract feelings manually
            if let junction = item["mood_log_feelings"] as? [[String: Any]] {
                let feelings: [Feeling] = junction.compactMap { jf in
                    if let f = jf["feelings"] {
                        let data = try! JSONSerialization.data(withJSONObject: f)
                        return try? decoder.decode(Feeling.self, from: data)
                    }
                    return nil
                }
                log.selectedFeeling = feelings
            }

            return log
        }
    }
//    func fetchMoodLogs(patientID: UUID) async throws -> [[String: Any]] {
//
//        let result = try await supabase
//            .from("mood_logs")
//            .select("""
//                mood,
//                mood_note,
//                mood_log_feelings(
//                    feelings(name, mood_level)
//                )
//            """)
//            .eq("patient_id", value: patientID.uuidString)
//            .order("date", ascending: false)
//            .execute()
//
//        let json = try JSONSerialization.jsonObject(with: result.data)
//
//        return json as? [[String: Any]] ?? []
//    }
    func fetchFeelings() async throws -> [Feeling] {
        let data: [Feeling] = try await supabase
            .from("feelings")
            .select("*")
            .execute()
            .value
        return data
    }
//    func updatePatient(_ patient: Patient) async throws -> Patient {
//        let updated: Patient = try await supabase
//            .from("patients")
//            .update([
//                "doc_id": patient.docID.uuidString,
//                "name": patient.name,
//                "email": patient.email,
//                "password": patient.password,
//                "contact": patient.contact,
//                "dob": patient.dob,
//                "next_session_date": patient.nextSessionDate,
//                "image_url": patient.imageURL as Any,
//                "address": patient.address,
//                "condition": patient.condition,
//                "session_status": patient.sessionStatus as Any,
//                "mood": patient.mood as Any,
//                "previous_session_date": patient.previousSessionDate as Any
//            ])
//            .eq("patient_id", value: patient.patientID.uuidString)
//            .select()
//            .single()
//            .execute()
//            .value
//        return updated
//    }
    func createAppointment(_ appointment: Appointment) async throws -> Appointment {

        let saved: Appointment = try await supabase
            .from("appointments")
            .insert(appointment)
            .select("*")
            .single()
            .execute()
            .value

        return saved
    }
        
    func updateAppointment(_ appointment: Appointment) async throws -> Appointment {

        guard let id = appointment.appointmentId else {
            throw NSError(domain: "Missing appointment ID", code: 0)
        }

        let updated: Appointment = try await supabase
            .from("appointments")
            .update(appointment)  
            .eq("appointment_id", value: id.uuidString)
            .select("*")
            .single()
            .execute()
            .value

        return updated
    }
    
    // fetch appointments by patient
    func fetchAppointments(patientID: UUID) async throws -> [Appointment] {

        let data: [Appointment] = try await supabase
            .from("appointments")
            .select("*")
            .eq("patient_id", value: patientID.uuidString)
            .order("scheduled_at", ascending: false)
            .execute()
            .value

        return data
    }
    // fetch appointments by doctor
    func fetchAppointmentsForDoctor(doctorID: UUID) async throws -> [Appointment] {

        let data: [Appointment] = try await supabase
            .from("appointments")
            .select("*")
            .eq("doctor_id", value: doctorID.uuidString)
            .order("scheduled_at", ascending: true)
            .execute()
            .value

        return data
    }
    func deleteAppointment(id: UUID) async throws {

        try await supabase
            .from("appointments")
            .delete()
            .eq("appointment_id", value: id.uuidString)
            .execute()
    }
    // mark status
    func updateAppointmentStatus(id: UUID, status: String) async throws {

        try await supabase
            .from("appointments")
            .update([
                "status": status
            ])
            .eq("appointment_id", value: id.uuidString)
            .execute()
    }
    
    func saveCaseHistory(_ patientId: UUID) async throws -> CaseHistory {
            let payload = CaseHistory(
                caseId: UUID(),
                patientId: patientId,
                timeline: nil,
                report: nil
            )

            let saved: CaseHistory = try await supabase
                .from("case_histories")
                .insert(payload)
                .select("*")
                .single()
                .execute()
                .value

            return saved
        }

    func saveTimeline(_ timeline: Timeline) async throws -> Timeline {
        let saved: Timeline = try await supabase
            .from("timelines")
            .insert(timeline)
            .select("*")
            .single()
            .execute()
            .value
        return saved
    }

    func saveReport(_ report: Report) async throws -> Report {
        let saved: Report = try await supabase
            .from("reports")
            .insert(report)
            .select("*")
            .single()
            .execute()
            .value
        return saved
    }

    func saveCompleteCaseHistory(
        patientId: UUID,
        timelines: [Timeline],
        reports: [Report]
    ) async throws {
        let caseHistory = try await saveCaseHistory(patientId)
        let caseID = caseHistory.caseId
            if !timelines.isEmpty {
                let items = timelines.map {
                    Timeline(
                        timelineId: UUID(),
                        caseID: caseID,
                        title: $0.title,
                        date: $0.date,
                        description: $0.description
                    )
                }

                _ = try await supabase
                    .from("timelines")
                    .insert(items)
                    .execute()
            }

            if !reports.isEmpty {
                let items = reports.map {
                    Report(
                        reportId: UUID(),
                        caseId: caseID,
                        title: $0.title,
                        date: $0.date,
                        reportPath: $0.reportPath
                    )
                }

                _ = try await supabase
                    .from("reports")
                    .insert(items)
                    .execute()
            }
        }
    func fetchCaseHistory(for patientId: UUID) async throws -> CaseHistory? {
            let caseHistory: CaseHistory = try await supabase
                .from("case_histories")
                .select("*")
                .eq("patient_id", value: patientId.uuidString)
                .single()
                .execute()
                .value

            return caseHistory
        }

        func fetchTimelines(for caseId: UUID) async throws -> [Timeline] {
            let timelines: [Timeline] = try await supabase
                .from("timelines")
                .select("*")
                .eq("case_id", value: caseId.uuidString)
                .order("date", ascending: false)
                .execute()
                .value
            return timelines
        }

        func fetchReports(for caseId: UUID) async throws -> [Report] {
            let reports: [Report] = try await supabase
                .from("reports")
                .select("*")
                .eq("case_id", value: caseId.uuidString)
                .order("date", ascending: false)
                .execute()
                .value
            return reports
        }

        func fetchFullCaseHistory(for patientId: UUID) async throws -> CaseHistory {
            let caseHistory = try await fetchCaseHistory(for: patientId)
            guard let caseHistory else {
                return CaseHistory(caseId: UUID(), patientId: patientId, timeline: [], report: [])
            }

            let timelines = try await fetchTimelines(for: caseHistory.caseId)
            let reports = try await fetchReports(for: caseHistory.caseId)

            return CaseHistory(
                caseId: caseHistory.caseId,
                patientId: caseHistory.patientId,
                timeline: timelines,
                report: reports
            )
        }
    func saveSessionNote(_ note: SessionNote) async throws -> SessionNote {

        let saved: SessionNote = try await supabase
            .from("session_notes")
            .insert(note)
            .select("*")
            .single()
            .execute()
            .value

        return saved
    }
    func fetchSessionNotes(patientID: UUID) async throws -> [SessionNote] {

        let data: [SessionNote] = try await supabase
            .from("session_notes")
            .select("*")
            .eq("patient_id", value: patientID.uuidString)
            .order("date", ascending: false)
            .execute()
            .value

        return data
    }
    func updateSessionNote(_ note: SessionNote) async throws -> SessionNote {

        let updated: SessionNote = try await supabase
            .from("session_notes")
            .update(note)
            .eq("session_id", value: note.sessionId!.uuidString)
            .select("*")
            .single()
            .execute()
            .value

        return updated
    }
    func savePatientNote(_ note: PatientNote) async throws -> PatientNote {

        let saved: PatientNote = try await supabase
            .from("patient_notes")
            .insert(note)
            .select("*")
            .single()
            .execute()
            .value

        return saved
    }
    func fetchPatientNotes(patientID: UUID) async throws -> [PatientNote] {

        let data: [PatientNote] = try await supabase
            .from("patient_notes")
            .select("*")
            .eq("patient_id", value: patientID.uuidString)
            .order("date", ascending: false)
            .execute()
            .value

        return data
    }
    func updatePatientNote(_ note: PatientNote) async throws -> PatientNote {

        let updated: PatientNote = try await supabase
            .from("patient_notes")
            .update(note)
            .eq("note_id", value: note.noteId.uuidString)
            .select("*")
            .single()
            .execute()
            .value

        return updated
    }
    private let bucketName = "Patient_profile"
    func uploadProfileImage(_ image: UIImage, folder: String = "patients") async throws -> String {
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                throw NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to JPEG data"])
            }

            let fileName = "\(UUID().uuidString).jpg"
            let path = "\(folder)/\(fileName)"

            try await supabase.storage
                .from(bucketName)
                .upload(
                    path: path,
                    file: data,
                    options: FileOptions(
                        cacheControl: "3600",
                        contentType: "image/jpeg",
                        upsert: false
                    )
                )

            return path
        }

        func getPublicImageURL(path: String) throws -> URL {
            try supabase.storage
                .from(bucketName)
                .getPublicURL(path: path)
        }

        func getSignedImageURL(path: String, expiresIn: Int = 3600) async throws -> URL {
            try await supabase.storage
                .from(bucketName)
                .createSignedURL(path: path, expiresIn: expiresIn)
        }

        func downloadImage(path: String) async throws -> UIImage {
            let data = try await supabase.storage
                .from(bucketName)
                .download(path: path)

            guard let image = UIImage(data: data) else {
                throw NSError(domain: "ImageError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not decode image data"])
            }
            return image
        }
}
