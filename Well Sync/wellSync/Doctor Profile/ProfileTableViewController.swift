//
//  ProfileTableViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 14/02/26.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == 1{
            performSegue(withIdentifier: "logout", sender: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logout"{
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.isTabBarHidden = true
        }
    }
}
