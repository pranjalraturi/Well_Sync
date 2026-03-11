//
//  PatientCollectionViewCell.swift
//  DoctorProfile
//
//  Created by Pranjal on 04/02/26.
//
import UIKit

class PatientCell: UICollectionViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var lastDate: UILabel!

    override func awakeFromNib() {
            super.awakeFromNib()

            setupTag(conditionLabel)
            setupTag(sessionLabel)

            contentView.layer.cornerRadius = 20
            contentView.layer.masksToBounds = true
        }

        private func setupTag(_ label: UILabel) {
            label.layer.cornerRadius = 11
            label.layer.masksToBounds = true
            label.textAlignment = .center
        }

        func configureCell(with patient: Patient) {

            nameLabel.text = patient.name
            conditionLabel.text = patient.condition

            // session status
            if let status = patient.sessionStatus {
                sessionLabel.text = "7  Sessions"//status ? "Active" : "Inactive"
            } else {
                sessionLabel.text = "Unknown"
            }

            // previous session date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yy"

            if let date = patient.previousSessionDate {
                lastDate.text = formatter.string(from: date)
            } else {
                lastDate.text = "-"
            }

            // profile image
            if let image = patient.imageURL {
                profileImage.image = UIImage(named: image)
            } else {
                profileImage.image = UIImage(systemName: "person.circle.fill")
            }
        }
    }
