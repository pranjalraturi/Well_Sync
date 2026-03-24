//
//  TableViewController.swift
//  wellSync
//
//  Created by Rishika Mittal on 07/02/26.
//


import UIKit

class SummarisedReportTableViewController: UITableViewController {
    
    var patient: Patient?

    let sections = ["Mood","Activity","Patient notes","Session Notes", "Journal Summary"]
    var todayItems: [TodayActivityItem] = []
    let activities :[Activity] = []

    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 120
        tableView.sectionHeaderTopPadding = 8
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 250
        tableView.dataSource = self
        
        guard let patientID = patient?.patientID else {
            print("SummaryViewController: no patient passed")
            return
        }
        Task{
            do{
                todayItems = try await buildTodayItems(for: patientID)
                print("5-->", patientID)
            }catch {
                print("Activity in Summarised report error \(error)")
            }
        }
        tableView.reloadData()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "sMoodCell", for: indexPath)
            return cell
            
        }
        if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "sActivityCell", for: indexPath
                ) as! SummaryActivityTableViewCell

                cell.selectedBackgroundView                  = UIView()
                cell.selectedBackgroundView?.backgroundColor = .clear

                if let patientID = patient?.patientID {
                    Task{
                        do{
                            await cell.configure(for: patientID)
                        }
                    }
                }
                return cell
            }
        let cell = tableView.dequeueReusableCell(withIdentifier: "sPatientNote", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textColor = .label
        
        label.text = sections[section]
        
        headerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8)
        ])
        
        return headerView
    }

    override func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            return 300
        }
        
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
}

