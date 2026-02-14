//
//  ProfileCollectionViewCell.swift
//  wellSync
//
//  Created by GEU on 02/02/26.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var AgeLabel: UILabel!
    @IBOutlet weak var AgeNumberLabel: UILabel!
    @IBOutlet weak var disorderLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(with patient: PatientModel ){
        profileImageView.image = UIImage(named: patient.imageName)
        nameLabel.text = patient.name
        AgeLabel.text = "Age: "
        AgeNumberLabel.text = String(patient.age)
        disorderLabel.text = patient.condition
    }

}
