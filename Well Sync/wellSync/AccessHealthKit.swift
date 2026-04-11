//
//  File.swift
//  wellSync
//
//  Created by Vidit Agarwal on 11/02/26.
//

import Foundation
import HealthKit

class AccessHealthKit {
    
    let healthStore = HKHealthStore()
    static let healthKit = AccessHealthKit()
    
    init() {
        askForPermission()
    }
    func askForPermission() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit not available")
            return
        }

        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
              let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }

        let readTypes: Set<HKObjectType> = [stepType, sleepType]
        let writeTypes: Set<HKSampleType> = [sleepType]

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            if success {
                print("✅ HealthKit permission granted")
            } else {
                print("❌ Permission error: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }
    func getSteps(howManyDaysBack days: Int,
                  completion: @escaping ([Date: Double]) -> Void) {
        
        // 1. Figure out the date range
        let endDate   = Date()  // today/now
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate)!
        
        // 2. Get the step count type
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        // 3. Create a filter to only get data in our date range
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        // 4. Create the query
        let query = HKSampleQuery(sampleType: stepType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { _, results, error in
            
            // If something went wrong, return empty
            if let error = error {
                print("Steps error: \(error)")
                DispatchQueue.main.async { completion([:]) }
                return
            }
            
            // 5. Group steps by day and add them up
            // (Apple Watch records steps every few minutes, so we sum per day)
            var stepsByDay: [Date: Double] = [:]
            
            for sample in (results as? [HKQuantitySample]) ?? [] {
                let day = Calendar.current.startOfDay(for: sample.startDate) // strip the time, keep only the date
                let steps = sample.quantity.doubleValue(for: .count())
                stepsByDay[day, default: 0] += steps // add to that day's total
            }
            
            // 6. Send the result back on the main thread (safe for UI updates)
            DispatchQueue.main.async {
                completion(stepsByDay)
            }
        }
        
        // 5. Run the query
        healthStore.execute(query)
    }
    
    // MARK: - Step 3: Fetch Sleep
    
    // This is a single sleep record — makes it easy to understand each sleep interval
    struct SleepRecord {
        var startTime: Date
        var endTime: Date
        var stage: String       // e.g. "Deep Sleep", "REM Sleep", "Awake"
        var durationMinutes: Double
    }
    
    // Call this function to get sleep data
    func getSleep(howManyNightsBack nights: Int,
                  completion: @escaping ([SleepRecord]) -> Void) {
        
        // 1. Use noon-to-noon range so we don't cut overnight sessions in half
        //    e.g. if tonight = April 8, we go from April 1 noon → April 8 noon
        let calendar  = Calendar.current
        let noonToday = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        let startDate = calendar.date(byAdding: .day, value: -nights, to: noonToday)!
        
        // 2. Get the sleep type
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        // 3. Create a filter for our date range
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: noonToday)
        
        // 4. Create the query
        let query = HKSampleQuery(sampleType: sleepType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { _, results, error in
            
            // If something went wrong, return empty
            if let error = error {
                print("Sleep error: \(error)")
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            // 5. Convert each raw sample into our simple SleepRecord
            var sleepRecords: [SleepRecord] = []
            
            for sample in (results as? [HKCategorySample]) ?? [] {
                
                // Figure out what stage this interval is
                let stage: String
                switch HKCategoryValueSleepAnalysis(rawValue: sample.value) {
                case .inBed:             stage = "In Bed"
                case .awake:             stage = "Awake"
                case .asleepCore:        stage = "Core Sleep"
                case .asleepDeep:        stage = "Deep Sleep"
                case .asleepREM:         stage = "REM Sleep"
                case .asleep,
                     .asleepUnspecified: stage = "Asleep"
                default:                 stage = "Unknown"
                }
                
                // Calculate how long this interval lasted
                let durationMinutes = sample.endDate.timeIntervalSince(sample.startDate) / 60
                
                // Build our simple record
                let record = SleepRecord(startTime: sample.startDate,
                                         endTime: sample.endDate,
                                         stage: stage,
                                         durationMinutes: durationMinutes)
                sleepRecords.append(record)
            }
            
            // 6. Send the result back on the main thread
            DispatchQueue.main.async {
                completion(sleepRecords)
            }
        }
        
        // 7. Run the query
        healthStore.execute(query)
    }
    // Fetch steps for a specific date range (used by the cell)
    func getSteps(from startDate: Date, to endDate: Date,
                  completion: @escaping ([Date: Double]) -> Void) {

        let stepType  = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

        let query = HKSampleQuery(sampleType: stepType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { _, results, error in

            if let error = error {
                print("Steps error: \(error)")
                DispatchQueue.main.async { completion([:]) }
                return
            }

            var stepsByDay: [Date: Double] = [:]
            for sample in (results as? [HKQuantitySample]) ?? [] {
                let day = Calendar.current.startOfDay(for: sample.startDate)
                stepsByDay[day, default: 0] += sample.quantity.doubleValue(for: .count())
            }

            DispatchQueue.main.async { completion(stepsByDay) }
        }

        healthStore.execute(query)
    }

    // Fetch sleep for a specific date range (used by the cell)
    func getSleep(from startDate: Date, to endDate: Date,
                  completion: @escaping ([SleepRecord]) -> Void) {

        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

        let query = HKSampleQuery(sampleType: sleepType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { _, results, error in

            if let error = error {
                print("Sleep error: \(error)")
                DispatchQueue.main.async { completion([]) }
                return
            }

            var records: [SleepRecord] = []
            for sample in (results as? [HKCategorySample]) ?? [] {
                let stage: String
                switch HKCategoryValueSleepAnalysis(rawValue: sample.value) {
                case .inBed:             stage = "In Bed"
                case .awake:             stage = "Awake"
                case .asleepCore:        stage = "Core Sleep"
                case .asleepDeep:        stage = "Deep Sleep"
                case .asleepREM:         stage = "REM Sleep"
                case .asleep,
                     .asleepUnspecified: stage = "Asleep"
                default:                 stage = "Unknown"
                }

                let durationMinutes = sample.endDate.timeIntervalSince(sample.startDate) / 60
                records.append(SleepRecord(startTime: sample.startDate,
                                           endTime: sample.endDate,
                                           stage: stage,
                                           durationMinutes: durationMinutes))
            }

            DispatchQueue.main.async { completion(records) }
        }

        healthStore.execute(query)
    }
    
    private func isAsleep(_ value: HKCategoryValueSleepAnalysis) -> Bool {
        switch value {
        case .asleep,
             .asleepUnspecified,
             .asleepCore,
             .asleepDeep,
             .asleepREM:
            return true
        default:
            return false
        }
    }
    func syncSleepToSupabase(patientID: UUID, nightsBack: Int) {
        getSleep(howManyNightsBack: nightsBack) { hkRecords in

            Task {
                do {
                    // ── 1. Filter only actual sleep from HealthKit
                    let hkSleep = hkRecords.filter {
                        $0.stage.contains("Sleep") || $0.stage == "Asleep"
                    }
                    print("📱 HealthKit sleep records:", hkSleep.count)

                    // ── 2. Fetch what's already in Supabase
                    let dbLogs = try await AccessSupabase.shared.fetchSleepLogs(for: patientID)
                    print("🗄️ Supabase sleep records:", dbLogs.count)

                    // ── 3. HK → Supabase
                    //       Build a set of existing (start, end) pairs from DB for fast lookup
                    let dbKeys = Set(dbLogs.map {
                        "\($0.start_time.timeIntervalSince1970)-\($0.end_time.timeIntervalSince1970)"
                    })

                    let logsToInsert = hkSleep
                        .filter { hk in
                            let key = "\(hk.startTime.timeIntervalSince1970)-\(hk.endTime.timeIntervalSince1970)"
                            return !dbKeys.contains(key)
                        }
                        .map {
                            sleepVital(
                                id: nil,
                                patient_id: patientID,
                                start_time: $0.startTime,
                                end_time: $0.endTime,
                                duration_minutes: $0.durationMinutes,
                                quality: $0.stage
                            )
                        }

                    if logsToInsert.isEmpty {
                        print("✅ HK→DB: nothing new to insert")
                    } else {
                        try await AccessSupabase.shared.saveSleepLogs(logsToInsert)
                        print("✅ HK→DB: inserted \(logsToInsert.count) records")
                    }

                    // ── 4. Supabase → HealthKit
                    //       Build a set of existing HK (start, end) pairs for fast lookup
                    let hkKeys = Set(hkSleep.map {
                        "\($0.startTime.timeIntervalSince1970)-\($0.endTime.timeIntervalSince1970)"
                    })

                    let logsToWriteToHK = dbLogs.filter { db in
                        let key = "\(db.start_time.timeIntervalSince1970)-\(db.end_time.timeIntervalSince1970)"
                        return !hkKeys.contains(key)
                    }

                    if logsToWriteToHK.isEmpty {
                        print("✅ DB→HK: nothing new to write")
                    } else {
                        for log in logsToWriteToHK {
                            try await self.saveSleepToHealthKit(
                                startTime: log.start_time,
                                endTime: log.end_time
                            )
                        }
                        print("✅ DB→HK: wrote \(logsToWriteToHK.count) records to HealthKit")
                    }

                } catch {
                    print("❌ Sync error:", error)
                }
            }
        }
    }
    func syncStepsToSupabase(patientID: UUID, daysBack: Int) {

        let endDate   = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: endDate)!

        // Step 1: Get steps from HealthKit
        getSteps(from: startDate, to: endDate) { hkStepsByDay in

            print("📱 HealthKit days with steps:", hkStepsByDay.count)

            guard !hkStepsByDay.isEmpty else {
                print("❌ No steps data from HealthKit")
                return
            }

            Task {
                do {
                    let calendar = Calendar.current

                    // Step 2: Convert [Date: Double] → [StepsVital]
                    // One row per day — upsert will INSERT or UPDATE automatically
                    let logs: [StepsVital] = hkStepsByDay.map { (date, steps) in
                        StepsVital(
                            id:         nil,
                            patient_id: patientID,
                            log_date:   calendar.startOfDay(for: date),
                            step_count: steps
                        )
                    }

                    // Step 3: Upsert to Supabase
                    // If morning had 500 and now it's 1200 → row gets updated automatically
                    try await AccessSupabase.shared.saveStepsLogs(logs)
                    print("✅ Synced \(logs.count) step logs to Supabase")

                } catch {
                    print("❌ Steps sync error:", error)
                }
            }
        }
    }
    func removeDuplicateLogs(newLogs: [sleepVital], existingLogs: [sleepVital]) -> [sleepVital] {

        let existingSet = Set(existingLogs.map {
            "\($0.start_time)-\($0.end_time)"
        })

        return newLogs.filter {
            !existingSet.contains("\($0.start_time)-\($0.end_time)")
        }
    }
   
    func saveSleepToHealthKit(startTime: Date, endTime: Date) async throws {

        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw NSError(domain: "HK", code: 1)
        }

        let sample = HKCategorySample(
            type: sleepType,
            value: HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            start: startTime,
            end: endTime
        )

        try await withCheckedThrowingContinuation { cont in
            healthStore.save(sample) { success, error in
                if success {
                    cont.resume()
                } else {
                    cont.resume(throwing: error ?? NSError(domain: "HK", code: 2))
                }
            }
        }
    }
    
}
