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


    func configureCell(with: Patient) {
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
//        profileImage.image = UIImage(named: URL(string: with.imageURL ?? ""))
        if let urlString = with.imageURL,
           let url = URL(string: urlString),
           let data = try? Data(contentsOf: url) {
            
            profileImage.image = UIImage(data: data)
        }
        
//        profileImage.image = nil
//        profileImage.image = UIImage(named: "user")
//        if let urlString = with.imageURL, let url = URL(string: urlString) {
//            // Capture the URL string to validate in the completion handler to avoid wrong images on reused cells
//            let expectedURL = url.absoluteString
//            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//                guard let self = self else { return }
//                guard error == nil, let data = data, let image = UIImage(data: data) else { return }
//                DispatchQueue.main.async {
//                    // Only set the image if the cell is still configured for the same URL
//                    if with.imageURL == expectedURL {
//                        self.profileImage.image = image
//                    }
//                }
//            }.resume()
//        }
        
        nameLabel.text = with.name
        conditionLabel.text = with.condition
        sessionLabel.text = "7 Sessions"
        let sessionDate = with.nextSessionDate
        print(sessionDate)
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.timeZone = TimeZone(secondsFromGMT: 0)   // keeps time as 10:00:00
        timeFormatter.dateFormat = "HH:mm"

        time.text = timeFormatter.string(from: sessionDate)
        

//        formatter.dateFormat = "HH:mm:ss"
        
        
        print("---->>>>",sessionDate.formatted(date: .omitted, time: .standard))
        print("---->>>>",time.text)
        
        var formatter = DateFormatter()
        guard let date = with.previousSessionDate else { return}
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.dateStyle = .medium

        let dateString = formatter.string(from: date)
        lastDate.text = dateString
//        lastDate.text = "\(with.previousSessionDate?.formatted(date: .numeric, time: .omitted))"
        contentView.layer.borderColor = color.cgColor
    }
}

