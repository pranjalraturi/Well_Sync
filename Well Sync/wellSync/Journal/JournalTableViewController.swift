//
//  JournalTableViewController.swift
//  wellSync
//
//  Created by Pranjal on 07/02/26.
//

import UIKit

class JournalTableViewController: UITableViewController {
    var thisWeek: [JournalEntry] = []
    var previous: [JournalEntry] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDummyData()
        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 180
    }
    
    func setupDummyData() {
        
        let j1 = JournalEntry(
            title: "Monday, Oct 23",
            subtitle: "9:41 AM • Voice Journal",
            summary: "Feeling significantly better today. Breathing exercises helped calm my nerves.",
            type: .audio,
            journalImage: nil,
            audioFile: "audio1",
            date: Date()
        )
        
        let j2 = JournalEntry(
            title: "Sunday, Oct 22",
            subtitle: "8:30 PM • Written Journal",
            summary: "Had anxiety in evening. Writing helped me relax and process emotions.",
            type: .written,
            journalImage: "journal1",
            audioFile: nil,
            date: Date()
        )
        let j3 = JournalEntry(
            title: "Sunday, Oct 22",
            subtitle: "8:30 PM • Written Journal",
            summary: "Had anxiety in evening. Writing helped me relax and process emotions.",
            type: .written,
            journalImage: "journal1",
            audioFile: nil,
            date: Date()
        )
        
        let old = JournalEntry(
            title: "Oct 10",
            subtitle: "8:30 PM • Written Journal",
            summary: "Mood stable. Sleep improved.",
            type: .written,
            journalImage: "journal2",
            audioFile: nil,
            date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        )
        let old2 = JournalEntry(
            title: "Oct 10",
            subtitle: "8:30 PM • Written Journal",
            summary: "Mood stable. Sleep improved.",
            type: .written,
            journalImage: "journal2",
            audioFile: nil,
            date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        )
        // grouping
        let calendar = Calendar.current
        
        let all = [j1, j2,j3,old, old2]
        
        for journal in all {
            
            if calendar.isDate(journal.date,
                               equalTo: Date(),
                               toGranularity: .weekOfYear) {
                
                thisWeek.append(journal)
            } else {
                previous.append(journal)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {

        return section == 0 ? thisWeek.count : previous.count
    }

    
    override func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalTableCell",
                                                 for: indexPath) as! JournalTableViewCell
        
        let data = indexPath.section == 0
        ? thisWeek[indexPath.row]
        : previous[indexPath.row]
        
        cell.configure(with: data)
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {

        if section == 0 && !thisWeek.isEmpty {
            return "This Week"
        }

        if section == 1 && !previous.isEmpty {
            return "Previous Week"
        }

        return nil
    }

}

