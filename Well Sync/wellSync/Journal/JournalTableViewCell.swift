//
//  JournalTableViewCell.swift
//  wellSync
//
//  Created by Pranjal on 07/02/26.
//

import UIKit

class JournalTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardView.isUserInteractionEnabled = false
//        contentView.heightAnchor.constraint(equalToConstant: 130).isActive = true
    }

    func configure(with data: JournalEntry) {

        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        summaryLabel.text = data.summary
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOffset = .zero
        // change icon based on type
        switch data.type {

        case .written:
            iconImage.image = UIImage(systemName: "book.fill")

        case .audio:
            iconImage.image = UIImage(systemName: "play.circle.fill")
        }
    }
}
