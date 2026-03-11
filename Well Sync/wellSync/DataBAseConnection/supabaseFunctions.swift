//
//  supabaseFunctions.swift
//  wellSync
//
//  Created by Vidit Agarwal on 14/02/26.
//

import Supabase
import UIKit

class AccessSupabase{
    let decoder = JSONDecoder()

    let formatter = DateFormatter()
    required init (){
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(formatter)
    }
    func fetchDoctors() async {
        Task {
            do {
                let response = try await SupabaseManager.shared.client
                    .database
                    .from("doctor")
                    .select()
                    .execute()

                let doctors = try JSONDecoder().decode([Doctor].self, from: response.data)

                for i in doctors{
                    print(i,"\n")
                }
            } catch {
                print("Error:", error)
            }
        }
    }


    func fetchPatients(for doctorId: UUID) async -> [Patient] {
//        do {
//                let response = try await SupabaseManager.shared.client
//                    .database
//                    .from("patients")
//                    .select()
//                    .eq("doc_id", value: doctorId.uuidString)
//                    .execute()
//
//                var patients = try decoder.decode([Patient].self, from: response.data)
//
//                await withTaskGroup(of: (Int, Int?, Date?).self) { group in
//                    for (idx, p) in patients.enumerated() {
//                        group.addTask {
//                            let mood = await self.fetchMood(for: p.patientID)
//                            let prev = await self.fetchSession(for: p.patientID)
//                            return (idx, mood, prev)
//                        }
//                    }
//
//                    for await (idx, mood, prev) in group {
//                        patients[idx].mood = mood
//                        patients[idx].previousSessionDate = prev
//                    }
//                }
//                print("---------------->",patients)
//                return patients

            
        
        do {
            let response = try await SupabaseManager.shared.client
                .database
                .from("patients")
                .select()
                .eq("doc_id", value: doctorId.uuidString)
                .execute()

//            print(String(data: response.data, encoding: .utf8)!)

            var patients = try JSONDecoder().decode([Patient].self, from: response.data)
//            let patients = try decoder.decode([Patient].self, from: response.data)
            for var i in patients{

                    i.mood = await fetchMood(for: i.patientID)
                    i.previousSessionDate = await fetchSession(for: i.patientID)
//                print("//\(String(describing: i.mood)) \t \(String(describing: i.previousSessionDate))\n")
            }
//            print("------------>",patients)
            return patients

        } catch {
            print("Supabase Error:", error)
        }
        return []
    }

    func fetchMood(for patientId: UUID) async -> Int?{
        do {
            let response = try await SupabaseManager.shared.client
                .database
                .from("mood_logs")
                .select("mood")
                .eq("patient_id", value: patientId.uuidString)
                .execute()

//            print(String(data: response.data, encoding: .utf8)!)

//            print("\n\n\n\n\n\n")
            let mood = try JSONDecoder().decode([MoodLog].self, from: response.data)
//            print("\n\(mood)\n")
            return mood[0].mood

        } catch {
            print("Supabase Error:", error)
        }
        return nil
    }

    func fetchSession(for patientId: UUID) async -> Date?{
        do {
            let response = try await SupabaseManager.shared.client
                .database
                .from("session_notes")
                .select()
                .eq("patient_id", value: patientId.uuidString)
                .execute()
            

            let session = try decoder.decode([SessionNote].self, from: response.data)

//            print("---------------->",session[0].date)
            if session.count == 0{
                return nil
            }
            return session[0].date
        } catch {
            print("Supabase Error:", error)
        }
        return nil
    }

//    func fetchSession(for patientId: UUID) async -> Date? {
//        do {
//            let response = try await SupabaseManager.shared.client
//                .database
//                .from("session_notes")
//                .select()
//                .eq("patient_id", value: patientId.uuidString)
//                .execute()
//
//            // Print raw JSON string for debugging
//            let raw = String(data: response.data, encoding: .utf8) ?? "<invalid utf8>"
//            print("raw response:", raw)
//
//            let decoder = JSONDecoder()
//
//            // Try multiple date formats: ISO8601 first, then fallback to "yyyy-MM-dd'T'HH:mm:ss"
//            decoder.dateDecodingStrategy = .custom { decoder -> Date in
//                let container = try decoder.singleValueContainer()
//
//                if let str = try? container.decode(String.self) {
//                    // 1) Try ISO8601 (with timezone)
//                    let iso = ISO8601DateFormatter()
//                    if let d = iso.date(from: str) { return d }
//
//                    // 2) Try plain "yyyy-MM-dd'T'HH:mm:ss" (no timezone)
//                    let df = DateFormatter()
//                    df.locale = Locale(identifier: "en_US_POSIX")
//                    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//                    if let d = df.date(from: str) { return d }
//
//                    // 3) Try common fractional-second ISO formats
//                    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//                    if let d = df.date(from: str) { return d }
//
//                    throw DecodingError.dataCorruptedError(in: container,
//                                                           debugDescription: "Unrecognized date: \(str)")
//                }
//
//                // 4) Maybe server returned a timestamp number
//                if let timestamp = try? container.decode(Double.self) {
//                    return Date(timeIntervalSince1970: timestamp)
//                }
//
//                throw DecodingError.dataCorruptedError(in: container,
//                                                       debugDescription: "Cannot decode date value")
//            }
//
//            // If you prefer, you can also use `decoder.keyDecodingStrategy = .convertFromSnakeCase`
//            // but we've defined CodingKeys above to be explicit.
//            let sessions = try decoder.decode([SessionNote].self, from: response.data)
//            print("decoded sessions:", sessions)
//
//            return sessions.first?.date
//
//        } catch {
//            print("Supabase Error:", error)
//        }
//        return nil
//    }
    
}
