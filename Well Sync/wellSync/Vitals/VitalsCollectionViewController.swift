//
//  VitalsCollectionViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 07/02/26.
//

import UIKit

private let reuseIdentifier = "Cell"

class VitalsCollectionViewController: UICollectionViewController {

    let vit: [(title: String, color: UIColor)] = [("",.white),
        ("Sleep", .systemIndigo),
        ("Steps", .systemOrange)
    ]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UINib(nibName: "VitalsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "vitalCell")
        self.collectionView!.register(UINib(nibName: "VitalsBarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "vitalBarCell")
        collectionView.collectionViewLayout = generateLayout()
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0{
            return 1
        }
        return 3
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "segment", for: indexPath)
                return cell
            }
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filter", for: indexPath)
//            
//            return cell
        }
        if indexPath.section == 1 && indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "vitalCell", for: indexPath)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "vitalBarCell", for: indexPath) as! VitalsBarCollectionViewCell
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = vit[indexPath.row].title
            label.textColor = vit[indexPath.row].color
        }
        cell.configure(index: indexPath.row)
        return cell
    }
    func generateLayout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            
            let height: NSCollectionLayoutDimension
            
            switch sectionIndex {
            case 0:
                height = .estimated(50)
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: height
                )
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                group.interItemSpacing = .fixed(12)
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                
                return section
            default:
                height = .absolute(280)
            }
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: height
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(8)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
            
            
            return section
        }
    }
}
