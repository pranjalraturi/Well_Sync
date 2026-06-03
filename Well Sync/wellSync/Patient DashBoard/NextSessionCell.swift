//
//  NextSessionCell.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 24/03/26.
//


import UIKit

class NextSessionCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        style(self)
        setupAppearance()
    }

    private func setupAppearance() {
        layer.cornerRadius = 16
        layer.masksToBounds = true

        titleLabel.text          = "Next Session"
        doctorLabel.textColor    = .label
        dateTimeLabel.textColor  = .secondaryLabel
    }
    
    func configure(doctorName: String, nextAppointment: Appointment?) {
        statusLabel.textColor = UIColor(red: 113/255, green: 201/255, blue: 206/255, alpha: 1)
        statusLabel.backgroundColor = UIColor(red: 113/255, green: 201/255, blue: 206/255, alpha: 0.2)

        guard let appointment = nextAppointment else {
            doctorLabel.text = doctorName
            dateTimeLabel.text = "Contact your doctor to schedule next session"
            statusLabel.text = "No session"
            statusLabel.isHidden = false
            return
        }

        doctorLabel.text = doctorName
        let sessionDate = appointment.scheduledAt
        
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        df.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        dateTimeLabel.text = df.string(from: sessionDate)
        statusLabel.isHidden = false

        let today = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(sessionDate, inSameDayAs: today) {
            if appointment.status == .completed {
                statusLabel.text = "Done"
            } else if appointment.status == .missed || (appointment.status == .scheduled && sessionDate < today) {
                statusLabel.text = "Missed"
            } else {
                statusLabel.text = "Today"
            }
        } else {
            let days = calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: today),
                to: calendar.startOfDay(for: sessionDate)
            ).day ?? 0

            if days == 1 {
                statusLabel.text = "1 day left"
            } else if days > 1 {
                statusLabel.text = "\(days) days left"
            } else {
                statusLabel.text = "Missed"
            }
        }
    }
}
