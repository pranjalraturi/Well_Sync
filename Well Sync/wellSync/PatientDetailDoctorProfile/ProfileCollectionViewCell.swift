////
////  ProfileCollectionViewCell.swift
////  wellSync
////
////  Created by GEU on 02/02/26.
////
//
//import UIKit
//protocol ProfileCellDelegate: AnyObject {
//    func calendarButtonTapped(from view: UIView)
//}
//class ProfileCollectionViewCell: UICollectionViewCell {
//   
//    weak var delegate: ProfileCellDelegate?
//    
//    @IBOutlet weak var profileImageView: UIImageView!
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var AgeNumberLabel: UILabel!
//    @IBOutlet weak var disorderLabel: UILabel!
//    @IBOutlet weak var calendarButton: UIButton!
//    @IBOutlet weak var genderLabel: UILabel!
//    
//    
//  
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//    
////    func configureCell(with patient: Patient){
////        if let urlStr = patient.imageURL, let url=URL(string: urlStr) {
////            URLSession.shared.dataTask(with: url) { (data, _, _) in
////                guard let data = data, let image = UIImage(data: data) else { return }
////                DispatchQueue.main.async {
////                    self.profileImageView.image = image
////                }
////            }.resume()
////        }
////        nameLabel.text = patient.name
////        AgeLabel.text = "Age: "
////        let age = Calendar.current.dateComponents([.year], from: patient.dob, to: Date())
////        AgeNumberLabel.text = "\(age.year ?? 0)"
////        disorderLabel.text = patient.condition
////        guard let nextDate = patient.nextSessionDate else { return }
////            let formatter = DateFormatter()
////            formatter.dateFormat = "MMM dd"
////            let dateString = formatter.string(from: nextDate)
////            calendarButton.setTitle("   \(dateString)", for: .normal)
////            calendarButton.tintColor = .systemGray
////        }else{
////            calendarButton.setTitle("", for: .normal)
////        }
////    }
//    func configureCell(with patient: Patient){
//        
//        profileImageView.image = UIImage(systemName: "person.circle")
//        if let imageString = patient.imageURL, !imageString.isEmpty {
//            
//            let currentTag = UUID().uuidString
//            self.profileImageView.accessibilityIdentifier = currentTag
//            
//            var finalURL: URL?
//            
//            // Case 1: already full URL
//            if imageString.starts(with: "http") {
//                finalURL = URL(string: imageString)
//            }
//            // Case 2: Supabase path
//            else {
//                do {
//                    finalURL = try AccessSupabase.shared.getPublicImageURL(path: imageString)
//                } catch {
//                    print("Image URL error:", error)
//                }
//            }
//            
//            if let url = finalURL {
//                URLSession.shared.dataTask(with: url) { data, _, _ in
//                    guard let data = data,
//                          let image = UIImage(data: data) else { return }
//                    
//                    DispatchQueue.main.async {
//                        if self.profileImageView.accessibilityIdentifier == currentTag {
//                            self.profileImageView.image = image
//                        }
//                    }
//                }.resume()
//            }
//        }
//        
//        nameLabel.text = patient.name
//        if let gender = patient.gender, !gender.isEmpty, gender.lowercased() != "Not Specified" {
//                genderLabel.text = gender
//                genderLabel.isHidden = false
//            } else {
//                genderLabel.text = ""
//                genderLabel.isHidden = true
//            }
//        
//        let age = Calendar.current.dateComponents([.year], from: patient.dob, to: Date())
//        AgeNumberLabel.text = "\(age.year ?? 0)"
//        
//        disorderLabel.text = patient.condition
//        guard let nextDate = patient.nextSessionDate else {
//            calendarButton.setTitle("  Schedule", for: .normal)
//            calendarButton.backgroundColor = .systemBlue.withAlphaComponent(0.12)
//            calendarButton.setTitleColor(.systemBlue, for: .normal)
//            return
//        }
//            
//        if Calendar.current.isDateInToday(nextDate) {
//                calendarButton.setTitle("  Schedule", for: .normal)
//            calendarButton.backgroundColor = .systemBlue.withAlphaComponent(0.12)
//                calendarButton.setTitleColor(.systemBlue, for: .normal)
//                calendarButton.tintColor = .systemBlue
//            } else {
//                let formatter = DateFormatter()
//                formatter.dateFormat = "MMM dd"
//                let dateString = formatter.string(from: nextDate)
//                
//                calendarButton.setTitle("   \(dateString)", for: .normal)
//                calendarButton.backgroundColor = .systemGray5
//                calendarButton.setTitleColor(.secondaryLabel, for: .normal)
//                calendarButton.tintColor = .secondaryLabel
//            }
////        }else{
////            calendarButton.setTitle("", for: .normal)
////        }
//    }
//    @IBAction func calenderButtonPressed(_ sender: UIButton) {
//        delegate?.calendarButtonTapped(from: sender as UIView)
//    }
//}


