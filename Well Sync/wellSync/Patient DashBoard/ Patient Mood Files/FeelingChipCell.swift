//
//  FeelingChipCell.swift
//  wellSync
//
//  Created by Rishika Mittal on 09/02/26.
//

import UIKit

class FeelingChipCell: UICollectionViewCell {
    
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        
        contentView.backgroundColor = .systemGray5
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .label
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    func setSelected(_ selected: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.contentView.backgroundColor = selected ? .systemGray2 : .systemGray5
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .systemGray5
        titleLabel.textColor = .label
    }
}
