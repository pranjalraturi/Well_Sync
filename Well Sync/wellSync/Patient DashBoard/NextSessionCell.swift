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

    // Countdown pill — created in code, no storyboard needed
//    private let countdownPill = PillLabel()

    // MARK: – Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }

    // MARK: – Appearance

    private func setupAppearance() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        layer.masksToBounds = true

        titleLabel.text          = "Next Session"

        doctorLabel.textColor    = .label

        dateTimeLabel.textColor  = .secondaryLabel
    }
    
    func configure(doctorName: String, sessionDate: Date?) {
        doctorLabel.text = doctorName
        guard let sessionDate else {
            dateTimeLabel.text = "Not Scheduled"
            statusLabel.isHidden = true
            return
        }

        // Date · Time
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMM d"
        let datePart = df.string(from: sessionDate)
        df.dateFormat = "h:mm a"
        let timePart = df.string(from: sessionDate)
        dateTimeLabel.text = "\(datePart)  ·  \(timePart)"

        // Countdown pill
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: sessionDate)
        ).day ?? 0

        if days == 0{
            statusLabel.text         = "Today"
            statusLabel.textColor    = .systemGreen
            statusLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        }else if days == 1{
            statusLabel.text = "Tomorrow"
            statusLabel.textColor    = .systemYellow
            statusLabel.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.1)
        }else if days<0{
            statusLabel.text         = "Missed"
            statusLabel.textColor    = .systemRed
            statusLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        }else {
            statusLabel.text = "In \(days) days"
        }
    }

//    private func resetPillToOrange() {
//        countdownPill.textColor       = UIColor(red: 0.94, green: 0.47, blue: 0, alpha: 1)
//        countdownPill.backgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.88, alpha: 1)
//    }
}