//
//  ProfileCollectionViewCell.swift
//  wellSync
//

import UIKit

protocol ProfileCellDelegate: AnyObject {
    func calendarButtonTapped(from view: UIView)
}

class ProfileCollectionViewCell: UICollectionViewCell {
   
    weak var delegate: ProfileCellDelegate?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var AgeNumberLabel: UILabel!
    @IBOutlet weak var disorderLabel: UILabel!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var genderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // ✅ Now accepts appointments array — no more nextSessionDate
    func configureCell(with patient: Patient, appointments: [Appointment]) {
        
        // MARK: - Profile Image
        profileImageView.image = UIImage(systemName: "person.circle")
        
        if let imageString = patient.imageURL, !imageString.isEmpty {
            
            let currentTag = UUID().uuidString
            self.profileImageView.accessibilityIdentifier = currentTag
            
            var finalURL: URL?
            
            if imageString.starts(with: "http") {
                finalURL = URL(string: imageString)
            } else {
                do {
                    finalURL = try AccessSupabase.shared.getPublicImageURL(path: imageString)
                } catch {
                    print("Image URL error:", error)
                }
            }
            
            if let url = finalURL {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data,
                          let image = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        if self.profileImageView.accessibilityIdentifier == currentTag {
                            self.profileImageView.image = image
                        }
                    }
                }.resume()
            }
        }
        
        // MARK: - Basic Info
        nameLabel.text = patient.name
        
        let age = Calendar.current.dateComponents([.year], from: patient.dob, to: Date())
        AgeNumberLabel.text = "\(age.year ?? 0)"
        
        disorderLabel.text = patient.condition
        
        if let gender = patient.gender,
           !gender.isEmpty,
           gender.lowercased() != "not specified" {
            genderLabel.text = gender
            genderLabel.isHidden = false
        } else {
            genderLabel.text = ""
            genderLabel.isHidden = true
        }
        
        // MARK: - Calendar Button (Appointment Based)
        
        // ✅ Find the next FUTURE scheduled appointment only
        let now = Date()
        let nextAppointment = appointments
            .filter { $0.status == .scheduled && $0.scheduledAt > now }
            .sorted { $0.scheduledAt < $1.scheduledAt }
            .first

        if let upcoming = nextAppointment {
            
            // ✅ FIX: If the upcoming appointment is TODAY → show "Schedule" in blue
            if Calendar.current.isDateInToday(upcoming.scheduledAt) {
                calendarButton.setTitle("  Schedule", for: .normal)
                calendarButton.backgroundColor = .systemBlue.withAlphaComponent(0.12)
                calendarButton.setTitleColor(.systemBlue, for: .normal)
                calendarButton.tintColor = .systemBlue
                
            } else {
                // Future date (not today) → show the date in gray
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd"
                let dateString = formatter.string(from: upcoming.scheduledAt)
                
                calendarButton.setTitle("   \(dateString)", for: .normal)
                calendarButton.backgroundColor = .systemGray5
                calendarButton.setTitleColor(.secondaryLabel, for: .normal)
                calendarButton.tintColor = .secondaryLabel
            }
            
        } else {
            // No future appointment at all → show Schedule in blue
            calendarButton.setTitle("  Schedule", for: .normal)
            calendarButton.backgroundColor = .systemBlue.withAlphaComponent(0.12)
            calendarButton.setTitleColor(.systemBlue, for: .normal)
            calendarButton.tintColor = .systemBlue
        }
    }
    
    @IBAction func calenderButtonPressed(_ sender: UIButton) {
        delegate?.calendarButtonTapped(from: sender as UIView)
    }
}
