//
//  VitalLogTableViewController.swift
//  wellSync
//
//  Created by Rishika Mittal on 11/02/26.
//

import UIKit

class VitalLogTableViewController: UITableViewController {
    
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var startSleep: UIDatePicker!
    @IBOutlet weak var endSleep: UIDatePicker!
    var onSave:(()->Void)?
    var patient:Patient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 2
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    @IBAction func savedata(_ sender: UIBarButtonItem) {
        guard let patient = patient else { return }

        let start = startSleep.date
        let end = endSleep.date

        guard end > start else {
            print("Invalid time")
            return
        }

        let duration = end.timeIntervalSince(start) / 60

        let qualityText = textField2.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        let log = sleepVital(
            id: nil,
            patient_id: patient.patientID,
            start_time: start,
            end_time: end,
            duration_minutes: duration,
            quality: (qualityText?.isEmpty == true ? "" : qualityText)! // ✅ FIX
        )

        Task {
            do {
                // ✅ HealthKit optional (won't crash if denied)
                try await AccessHealthKit.healthKit.saveSleepToHealthKit(
                    startTime: start,
                    endTime: end
                )

                // ✅ Always save to DB
                try await AccessSupabase.shared.saveSleepLog(log)

                print("✅ Saved to DB")
                onSave?()
                dismiss(animated: true)

            } catch {
                print("❌ DB Save error: \(error)")
            }
        }
    }
    @IBAction func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

