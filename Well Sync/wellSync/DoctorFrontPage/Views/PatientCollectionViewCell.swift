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
    
    @IBOutlet var sessionStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTag(conditionLabel)
        setupTag(sessionLabel)
        setupLabel(sessionStatusLabel)
    }
    
    private func setupTag(_ label: UILabel) {
        label.layer.cornerRadius = 11
        label.layer.masksToBounds = true
        label.textAlignment = .center
        contentView.layer.cornerRadius = 20
        
        contentView.layer.masksToBounds = true
    }
    
    private func setupLabel(_ label: UILabel) {
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        label.textColor = UIColor.systemGreen
        label.layer.masksToBounds = true
    }
    
    
    func configureCell(with: Patient) {
        
        // Default image
        profileImage.image = UIImage(systemName: "person.circle")
        
        // ✅ IMAGE LOADING
        if let imageString = with.imageURL, !imageString.isEmpty {
            
            let currentTag = UUID().uuidString
            self.profileImage.accessibilityIdentifier = currentTag
            
            var finalURL: URL?
            
            // Case 1: already full URL
            if imageString.starts(with: "http") {
                finalURL = URL(string: imageString)
            }
            // Case 2: Supabase path
            else {
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
                        // Prevent wrong image due to reuse
                        if self.profileImage.accessibilityIdentifier == currentTag {
                            self.profileImage.image = image
                        }
                    }
                }.resume()
            }
        }
        
        // UI DATA
        nameLabel.text = with.name
        conditionLabel.text = with.condition
        sessionLabel.text = "7 Sessions"
        
        // Time
        if let sessionDate = with.nextSessionDate {
            let timeFormatter = DateFormatter()
            timeFormatter.locale = Locale(identifier: "en_US_POSIX")
            timeFormatter.dateFormat = "HH:mm"
            time.text = timeFormatter.string(from: sessionDate)
        }
        
        // Last session date
        if let date = with.previousSessionDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateString = formatter.string(from: date)
            lastDate.text = "Last session: \(dateString)"
        }
    }

}

