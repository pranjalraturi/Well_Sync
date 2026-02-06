//
//  PatientCollectionViewCell.swift
//  DoctorProfile
//
//  Created by Pranjal on 04/02/26.
//

import UIKit

class PatientCollectionViewCell: UICollectionViewCell {
   
 
    @IBOutlet weak var sessionNumber: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var conditionLabel: UILabel!
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(){
        profileImage.image = UIImage(named: "profile")
        nameLabel.text = "Vidit"
        conditionLabel.text = "BPD"
        sessionNumber.text = "7 sessions"
    }
}
