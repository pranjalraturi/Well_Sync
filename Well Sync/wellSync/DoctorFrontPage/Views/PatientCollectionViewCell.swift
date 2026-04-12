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
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    
    var onAction: ((doctorAction) -> Void)?
    
    private var leftAction: doctorAction?
    private var rightAction: doctorAction?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTag(conditionLabel)
        setupTag(sessionLabel)
        
        setupButton(leftButton, bgColor: .systemBlue, textColor: .systemBlue)
        setupButton(rightButton, bgColor: .systemBlue, textColor: .systemBlue)
    }
    
    private func setupTag(_ label: UILabel) {
        label.layer.cornerRadius = 11
        label.layer.masksToBounds = true
        label.textAlignment = .center
        contentView.layer.cornerRadius = 20
        
        contentView.layer.masksToBounds = true
    }
    
    private func setupButton(_ button: UIButton, bgColor: UIColor, textColor: UIColor) {
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        
        button.backgroundColor = bgColor.withAlphaComponent(0.12)
        button.setTitleColor(textColor, for: .normal)
    }
    
//    private func configureButtons(_ patient: Patient){
//        if patient.sessionStatus == .done{
//
//        }
//    }
    
    private func configureButtons(status: Appointment.status) {


        switch status {

        case .completed:
            leftButton.setTitle("Next Session Date", for: .normal)
            leftAction = .nextSession
            leftButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            leftButton.setTitleColor(.systemOrange, for: .normal)
            rightButton.setTitle("Add Session Note", for: .normal)
            rightAction = .addNote
            rightButton.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.25)
            rightButton.setTitleColor(.systemIndigo.withAlphaComponent(0.75), for: .normal)

        case .scheduled:
            leftButton.setTitle("Reschedule", for: .normal)
            leftAction = .reschedule
            leftButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            leftButton.setTitleColor(.systemOrange, for: .normal)
            rightButton.setTitle("Mark as Done", for: .normal)
            rightAction = .markDone
            rightButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            rightButton.setTitleColor(.systemRed, for: .normal)
            rightButton.isEnabled = true

        case .missed:
            leftButton.setTitle("Reschedule", for: .normal)
            leftAction = .reschedule
            leftButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            leftButton.setTitleColor(.systemOrange, for: .normal)
            rightButton.setTitle("Notify", for: .normal)
            rightAction = .notify
            rightButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            rightButton.setTitleColor(.systemBlue, for: .normal)
            rightButton.isEnabled = true
        }
    }
    
    func configureCell(with: Patient, status: Appointment.status) {
        
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
        configureButtons(status: status)
    }
    
    @IBAction func leftButtonTapped(_ sender: UIButton) {
        if let action = leftAction {
            onAction?(action)
        }
    }

    @IBAction func rightButtonTapped(_ sender: UIButton) {
        if let action = rightAction {
            onAction?(action)
        }
    }

}

