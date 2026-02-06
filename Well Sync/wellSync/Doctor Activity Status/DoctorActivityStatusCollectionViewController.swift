//
//  DoctorActivityStatusCollectionViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 06/02/26.
//

import UIKit

private let reuseIdentifier = "Cell"

class DoctorActivityStatusCollectionViewController: UICollectionViewController {

    var activities = ["Art","Journal","Breathing","Walking"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UINib(nibName: "UploadCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "uploadCell")
        self.collectionView!.register(UINib(nibName: "GraphCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "graphCell")
        
        self.collectionView!.collectionViewLayout = generateLayout()
        // Do any additional setup after loading the view.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0{
            return 1
        }
        return activities.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityStateCell", for: indexPath) as! activitystatusringCollectionViewCell
            cell.configure(progress: 3.0/7.0)
            return cell
        }
        
        if activities[indexPath.row] == "Art" || activities[indexPath.row] == "Journal" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "uploadCell", for: indexPath) as! UploadCollectionViewCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "graphCell", for: indexPath) as! GraphCollectionViewCell
        return cell
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            if sectionIndex == 0 {
                return self.generateLayoutForS1()
            } else {
                return self.generateLayoutForS2()
            }
        }
        return layout
    }

    
    func generateLayoutForS1() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(160)
            )

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 16, leading: 16, bottom: 8, trailing: 16)

            return section
    }
    
    func generateLayoutForS2() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(120)
            )

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 8, leading: 16, bottom: 16, trailing: 16)
            section.interGroupSpacing = 10

            return section
    }
}
