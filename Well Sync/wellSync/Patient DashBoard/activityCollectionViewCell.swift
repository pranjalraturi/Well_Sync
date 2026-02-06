//
//  activityCollectionViewCell.swift
//  Project
//
//  Created by Vidit Agarwal on 27/01/26.
//

import UIKit

class ActivityRingCell: UICollectionViewCell {
    @IBOutlet weak var ringContainer: ActivityRingView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
            super.prepareForReuse()
            ringContainer.reset()
    }

    func configure(progress: CGFloat) {
        layoutIfNeeded()
        ringContainer.setProgress(progress, animated: true)
   }
}
