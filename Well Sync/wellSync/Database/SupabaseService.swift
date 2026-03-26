//
//  SupabaseManager.swift
//  wellSync
//
//  Created by Rishika Mittal on 20/03/26.
//

import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient()
    }
    
    func signUp(email: String, password: String) async throws -> UUID {
            let response = try await client.auth.signUp(
                email: email,
                password: password
            )
            let user = response.user
            return user.id
        }
        
        // MARK: - Sign In (for Login Screen)
        // Returns the logged-in auth user's UUID
        func signIn(email: String, password: String) async throws -> UUID {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            return session.user.id
        }
        
        // MARK: - Sign Out
        func signOut() async throws {
            try await client.auth.signOut()
            SessionManager.shared.clearSession()
        }
        
        // MARK: - Get current Auth session (used on app launch)
        // Returns the auth user's UUID if they are still logged in, nil otherwise
        func getCurrentAuthUserID() async -> UUID? {
            do {
                let session = try await client.auth.session
                return session.user.id
            } catch {
                return nil
            }
        }
        
        // MARK: - Determine Role from auth_id
        // Checks doctors table first, then patients table
        func resolveRole(authID: UUID) async throws -> UserRole {
            // Try doctors table
            let doctors: [Doctor] = try await client
                .from("doctors")
                .select()
                .eq("auth_id", value: authID.uuidString)
                .limit(1)
                .execute()
                .value
            
            if !doctors.isEmpty {
                return .doctor
            }
            
            // Try patients table
            let patients: [Patient] = try await client
                .from("patients")
                .select()
                .eq("auth_id", value: authID.uuidString)
                .limit(1)
                .execute()
                .value
            
            if !patients.isEmpty {
                return .patient
            }
            
            throw NSError(domain: "AuthError", code: 404,
                         userInfo: [NSLocalizedDescriptionKey: "No profile found for this user"])
        }
}
