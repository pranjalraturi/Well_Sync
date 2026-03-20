//
//  Supabase.swift
//  wellSync
//
//  Created by Rishika Mittal on 20/03/26.
//
import Foundation
import Supabase

final class AccessSupabase {
    static let shared = AccessSupabase()
    private let supabase = SupabaseManager.shared.client

    private init() {}

    // MARK: - DOCTORS

    func saveDoctor() async throws {
        
        let doctor = Doctor(
            docID: nil,
            username: "drvidit",
            email: "doctor@example.com",
            password: "123456",
            name: "Dr. Vidit",
            dob: Date(),
            address: "Delhi",
            experience: 5,
            doctorImage: nil,
            qualification: "MBBS",
            registrationNumber: "REG123",
            identityNumber: "ID123",
            educationImageData: nil,
            registrationImageData: nil,
            identityImageData: nil
        )
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

    // MARK: - PATIENTS

    func savePatient() async throws {
        let patients = Patient(
            patientID: UUID(),
            docID: UUID(uuidString: "6bf94a4d-cc66-4d87-a90d-be2500434e3d")!,
            name: "Patient One",
            email: "p1@example.com",
            password: "pass123",
            contact: "9999999999",
            dob: Date(),
            address: "Noida", condition: "Anxiety", sessionStatus: false, nextSessionDate: Date(),
            imageURL: nil,
            previousSessionDate: nil
        )
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
    
    func saveMoodLog(_ log: MoodLog) async throws {

        // 1️⃣ Save mood log first
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

        // 2️⃣ Save feelings (join table)
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
}
