//
//  MoodLogCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 30/01/26.
//

import UIKit

class MoodLogCollectionViewCell: UICollectionViewCell {
    @IBOutlet var moodView: [UIView]!

    override func awakeFromNib() {
            super.awakeFromNib()

            for view in moodView {
                view.layer.cornerRadius = 8
                view.isUserInteractionEnabled = true
            }
        }

        func configureTap(target: Any, action: Selector) {
            for view in moodView {
                let tap = UITapGestureRecognizer(target: target, action: action)
                view.addGestureRecognizer(tap)
            }
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            for view in moodView {
                view.transform = .identity
            }
        }
}
