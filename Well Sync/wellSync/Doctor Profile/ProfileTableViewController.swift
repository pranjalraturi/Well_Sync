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
        if currentDoctor == nil{
            return
        }
        doctorNameLabel.text = currentDoctor!.name
        doctorCityLabel.text = currentDoctor!.address
        
        doctorAgeLabel.text = String(Calendar.current.dateComponents([.year], from: currentDoctor!.dob, to: Date()).year!)
        doctorExperienceLabel.text = String(currentDoctor!.experience)
        doctorMailLabel.text = currentDoctor!.email
    }
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 3 && indexPath.row == 1{
//            performSegue(withIdentifier: "logout", sender: nil)
//        }
//    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "logout"{
//            self.navigationController?.isNavigationBarHidden = true
//            self.tabBarController?.isTabBarHidden = true
//        }
//    }
}
