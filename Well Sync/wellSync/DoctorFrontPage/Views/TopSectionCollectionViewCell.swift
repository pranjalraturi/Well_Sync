//
//  TopSectionCollectionViewCell.swift
//  wellSync
//
//  Created by Pranjal on 05/02/26.
//

import UIKit

class TopSectionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        contentView.backgroundColor = .secondarySystemBackground
        
    }
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }


}
