//
//  SectionHeaderView 2.swift
//  sample
//
//  Created by Pranjal on 02/04/26.
//


import UIKit

class SectionHeaderViewAp: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(withTitle title: String) {
        titleLabel.text = title
    }
}
