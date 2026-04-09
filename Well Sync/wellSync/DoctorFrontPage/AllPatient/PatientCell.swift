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

        profileImage.image = UIImage(systemName: "person.circle.fill")

        // session
        sessionLabel.text = patient.sessionStatus != nil ? "7 Sessions" : "Unknown"

        // date
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy"

        if let date = patient.previousSessionDate {
            lastDate.text = formatter.string(from: date)
        } else {
            lastDate.text = "-"
        }

        // ✅ FETCH IMAGE FROM SUPABASE BUCKET
        if let path = patient.imageURL {
            Task {
                do {
                    let image = try await AccessSupabase.shared.downloadImage(path: path)
                    DispatchQueue.main.async {
                        self.profileImage.image = image
                    }
                } catch {
                    print("Image fetch failed:", error)
                }
            }
        }
    }
}
