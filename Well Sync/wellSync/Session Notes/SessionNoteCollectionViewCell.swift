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
    @IBOutlet var sessionTitleLabel: UILabel!
    func configur(with session: SessionNote?,indexPath: IndexPath){
        layer.cornerRadius = 25
//        layer.masksToBounds = false
        sessionNumberLabel.text = "Session \(indexPath.row + 1)"
        sessionDateLabel.text = session?.date.formatted(date: .numeric, time: .omitted) ?? ""
        sessionTitleLabel.text = /*session.title*/ "Person is suffring from BPD"
        sessionSummaryLabel.text = "DATA NOT AVAILABLE"
    }
}
