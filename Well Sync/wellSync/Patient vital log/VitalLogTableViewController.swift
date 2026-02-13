//
//  VitalLogTableViewController.swift
//  wellSync
//
//  Created by Rishika Mittal on 11/02/26.
//

import UIKit

// Enum to represent which log type is selected
enum LogType {
    case heartRate
    case sleep
}

class VitalLogTableViewController: UITableViewController {
    
    // Outlet to connect your segmented control from Interface Builder
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var heartText1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    //    @IBOutlet weak var section1: UITableViewSection!
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var startSleep: UIDatePicker!
    @IBOutlet weak var endSleep: UIDatePicker!
    
    let textfield2 = IndexPath(row: 1, section: 3)
    let textfield1 = IndexPath(row: 1, section: 2)
    
    var istextfieldVisible1: Bool = false
    var istextfieldVisible2: Bool = false
    
    // Track which segment is selected
    var selectedLogType: LogType = .heartRate

    func setTextFieldVisibility(isVisible1: Bool, isVisible2: Bool) {
        let oldVisible1 = istextfieldVisible1
        let oldVisible2 = istextfieldVisible2
        
        istextfieldVisible1 = isVisible1
        istextfieldVisible2 = isVisible2
        
        var inserts: [IndexPath] = []
        var deletes: [IndexPath] = []
        
        if oldVisible1 != isVisible1 {
            let ip = IndexPath(row: 1, section: 2)
            if isVisible1 {
                inserts.append(ip)
            } else {
                deletes.append(ip)
            }
        }
        
        if oldVisible2 != isVisible2 {
            let ip = IndexPath(row: 1, section: 3)
            if isVisible2 {
                inserts.append(ip)
            } else {
                deletes.append(ip)
            }
        }
        
        tableView.beginUpdates()
        if !deletes.isEmpty {
            tableView.deleteRows(at: deletes, with: .middle)
        }
        if !inserts.isEmpty {
            tableView.insertRows(at: inserts, with: .middle)
        }
        tableView.endUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Optionally set default selected segment
        updateLabels()
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // For section 2 (textfield1)
        if section == 2 {
            return istextfieldVisible1 ? 2 : 1  // Hide the row if not visible
        }
        
        // For section 4 (textfield2)
        if section == 3 {
            return istextfieldVisible2 ? 2 : 1  // Hide the row if not visible
        }
        
        // Default row count for other sections
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func updateLabels() {
        if selectedLogType == .heartRate {
            startSleep.isHidden = true
            endSleep.isHidden = true
            
            Label1.text = "Enter your heart rate"
            label2.text = "What were you doing at that time?"
            label3.text = "Device used for measurement"
            
            setTextFieldVisibility(isVisible1: true, isVisible2: true)
        }
        else {
            startSleep.isHidden = false
            endSleep.isHidden = false
            
            Label1.text = "Start Time"
            label2.text = "End Time"
            label3.text = "I felt that the quality of sleep was?"
            
            setTextFieldVisibility(isVisible1: false, isVisible2: false)
        }
    }

    // IBAction for the segmented control, connect this in Interface Builder
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        selectedLogType = sender.selectedSegmentIndex == 0 ? .heartRate : .sleep
        updateLabels()
    }
    @IBAction func savedata(_ sender: UIBarButtonItem) {
        if selectedLogType == .heartRate {
            
        }
        else{
            
        }
    }
}

