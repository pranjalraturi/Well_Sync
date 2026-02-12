//
//  File.swift
//  wellSync
//
//  Created by Vidit Agarwal on 11/02/26.
//

import Foundation
import HealthKit
import UIKit
class AccessHealthKit{
    var healthStore: HKHealthStore = HKHealthStore()
    init(){
        requestHealthPermission()
    }
    func requestHealthPermission() {
            if HKHealthStore.isHealthDataAvailable() {
                let readTypes: Set<HKObjectType> = [
                    HKObjectType.quantityType(forIdentifier: .heartRate)!,
                    HKObjectType.quantityType(forIdentifier: .stepCount)!,
                    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                    HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                    HKObjectType.quantityType(forIdentifier: .height)!,
                    HKObjectType.quantityType(forIdentifier: .bodyMass)!
                ]

                healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
                    if success {
                        print("HealthKit Permission Granted")
                    } else {
                        print("HealthKit Permission Failed")
                    }
                }
            }
        }

        // MARK: - Fetch Functions

    func fetchHeartRate(_ heartRateLabel:UILabel) {
            fetchLatestSample(type: .heartRate, unit: HKUnit(from: "count/min")) {
                heartRateLabel.text = "\($0)"
            }
        }

    func fetchSteps(_ stepsLabel:UILabel) {
            fetchLatestSample(type: .stepCount, unit: HKUnit.count()) {
                stepsLabel.text = "\($0)"
            }
        }

    func fetchCalories(_ caloriesLabel:UILabel) {
            fetchLatestSample(type: .activeEnergyBurned, unit: HKUnit.kilocalorie()) {
                caloriesLabel.text = "\($0)"
            }
        }

    func fetchSpO2(_ spo2Label: UILabel) {
            fetchLatestSample(type: .oxygenSaturation, unit: HKUnit.percent()) {
                spo2Label.text = "🩸 SpO2: \(Double($0)! * 100)%"
            }
        }

    func fetchHeight(_ heightLabel : UILabel) {
            fetchLatestSample(type: .height, unit: HKUnit.meter()) {
            heightLabel.text = "🧍 Height: \($0) m"
            }
        }

    func fetchWeight(_ weightLabel : UILabel) {
            fetchLatestSample(type: .bodyMass, unit: HKUnit.gramUnit(with: .kilo)) {
                weightLabel.text = "⚖️ Weight: \($0) kg"
            }
        }

        // MARK: - Generic Fetch

        func fetchLatestSample(type: HKQuantityTypeIdentifier, unit: HKUnit, completion: @escaping (String) -> Void) {
            guard let sampleType = HKQuantityType.quantityType(forIdentifier: type) else { return }

            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: sampleType,
                                      predicate: nil,
                                      limit: 1,
                                      sortDescriptors: [sortDescriptor]) { _, results, _ in
                if let sample = results?.first as? HKQuantitySample {
                    let value = sample.quantity.doubleValue(for: unit)
                    DispatchQueue.main.async {
                        completion(String(format: "%.2f", value))
                    }
                }
            }

            healthStore.execute(query)
        }
}
