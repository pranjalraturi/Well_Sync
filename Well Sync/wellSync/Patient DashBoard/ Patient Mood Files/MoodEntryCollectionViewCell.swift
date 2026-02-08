//
//  MoodEntryCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 01/02/26.
//

import UIKit

class MoodEntryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var moodView: [UIView]!

    override func awakeFromNib() {
        super.awakeFromNib()

        for view in moodView {
            view.layer.cornerRadius = 8
            view.isUserInteractionEnabled = true
        }
        for (index, view) in moodView.enumerated() {
            view.layer.cornerRadius = 8
            view.isUserInteractionEnabled = true
            view.tag = index   
        }
    }
    
    func configureTap(target: Any, action: Selector) {
        for view in moodView {
            let tap = UITapGestureRecognizer(target: target, action: action)
            view.addGestureRecognizer(tap)
        }
    }
    
    func configure(selectedIndex: Int) {
        for (index, view) in moodView.enumerated() {

            if index == selectedIndex {
                view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } else {
                view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
        }
    }


    override func prepareForReuse() {
        super.prepareForReuse()
        for view in moodView {
            view.transform = .identity
        }
    }
    
}
