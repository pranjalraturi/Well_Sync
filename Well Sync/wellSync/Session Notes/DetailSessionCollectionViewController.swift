//
//  DetailSessionCollectionViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 11/03/26.
//

import UIKit
import AVFoundation

class DetailSessionCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.collectionViewLayout = generateLayout()
    }


    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recording", for: indexPath)
    
        // Configure the cell
    
        return cell
    }
    func generateLayout() -> UICollectionViewLayout {
        //createthe itemSize
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(150))
        
        //certe the item
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //create teh siz eof the group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(200.0))
        //create the group
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .flexible(10)
        
        //create the section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
}

