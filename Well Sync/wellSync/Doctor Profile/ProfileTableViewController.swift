//
//  ProfileTableViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 14/02/26.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    @IBOutlet var doctorNameLabel: UILabel!
    @IBOutlet var doctorCityLabel: UILabel!
    @IBOutlet var doctorAgeLabel: UILabel!
    @IBOutlet var doctorExperienceLabel: UILabel!
    @IBOutlet var doctorMailLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        filldata();
    }
    func filldata(){
        if SessionManager.shared.currentDoctor == nil{
            return
        }
        var doctor = SessionManager.shared.currentDoctor
        doctorNameLabel.text = doctor!.name
        doctorCityLabel.text = doctor!.address
        
        doctorAgeLabel.text = String(Calendar.current.dateComponents([.year], from: doctor!.dob, to: Date()).year!)
        doctorExperienceLabel.text = String(doctor!.experience)
        doctorMailLabel.text = doctor!.email
    }
}
