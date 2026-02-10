//
//  FeelingCollectionViewCell.swift
//  wellSync
//
//  Created by Rishika Mittal on 08/02/26.
//

import UIKit


class FeelingCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
        
    private var feelings: [String] = []
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Card styling
        cardView.layer.cornerRadius = 16
        
        
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        cardView.layer.shadowRadius = 12
        
        cardView.layer.masksToBounds = true
        
        // Inner collection
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.estimatedItemSize = CGSize(width: 80, height: 36)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 5
//            layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
        
//        collectionView.backgroundColor = .clear
        
        collectionView.register(
            FeelingChipCell.self,
            forCellWithReuseIdentifier: "FeelingChipCell"
        )
    }
        
    func configure(feelings: [String]) {
        self.feelings = feelings
        collectionView.reloadData()
    }
}
extension FeelingCollectionViewCell {
        
    func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
        return feelings.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "FeelingChipCell",
            for: indexPath
        ) as! FeelingChipCell
            
        cell.configure(title: feelings[indexPath.item])
        return cell
    }
}

//
////    private let titleLabel = UILabel()
//    @IBOutlet weak var titleLabel: UILabel!
//    
//        override func awakeFromNib() {
//            super.awakeFromNib()
//
//            contentView.backgroundColor = .systemGray5
//            contentView.layer.cornerRadius = 18
//            contentView.clipsToBounds = true
//
//            titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
//            titleLabel.textAlignment = .center
//        }
//
//        func configure(title: String) {
//            titleLabel.text = title
//        }
//    }

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupUI()
//    }
//
//    private func setupUI() {
//        // Make contentView friendly to auto-sizing
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.backgroundColor = UIColor.systemGray5
//        contentView.layer.cornerRadius = 18
//        contentView.clipsToBounds = true
//
//        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        titleLabel.textAlignment = .center
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.numberOfLines = 1
//        titleLabel.lineBreakMode = .byTruncatingTail
//
//        contentView.addSubview(titleLabel)
//
//        NSLayoutConstraint.activate([
//            // ensure contentView has a size relative to its cell's contentView
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
//
//            // pin contentView to cell (helps self-sizing)
//            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            contentView.topAnchor.constraint(equalTo: topAnchor),
//            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//
//        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
//        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
//    }
//
//    
//    func configure(title: String) {
//        titleLabel.text = title
//    }
//    
//}
