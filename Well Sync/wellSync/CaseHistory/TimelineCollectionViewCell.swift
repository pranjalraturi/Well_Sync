//
//  TimelineCollectionViewCell.swift
//  wellSync
//
//  Created by GEU on 09/03/26.
//

import UIKit

class TimelineCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
    }
    
    func configureCell(){
        dateLabel.text = "18 Nov"
        titleLabel.text = "Initial Phase"
        descriptionLabel.text = "Doing great work. We will release the next do some more test."
    }

}
