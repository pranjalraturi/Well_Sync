//
//  NextSessionCell.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 24/03/26.
//


import UIKit

class NextSessionCell: UICollectionViewCell {

    // MARK: – Outlets (connect from storyboard)
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    // MARK: – Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        style(self)
        setupAppearance()
    }

    // MARK: – Appearance

    private func setupAppearance() {
        layer.cornerRadius = 16
        layer.masksToBounds = true

        titleLabel.text          = "Next Session"

        doctorLabel.textColor    = .label

        dateTimeLabel.textColor  = .secondaryLabel
    }
    
    func configure(doctorName: String, sessionDate: Date?, isMissedToday: Bool) {
        statusLabel.textColor = UIColor(red: 113/255, green: 201/255, blue: 206/255, alpha: 1)
        statusLabel.backgroundColor = UIColor(red: 113/255, green: 201/255, blue: 206/255, alpha: 0.2)

        if sessionDate == nil {
            doctorLabel.text = ""
            dateTimeLabel.text = ""
            statusLabel.text = "No session"
            statusLabel.isHidden = false
            return
        }

        doctorLabel.text = doctorName

        if let sessionDate = sessionDate {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US")
            df.dateFormat = "MMMM d, yyyy 'at' h:mm a"
            dateTimeLabel.text = df.string(from: sessionDate)
            statusLabel.isHidden = false

            if isMissedToday {
                statusLabel.text = "Missed"
            } else {
                let today = Date()
                let calendar = Calendar.current
                
                let days = calendar.dateComponents(
                    [.day],
                    from: calendar.startOfDay(for: today),
                    to: calendar.startOfDay(for: sessionDate)
                ).day ?? 0

                if days == 0 {
                    statusLabel.text = "Today"
                } else if days == 1 {
                    statusLabel.text = "1 day left"
                } else if days > 1 {
                    statusLabel.text = "\(days) days left"
                } else {
                    statusLabel.text = "Missed"
                }
            }
        } else {
            dateTimeLabel.text = ""
            statusLabel.text = "No session"
            statusLabel.isHidden = false
        }
    }
}
