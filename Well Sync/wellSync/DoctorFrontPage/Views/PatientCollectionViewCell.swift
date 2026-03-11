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
    var color:UIColor = .systemYellow
    
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
        contentView.layer.cornerRadius = 20
        contentView.layer.borderWidth = 1.5
        
        contentView.layer.masksToBounds = true
    }


    func configureCell(with: Patient){
        switch with.mood{
        case 4:
            color = .systemGreen
        case 3:
            color = .systemOrange
        case 2:
            color = .systemRed
        default:
            color = .systemYellow
        }
        profileImage.image = UIImage(named: with.imageURL ?? "")
        nameLabel.text = with.name
        conditionLabel.text = with.condition
        sessionLabel.text = "7  Sessions"
        time.text = with.nextSessionDate.formatted(date: .omitted, time: .shortened)
        
        let date = with.previousSessionDate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.dateStyle = .medium

        let dateString = formatter.string(from: date!)
        lastDate.text = dateString
//        lastDate.text = "\(with.previousSessionDate?.formatted(date: .numeric, time: .omitted))"
        contentView.layer.borderColor = color.cgColor
    }
}
