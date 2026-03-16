//
//  PateintSettingTableViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 11/02/26.
//

import UIKit

class PateintSettingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
    }
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        if indexPath.section == 2 && indexPath.row == 4{
            performSegue(withIdentifier: "logoutPatients", sender: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logoutPatients"{
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.isTabBarHidden = true
        }
    }
}
