//
//  ReportCollectionViewCell.swift
//  wellSync
//
//  Created by GEU on 09/03/26.
//

import UIKit

class ReportCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.secondarySystemBackground
    }
    func configureCell(){
        imageView.image = UIImage(systemName: "folder.fill")
        titleLabel.text = "Report"
        dateLabel.text = "09-03-2026"
    }
}
