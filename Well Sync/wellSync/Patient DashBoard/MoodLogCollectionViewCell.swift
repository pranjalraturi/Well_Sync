//
//  MoodLogCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 30/01/26.
//

import UIKit

class MoodLogCollectionViewCell: UICollectionViewCell {
    @IBOutlet var moodViews: [UIImageView]!

    override func awakeFromNib() {
            super.awakeFromNib()
        }

        func configureTap(target: Any, action: Selector) {
            for view in moodViews {
                view.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: target, action: action)
                view.addGestureRecognizer(tap)
            }
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            for view in moodViews {
                view.transform = CGAffineTransform.identity
            }
        }
}
