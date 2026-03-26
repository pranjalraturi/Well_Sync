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
            logout()
        }
    }
    func logout() {
        Task {
            do {
                // Step 1: logout from Supabase
                try await SupabaseManager.shared.signOut()
                
                // Step 2: clear local session
                SessionManager.shared.clearSession()
                
                // Step 3: UI update on main thread
                await MainActor.run {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginVC = storyboard.instantiateViewController(withIdentifier: "login")
                    
                    let nav = UINavigationController(rootViewController: loginVC)
                    nav.isNavigationBarHidden = true
                    
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        
                        window.rootViewController = nav
                        window.makeKeyAndVisible()
                    }
                }
                
            } catch {
                print("Logout failed: \(error)")
            }
        }
    }
}
