//
//  FeelingCollectionViewCell.swift
//  wellSync
//
//  Created by Rishika Mittal on 08/02/26.
//

import UIKit

class FeelingCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel = UILabel()
//    IBOutlet weak var titleLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // Make contentView friendly to auto-sizing
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.systemGray5
        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true

        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            // ensure contentView has a size relative to its cell's contentView
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),

            // pin contentView to cell (helps self-sizing)
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    
    func configure(title: String) {
        titleLabel.text = title
    }
    
}
