//
//  ProfileCollectionViewCell.swift
//  wellSync
//
//  Created by GEU on 02/02/26.
//

import UIKit
protocol ProfileCellDelegate: AnyObject {
    func calendarButtonTapped(from view: UIView)
}
class ProfileCollectionViewCell: UICollectionViewCell {
   
    weak var delegate: ProfileCellDelegate?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var AgeLabel: UILabel!
    @IBOutlet weak var AgeNumberLabel: UILabel!
    @IBOutlet weak var disorderLabel: UILabel!
    @IBOutlet weak var calendarButton: UIButton!
    
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(with patient: Patient){
        if let urlStr = patient.imageURL, let url=URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { (data, _, _) in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                }
            }.resume()
        }
        nameLabel.text = patient.name
        AgeLabel.text = "Age: "
        let age = Calendar.current.dateComponents([.year], from: patient.dob, to: Date())
        AgeNumberLabel.text = "\(age.year ?? 0)"
        disorderLabel.text = patient.condition
        guard let nextDate = patient.nextSessionDate else {
            calendarButton.setTitle("Schedule", for: .normal)
            calendarButton.backgroundColor = .systemBlue
            return
        }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd"
            let dateString = formatter.string(from: nextDate)
            calendarButton.setTitle("   \(dateString)", for: .normal)
        if Calendar.current.isDateInToday(nextDate) {
                calendarButton.backgroundColor = .systemBlue
                calendarButton.setTitleColor(.white, for: .normal)
                calendarButton.tintColor = .white
            } else {
                calendarButton.backgroundColor = .systemGray5
                calendarButton.setTitleColor(.secondaryLabel, for: .normal)
                calendarButton.tintColor = .secondaryLabel
            }
//        }else{
//            calendarButton.setTitle("", for: .normal)
//        }
    }
    @IBAction func calenderButtonPressed(_ sender: UIButton) {
        delegate?.calendarButtonTapped(from: sender as UIView)
    }
}
