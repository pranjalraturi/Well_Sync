//
//  AccessHealthKit.swift
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
              let stepType  = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }

        let readTypes:  Set<HKObjectType>  = [stepType, sleepType]
        let writeTypes: Set<HKSampleType>  = [sleepType]

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            if success {
                print("✅ HealthKit permission granted")
            } else {
                print("❌ Permission error: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }

    // MARK: - Date Precision Helper
    //
    // ROOT CAUSE OF "ON CONFLICT DO UPDATE command cannot affect row a second time":
    //
    // HealthKit timestamps have sub-second precision (e.g. 05:41:45.769 and 05:41:45.770).
    // Our Swift dedup key used full Double precision so those two dates looked DIFFERENT
    // in Swift — both passed the dedup filter and both ended up in the upsert batch.
    // However, the Supabase SDK encodes Date to ISO8601 WITHOUT fractional seconds
    // (e.g. "2026-04-11T05:41:45Z"), so Postgres received two rows with IDENTICAL
    // start_time / end_time strings in the same command → error 21000.
    //
    // Fix: truncate every Date to second precision BEFORE building the dedup key AND
    // before storing it in the struct. This makes the Swift key match exactly what
    // the Supabase SDK will send to Postgres.

    private func floorToSecond(_ date: Date) -> Date {
        Date(timeIntervalSince1970: floor(date.timeIntervalSince1970))
    }

    private func dedupKey(start: Date, end: Date) -> String {
        // Both dates must already be second-precision (call floorToSecond first)
        "\(start.timeIntervalSince1970)-\(end.timeIntervalSince1970)"
    }

    // MARK: - Fetch Steps (last N days)

    func getSteps(howManyDaysBack days: Int,
                  completion: @escaping ([Date: Double]) -> Void) {
        let endDate   = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate)!
        getSteps(from: startDate, to: endDate, completion: completion)
    }

    // MARK: - Fetch Steps (date range)

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

    // MARK: - Sleep Record Model

    struct SleepRecord {
        var startTime: Date
        var endTime: Date
        var stage: String
        var durationMinutes: Double
    }

    // MARK: - Fetch Sleep (last N nights)

    func getSleep(howManyNightsBack nights: Int,
                  completion: @escaping ([SleepRecord]) -> Void) {
        let calendar  = Calendar.current
        let noonToday = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        let startDate = calendar.date(byAdding: .day, value: -nights, to: noonToday)!
        getSleep(from: startDate, to: noonToday, completion: completion)
    }

    // MARK: - Fetch Sleep (date range)

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
                                           endTime:   sample.endDate,
                                           stage:     stage,
                                           durationMinutes: durationMinutes))
            }

            DispatchQueue.main.async { completion(records) }
        }

        healthStore.execute(query)
    }

    // MARK: - Sync Sleep: HealthKit ↔ Supabase (Two-Way)

    func syncSleepToSupabase(patientID: UUID, nightsBack: Int) {

        let calendar  = Calendar.current
        let noonToday = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        let syncStart = calendar.date(byAdding: .day, value: -nightsBack, to: noonToday)!

        getSleep(howManyNightsBack: nightsBack) { [weak self] hkRecords in
            guard let self = self else { return }

            Task {
                do {
                    // ── 1. Filter only actual sleep stages from HealthKit
                    let hkSleep = hkRecords.filter {
                        $0.stage.contains("Sleep") || $0.stage == "Asleep"
                    }
                    print("📱 HealthKit sleep records:", hkSleep.count)

                    // ── 2. Fetch what's already in Supabase
                    let dbLogs = try await AccessSupabase.shared.fetchSleepLogs(for: patientID)
                    print("🗄️ Supabase sleep records:", dbLogs.count)

                    // ── 3. HK → Supabase
                    //
                    // Build DB key set using second-precision dates.
                    // DB records inserted after this fix have second precision already.
                    // Old records with ms precision are also floored here so they still
                    // match and don't get re-inserted.
                    let dbKeys = Set(dbLogs.map { log -> String in
                        let s = self.floorToSecond(log.start_time)
                        let e = self.floorToSecond(log.end_time)
                        return self.dedupKey(start: s, end: e)
                    })

                    // Filter HK records not already in DB (compare at second precision)
                    let candidates = hkSleep.filter { hk in
                        let s = self.floorToSecond(hk.startTime)
                        let e = self.floorToSecond(hk.endTime)
                        return !dbKeys.contains(self.dedupKey(start: s, end: e))
                    }

                    // Deduplicate WITHIN the batch at second precision.
                    // This catches two HK records that are only milliseconds apart —
                    // they have different Swift Double keys but encode to the same
                    // ISO8601 string in the Supabase JSON payload → Postgres error 21000.
                    var seenSleepKeys = Set<String>()
                    let logsToInsert: [sleepVital] = candidates.compactMap { hk in
                        let normalStart = self.floorToSecond(hk.startTime)
                        let normalEnd   = self.floorToSecond(hk.endTime)
                        let key         = self.dedupKey(start: normalStart, end: normalEnd)
                        guard seenSleepKeys.insert(key).inserted else { return nil }
                        return sleepVital(
                            id:               nil,
                            patient_id:       patientID,
                            start_time:       normalStart,   // ← second precision
                            end_time:         normalEnd,     // ← second precision
                            duration_minutes: hk.durationMinutes,
                            quality:          hk.stage
                        )
                    }

                    if logsToInsert.isEmpty {
                        print("✅ HK→DB: nothing new to insert")
                    } else {
                        try await AccessSupabase.shared.saveSleepLogs(logsToInsert)
                        print("✅ HK→DB: inserted \(logsToInsert.count) records")
                    }

                    // ── 4. Supabase → HealthKit
                    // Build HK key set at second precision to match the DB keys.
                    let hkKeys = Set(hkSleep.map { hk -> String in
                        let s = self.floorToSecond(hk.startTime)
                        let e = self.floorToSecond(hk.endTime)
                        return self.dedupKey(start: s, end: e)
                    })

                    let logsToWriteToHK = dbLogs.filter { db in
                        // Only look at records within the current sync window
                        guard db.start_time >= syncStart else { return false }
                        let s   = self.floorToSecond(db.start_time)
                        let e   = self.floorToSecond(db.end_time)
                        let key = self.dedupKey(start: s, end: e)
                        return !hkKeys.contains(key)
                    }

                    if logsToWriteToHK.isEmpty {
                        print("✅ DB→HK: nothing new to write")
                    } else {
                        for log in logsToWriteToHK {
                            try await self.saveSleepToHealthKit(
                                startTime: log.start_time,
                                endTime:   log.end_time
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

    // MARK: - Sync Steps: HealthKit → Supabase (One-Way)

    func syncStepsToSupabase(patientID: UUID, daysBack: Int) {

        let endDate   = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: endDate)!

        getSteps(from: startDate, to: endDate) { hkStepsByDay in

            print("📱 HealthKit days with steps:", hkStepsByDay.count)
            guard !hkStepsByDay.isEmpty else {
                print("❌ No steps data from HealthKit")
                return
            }

            Task {
                do {
                    let calendar = Calendar.current

                    // Re-aggregate by startOfDay to guard against any Calendar timezone
                    // edge case producing two slightly different Date values for the same
                    // calendar day. Dictionary keying collapses them into one entry and
                    // sums their step counts, so the final batch has one row per day.
                    var dedupedByDay: [Date: Double] = [:]
                    for (date, steps) in hkStepsByDay {
                        let day = calendar.startOfDay(for: date)
                        dedupedByDay[day, default: 0] += steps
                    }

                    let logs: [StepsVital] = dedupedByDay.map { (date, steps) in
                        StepsVital(
                            id:         nil,
                            patient_id: patientID,
                            log_date:   date,
                            step_count: steps
                        )
                    }

                    try await AccessSupabase.shared.saveStepsLogs(logs)
                    print("✅ Synced \(logs.count) step logs to Supabase")

                } catch {
                    print("❌ Steps sync error:", error)
                }
            }
        }
    }

    // MARK: - Deduplication Helper

    func removeDuplicateLogs(newLogs: [sleepVital], existingLogs: [sleepVital]) -> [sleepVital] {
        let existingSet = Set(existingLogs.map {
            "\(floorToSecond($0.start_time).timeIntervalSince1970)-\(floorToSecond($0.end_time).timeIntervalSince1970)"
        })
        return newLogs.filter {
            !existingSet.contains(
                "\(floorToSecond($0.start_time).timeIntervalSince1970)-\(floorToSecond($0.end_time).timeIntervalSince1970)"
            )
        }
    }

    // MARK: - Write Sleep Record to HealthKit

    func saveSleepToHealthKit(startTime: Date, endTime: Date) async throws {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw NSError(domain: "HK", code: 1)
        }

        let sample = HKCategorySample(
            type:  sleepType,
            value: HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            start: startTime,
            end:   endTime
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

    // MARK: - Private Helpers

    private func isAsleep(_ value: HKCategoryValueSleepAnalysis) -> Bool {
        switch value {
        case .asleep, .asleepUnspecified, .asleepCore, .asleepDeep, .asleepREM:
            return true
        default:
            return false
        }
    }
}
