//
//  SummaryActivityTableViewCell.swift
//  wellSync
//
//  Created by Rishika Mittal on 07/02/26.
//

import UIKit

class SummaryActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true

        // Initialization code
    }

    func configure(with activities: [Activity]) {
        
        // Clear old arranged subviews (important for reuse!)
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for activity in activities {
            
            let container = UIView()
            
            let titleLabel = UILabel()
            titleLabel.text = activity.title
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            
            let percentLabel = UILabel()
            percentLabel.text = "\(Int(activity.completed * 100))%"
//            percentLabel.textColor = .red
            percentLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)

            
//            let progress = UIProgressView(progressViewStyle: .default)
//            progress.progress = activity.completed
//            progress.progressTintColor = .cyan
//            progress.trackTintColor = .systemGray5
//            progress.layer.cornerRadius = 6
//            progress.clipsToBounds = true
            
            let progress = UIProgressView(progressViewStyle: .default)
            progress.progress = activity.completed
            progress.progressTintColor = .systemTeal
            progress.trackTintColor = UIColor.systemGray5
            
            percentLabel.textColor = progress.progressTintColor

            // Make it thicker
            progress.transform = progress.transform.scaledBy(x: 1, y: 1.5)

            // Rounded look
            progress.layer.cornerRadius = 2
            progress.clipsToBounds = true

            
            let topRow = UIStackView(arrangedSubviews: [titleLabel, percentLabel])
            topRow.axis = .horizontal
            topRow.distribution = .equalSpacing
            
            let vertical = UIStackView(arrangedSubviews: [topRow, progress])
            vertical.axis = .vertical
//            vertical.spacing = 8
            
            vertical.spacing = 8
            stackView.spacing = 16
//            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
//            percentLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            
            container.addSubview(vertical)
            vertical.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                vertical.topAnchor.constraint(equalTo: container.topAnchor),
                vertical.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                vertical.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                vertical.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
            stackView.addArrangedSubview(container)
        }
    }


}
