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
    private var selectedIndexes: Set<Int> = []
    var onSelectionChanged: (([String]) -> Void)?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Card styling
        cardView.layer.cornerRadius = 20
        
//        
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.08
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)
//        cardView.layer.shadowRadius = 12
        
        cardView.layer.masksToBounds = true
        
        // Inner collection
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
        
        collectionView.register(
            FeelingChipCell.self,
            forCellWithReuseIdentifier: "FeelingChipCell"
        )
    }
  
    func configure(feelings: [String]) {
            self.feelings       = feelings
            self.selectedIndexes = []
            onSelectionChanged?([])
            collectionView.reloadData()
        }

}
extension FeelingCollectionViewCell {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        feelings.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "FeelingChipCell",
            for: indexPath
        ) as! FeelingChipCell
        
        cell.configure(title: feelings[indexPath.item])

        cell.setSelected(selectedIndexes.contains(indexPath.item))

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        if selectedIndexes.contains(indexPath.item) {
            selectedIndexes.remove(indexPath.item)
        } else {
            selectedIndexes.insert(indexPath.item)
        }

        if let cell = collectionView.cellForItem(at: indexPath) as? FeelingChipCell {
            cell.setSelected(selectedIndexes.contains(indexPath.item))
        }

        let selected = selectedIndexes.sorted().map { feelings[$0] }
        onSelectionChanged?(selected)
    }
    
}
