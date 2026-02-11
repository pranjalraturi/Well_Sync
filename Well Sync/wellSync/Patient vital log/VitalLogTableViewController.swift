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
    @IBOutlet weak var heartText1: UITableViewCell!
//    @IBOutlet weak var section1: UITableViewSection!
    @IBOutlet weak var heartLabel1: UITableViewCell!
    
    // Track which segment is selected
    var selectedLogType: LogType = .heartRate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Optionally set default selected segment
        segmentedControl.selectedSegmentIndex = 0
        heartText1.isHidden = true
        heartLabel1.isHidden = true
    }
    
    // IBAction for the segmented control, connect this in Interface Builder
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        selectedLogType = sender.selectedSegmentIndex == 0 ? .heartRate : .sleep
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 4
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0{
//            return 1
//        }
//        return 2 // Example: always 1 row per segment (customize as needed)
//    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch selectedLogType {
//        case .heartRate:
//            
//        case .sleep:
//            
//        }
//    }
}

