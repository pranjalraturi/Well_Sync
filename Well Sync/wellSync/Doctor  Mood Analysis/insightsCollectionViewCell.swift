//
//  insightsCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 04/02/26.
//

import UIKit

class insightsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var insight: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        insight.numberOfLines = 0
        insight.lineBreakMode = .byWordWrapping
    }

    func configur(with text: String) {
        insight.text = text
    }
}
