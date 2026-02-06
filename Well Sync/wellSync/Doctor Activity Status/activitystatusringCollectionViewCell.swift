//
//  activitystatusringCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 07/02/26.
//

import UIKit

class activitystatusringCollectionViewCell: UICollectionViewCell {
    
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
