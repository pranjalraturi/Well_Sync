//
//  TodayTableViewCell.swift
//  patientSide
//
//  Created by Rishika Mittal on 27/01/26.
//

import UIKit

class TodayTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    func configure(with activity: Activity) {
//        titleLabel.text = activity.title
//        dateLabel.text = activity.dateText
//        subtitleLabel.text = activity.subtitle
//        iconImageView.image = UIImage(systemName: activity.iconName)
    }
}


