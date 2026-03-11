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
    
    func configureCell(with patient: Patient){
        profileImageView.image = UIImage(named: patient.imageURL ?? "")
        nameLabel.text = patient.name
        AgeLabel.text = "Age: "
        let age = Calendar.current.dateComponents([.year], from: patient.dob, to: Date())
        AgeNumberLabel.text = "\(age.year ?? 0)"
        disorderLabel.text = patient.condition
    }

}
