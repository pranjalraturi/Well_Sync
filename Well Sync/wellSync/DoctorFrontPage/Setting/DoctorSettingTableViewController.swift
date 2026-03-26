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
            Task {
                do {
                    try await SupabaseManager.shared.signOut()
                    SessionManager.shared.clearSession()
                    
                    await MainActor.run {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "login")
                        
                        let nav = UINavigationController(rootViewController: loginVC)
                        nav.isNavigationBarHidden = true
                        
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                            sceneDelegate.window?.rootViewController = nav
                            sceneDelegate.window?.makeKeyAndVisible()
                        }
                    }
                    
                } catch {
                    print("Logout failed: \(error)")
                }
            }
        }
    }
}
