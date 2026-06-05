//
//  SessionNoteCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 10/03/26.
//

import UIKit

class SessionNoteCollectionViewCell: UICollectionViewCell {
    @IBOutlet var sessionNumberLabel: UILabel!
    @IBOutlet var sessionSummaryLabel: UILabel!
    @IBOutlet var sessionDateLabel: UILabel!
    
    func configur(with session: SessionNote?,index: Int){
        layer.cornerRadius = 25
        sessionNumberLabel.layer.cornerRadius = 10
//        layer.masksToBounds = false
        sessionNumberLabel.text = "Session \(index)"
        sessionDateLabel.text = session?.date.formatted(date: .numeric, time: .omitted) ?? ""
        
        if let session = session {
            if let notes = session.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                sessionSummaryLabel.text = notes
            } else {
                let imageCount = session.images?.count ?? 0
                let voiceCount = session.voice?.count ?? 0
                
                if imageCount > 0 && voiceCount > 0 {
                    sessionSummaryLabel.text = "\(imageCount) image(s), \(voiceCount) recording(s)"
                } else if imageCount > 0 {
                    sessionSummaryLabel.text = "\(imageCount) image(s)"
                } else if voiceCount > 0 {
                    sessionSummaryLabel.text = "\(voiceCount) recording(s)"
                } else {
                    sessionSummaryLabel.text = "No notes"
                }
            }
        } else {
            sessionSummaryLabel.text = "No notes"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        style(self)
    }
}
