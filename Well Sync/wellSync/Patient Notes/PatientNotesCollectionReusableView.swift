//
//  PatientNotesCollectionReusableView.swift
//  wellSync
//
//  Created by Rishika Mittal on 13/03/26.
//

import UIKit

class PatientNotesCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var header: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(with title: String) {
        header.text = title
    }
}
