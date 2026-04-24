//
//  StreakCompactCell.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 24/04/26.
//

import UIKit

class StreakCompactCell: UICollectionViewCell {

    // MARK: – IBOutlets
    @IBOutlet weak var fireIconContainer: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    // MARK: – Gradient layer
    private let gradientLayer: CAGradientLayer = {
        let gl = CAGradientLayer()
        // #71C9CE gradient — lighter top-left to darker bottom-right
        gl.colors = [
            UIColor(red: 143/255, green: 218/255, blue: 222/255, alpha: 1).cgColor,  // lighter
            UIColor(red: 113/255, green: 201/255, blue: 206/255, alpha: 1).cgColor,  // #71C9CE
            UIColor(red: 80/255,  green: 170/255, blue: 180/255, alpha: 1).cgColor   // darker
        ]
        gl.locations = [0.0, 0.5, 1.0]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint   = CGPoint(x: 1, y: 1)
        gl.cornerRadius = 20
        return gl
    }()

    // MARK: – Init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: – Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
        fireIconContainer?.layer.cornerRadius = (fireIconContainer?.bounds.height ?? 40) / 2
    }

    // MARK: – Setup

    private func setupUI() {
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: – Configure

    func configure(streak: Int) {
        countLabel?.text = "\(streak) \(streak == 1 ? "Day!" : "Days!")"

        if streak >= 7 {
            subtitleLabel?.text = "Amazing streak"
        } else if streak >= 3 {
            subtitleLabel?.text = "Great streak"
        } else if streak >= 1 {
            subtitleLabel?.text = "Keep going!"
        } else {
            subtitleLabel?.text = "Start today"
        }
    }
}
