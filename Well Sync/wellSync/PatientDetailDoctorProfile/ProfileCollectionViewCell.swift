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
    
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(with patient: Patient){
//        if let urlString = patient.imageURL,
//           let url = URL(string: urlString),
//           let data = try? Data(contentsOf: url) {
//            
//            profileImageView.image = UIImage(data: data)
//        }
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
    }
    @IBAction func calenderButtonPressed(_ sender: UIButton) {
        delegate?.calendarButtonTapped(from: sender as UIView)
    }
}
