//
//  PatientCollectionViewCell.swift
//  DoctorProfile
//
//  Created by Pranjal on 04/02/26.
//

import UIKit

class PatientCollectionViewCell: UICollectionViewCell {
   
 
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet weak var sessionLabel: UILabel!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var conditionLabel: UILabel!
    @IBOutlet weak var lastDate: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        ontentView.backgroundColor = .secondarySystemBackground
        setupTag(conditionLabel)
        setupTag(sessionLabel)
    }

    private func setupTag(_ label: UILabel) {
        label.layer.cornerRadius = 11
        label.layer.masksToBounds = true
        label.textAlignment = .center
    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        conditionLabel.layer.cornerRadius = conditionLabel.frame.height / 2
//        sessionLabel.layer.cornerRadius = sessionLabel.frame.height / 2
//    }

    func configureCell(with: PatientModel){
        profileImage.image = UIImage(named: with.imageName)
        nameLabel.text = with.name
        conditionLabel.text = with.condition
        sessionLabel.text = "\(with.sessionCount)  Sessions"
        time.text = with.sessionTime
        lastDate.text = with.lastSessionDate
    }
}
