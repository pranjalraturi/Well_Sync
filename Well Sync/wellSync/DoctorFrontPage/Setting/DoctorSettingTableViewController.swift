//
//  PateintSettingTableViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 11/02/26.
//

import UIKit

class DoctorSettingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 3 && indexPath.row == 1 {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "login")
            
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                
                // 🔥 Disable animation (important)
//                UIView.transition(with: sceneDelegate.window!,
//                                  duration: 0.3,
//                                  options: .transitionCrossDissolve,
//                                  animations: {
                    sceneDelegate.window?.rootViewController = loginVC
//                })
            }
        }
    }
}
