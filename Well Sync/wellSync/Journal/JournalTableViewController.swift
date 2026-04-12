//
//  JournalTableViewController.swift
//  wellSync
//
//  Created by Pranjal on 07/02/26.
//

import UIKit

class JournalTableViewController: UITableViewController {
    
    // MARK: - Properties
    var currentAssignmentLogs: [JournalEntry] = []  // Logs for THIS assignment only
    var allActivityLogs: [JournalEntry] = []        // ALL logs for this activity
    
    // Passed from previous screen
    var selectedAssignment: AssignedActivity?
    var selectedActivity: Activity?
    var patient: Patient?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isUserInteractionEnabled = true
        tableView.allowsSelection = true  // ADD THIS
        
        // Set navigation title
        if let activity = selectedActivity {
            self.title = activity.name
        }
        
        // Load real data from database
        loadJournalData()
    }
    
    // MARK: - Data Loading
    
    func loadJournalData() {
        guard let assignment = selectedAssignment,
              let activity = selectedActivity,
              let patientID = patient?.patientID else {
            print("Missing required data")
            return
        }
        
        Task {
            do {
                // STEP 1: Fetch logs for THIS SPECIFIC assignment (Current section)
                let currentLogs = try await AccessSupabase.shared.fetchLogsForAssignment(
                    assignment.assignedID  // Changed method name
                )
                
                // STEP 2: Fetch ALL assignments for this activity for this patient
                let allAssignments = try await AccessSupabase.shared.fetchAssignments(
                    for: patientID,
                    activityID: activity.activityID
                )
                
                // STEP 3: Fetch logs for ALL assignments of this activity
                var allLogs: [ActivityLog] = []
                for assign in allAssignments {
                    let logs = try await AccessSupabase.shared.fetchLogsForAssignment(
                        assign.assignedID  // Changed method name
                    )
                    allLogs.append(contentsOf: logs)
                }
                
                // STEP 4: Convert to JournalEntry
                let currentEntries = currentLogs.map { log in
                    JournalEntry(from: log, assignment: assignment)
                }
                
                var previousEntries: [JournalEntry] = []
                for log in allLogs {
                    if let logAssignment = allAssignments.first(where: { $0.assignedID == log.assignedID }) {
                        let entry = JournalEntry(from: log, assignment: logAssignment)
                        previousEntries.append(entry)
                    }
                }
                
                // STEP 5: Sort and assign
                self.currentAssignmentLogs = currentEntries.sorted { $0.date > $1.date }
                self.allActivityLogs = previousEntries.sorted { $0.date > $1.date }
                
                // Reload table on main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
                print("Error loading journal data: \(error)")
                DispatchQueue.main.async {
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    func showErrorAlert(message: String? = nil) {
        let alert = UIAlertController(
            title: "Error",
            message: message ?? "Failed to load journal entries. Please try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? currentAssignmentLogs.count : allActivityLogs.count
    }
    
    override func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalTableCell",
                                                 for: indexPath) as! JournalTableViewCell
        
        let entry = indexPath.section == 0
            ? currentAssignmentLogs[indexPath.row]
            : allActivityLogs[indexPath.row]
        
        cell.configure(with: entry, sender: Any?.self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        if section == 0 && !currentAssignmentLogs.isEmpty {
            return "Current Assignment"
        }
        if section == 1 && !allActivityLogs.isEmpty {
            return "All Previous Logs"
        }
        return nil
    }
    
    // MARK: - Table View Delegate
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        let entry = indexPath.section == 0
//            ? currentAssignmentLogs[indexPath.row]
//            : allActivityLogs[indexPath.row]
//        
//        // Navigate to detail view
//        showLogDetail(for: entry)
//    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let entry = indexPath.section == 0
            ? currentAssignmentLogs[indexPath.row]
            : allActivityLogs[indexPath.row]
        
        showLogDetail(for: entry)
    }
    func showLogDetail(for entry: JournalEntry) {
        guard entry.type == .written else {
            let alert = UIAlertController(title: "Audio", message: "Playback coming soon.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        performSegue(withIdentifier: "showImageDetail", sender: entry)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageDetail",
           let imageVC = segue.destination as? JournalImageViewController,
           let entry = sender as? JournalEntry {
            imageVC.journalEntry = entry   
        }
    }

}
