//
//  ActivityTableViewController.swift
//  patientSide
//
//  Created by Rishika Mittal on 27/01/26.
//

import UIKit

class ActivityTableViewController: UITableViewController {
    let sectionTitles = ["Today", "Logs"]

    var sectionData: [[Activity]] = [
        [
            Activity(title: "Journaling", dateText: "Wed, Nov 20 at 02:00 PM", subtitle: "Want to write something? I am here...", iconName: "book", completed: false),
            Activity(title: "Art", dateText: "Wed, Nov 20 at 08:00 PM", subtitle: "How was your day?", iconName: "paintpalette", completed: false),
            Activity(title: "Breathing Exercises", dateText: "Wed, Nov 20 at 07:00 AM", subtitle: "Just relax your mind...", iconName: "wind", completed: true)
        ],
        [
            Activity(title: "Journaling", dateText: "Total: 15", subtitle: "", iconName: "book", completed: false),
            Activity(title: "Art", dateText: "Total: 5", subtitle: "", iconName: "paintpalette", completed: false)
        ]
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 180
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sectionData[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "today", for: indexPath) as! TodayTableViewCell
        let activity = sectionData[indexPath.section][indexPath.row]
//        cell.selectionStyle = .none
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = .clear

        cell.configure(with: activity)
        return cell
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView()
//        headerView.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .systemGray

        let subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel

        if section == 0 {
            let todayActivities = sectionData[0]
            let completed = todayActivities.filter { $0.completed }.count
            let pending = todayActivities.count - completed

            titleLabel.text = "Today"
            subtitleLabel.text = "\(pending) pending · \(completed) completed"
        } else {
            titleLabel.text = "Logs"
            subtitleLabel.text = ""
        }

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: -16),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -8),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -6)
        ])

        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 20
    }


    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.numberOfLines = 0
            header.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            header.textLabel?.textColor = .secondaryLabel
            
            header.textLabel?.lineBreakMode = .byWordWrapping
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
