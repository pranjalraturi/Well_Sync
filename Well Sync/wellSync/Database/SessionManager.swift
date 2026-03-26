//
//  SessionManager.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 26/03/26.

import Foundation

// This enum defines which type of user is currently logged in
enum UserRole: String {
    case doctor = "doctor"
    case patient = "patient"
    case none = "none"
}

final class SessionManager {
    
    // Singleton — access from anywhere with SessionManager.shared
    static let shared = SessionManager()
    private init() {}
    
    // MARK: - Keys for UserDefaults
    private let roleKey = "wellsync_user_role"
    private let doctorIDKey = "wellsync_doctor_id"
    private let patientIDKey = "wellsync_patient_id"
    
    // MARK: - In-memory current user (loaded after login, cleared on logout)
    // These are loaded fresh after every login — not persisted as full objects
    var currentDoctor: Doctor?
    var currentPatient: Patient?
    
    // MARK: - Role (persisted to UserDefaults so it survives app restart)
    var currentRole: UserRole {
        get {
            let raw = UserDefaults.standard.string(forKey: roleKey) ?? "none"
            return UserRole(rawValue: raw) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: roleKey)
        }
    }
    
    // MARK: - Persisted IDs (so we can reload the profile after app restart)
    var persistedDoctorID: String? {
        get { UserDefaults.standard.string(forKey: doctorIDKey) }
        set { UserDefaults.standard.set(newValue, forKey: doctorIDKey) }
    }
    
    var persistedPatientID: String? {
        get { UserDefaults.standard.string(forKey: patientIDKey) }
        set { UserDefaults.standard.set(newValue, forKey: patientIDKey) }
    }
    
    // MARK: - Save session after successful login
    func saveSession(role: UserRole, doctorID: UUID? = nil, patientID: UUID? = nil) {
        currentRole = role
        if let doctorID = doctorID {
            persistedDoctorID = doctorID.uuidString
        }
        if let patientID = patientID {
            persistedPatientID = patientID.uuidString
        }
    }
    
    // MARK: - Clear session on logout
    func clearSession() {
        currentRole = .none
        currentDoctor = nil
        currentPatient = nil
        persistedDoctorID = nil
        persistedPatientID = nil
        UserDefaults.standard.removeObject(forKey: roleKey)
        UserDefaults.standard.removeObject(forKey: doctorIDKey)
        UserDefaults.standard.removeObject(forKey: patientIDKey)
    }
    
    // MARK: - Quick check helpers
    var isLoggedIn: Bool {
        return currentRole != .none
    }
    
    var isDoctor: Bool {
        return currentRole == .doctor
    }
    
    var isPatient: Bool {
        return currentRole == .patient
    }
}
