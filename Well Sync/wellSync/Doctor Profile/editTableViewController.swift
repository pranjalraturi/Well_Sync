//
//  editTableViewController.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 19/04/26.
//

import UIKit

class editTableViewController: UITableViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var experience: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var addPhoto: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        }
        return 5
    }
    
    @IBAction func saveChanges(_ sender: UIBarButtonItem) {
        //        guard let doctor = SessionManager.shared.currentDoctor,
        //                      let docID = doctor.docID else {
        //                    print("No doctor found")
        //                    return
        //                }
        //
        //                let updatedName = name.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        //                let updatedAddress = address.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        //                let updatedEmail = email.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        //        let expValue = Int(experience.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        //
        //                guard !updatedName.isEmpty,
        //                      !updatedAddress.isEmpty,
        //                      !updatedEmail.isEmpty,
        //                      let updatedExperience = expValue else {
        //                    print("Invalid input")
        //                    return
        //                }
        //
        //        Task {
        //            do {
        //                var updatedDoc = doctor   // copy
        //
        //                updatedDoc.name = updatedName
        //                updatedDoc.address = updatedAddress
        //                updatedDoc.email = updatedEmail
        //                updatedDoc.experience = updatedExperience
        //
        //                let result = try await AccessSupabase.shared.updateDoctor(updatedDoc)
        //
        //                await MainActor.run {
        //                    SessionManager.shared.currentDoctor = result
        //                    self.dismiss(animated: true)
        //                }
        //
        //            } catch {
        //                print("Doctor update failed:", error)
        //            }
        //        }
        dismiss(animated: true)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
