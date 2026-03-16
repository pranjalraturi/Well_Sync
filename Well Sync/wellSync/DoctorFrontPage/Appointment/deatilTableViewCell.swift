//
//  deatilTableViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 15/03/26.
//

import UIKit

class deatilTableViewCell: UITableViewCell {

    @IBOutlet var patientImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var conditionLabel: UILabel!
    @IBOutlet var numberOfSession: UILabel!
    @IBOutlet var sessionTime: UILabel!
    var filteredPatients:[Patient] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configureCell(patient: Patient, session: SessionNote) {

        nameLabel.text = patient.name
        conditionLabel.text = patient.condition
        numberOfSession.text = session.title

        patientImage.image = UIImage(named: "photo")

        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"

        sessionTime.text = formatter.string(from: session.date)
    }
    
}
