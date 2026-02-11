//
//  RoundedBackgroundCollectionReusableView.swift
//  wellSync
//
//  Created by Rishika Mittal on 06/02/26.
//

import UIKit

class RoundedBackgroundCollectionReusableView: UICollectionReusableView {
    override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }

        private func setup() {
            backgroundColor = .secondarySystemBackground
            layer.cornerRadius = 20
            layer.masksToBounds = true
            layer.cornerRadius = 20
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.10
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 2
            layer.masksToBounds = false
        }
    
}
