//
//  SectionHeaderView.swift
//  wellSync
//
//  Created by GEU on 10/03/26.
//

import UIKit

class HeaderView: UICollectionReusableView {
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(title: String){
        self.titleLabel.text = title
    }
}
