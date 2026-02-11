//
//  PatientDetailCollectionViewController.swift
//  wellSync
//
//  Created by Rishika Mittal on 06/02/26.
//

import UIKit

class PatientDetailCollectionViewController: UICollectionViewController {

    @IBOutlet weak var PatientProfileCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        let Layout = generateLayout()
        PatientProfileCollectionView.setCollectionViewLayout(Layout, animated: true)
        
        PatientProfileCollectionView.delegate = self
        PatientProfileCollectionView.dataSource = self
    }
    
    func registerCells(){
        PatientProfileCollectionView.register(UINib(nibName: "ProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProfileCollectionViewCell")
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        return 6
     }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let profilecell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewCell", for: indexPath) as! ProfileCollectionViewCell
            profilecell.configureCell()
            return profilecell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as! DetailCollectionViewCell
        cell.configure(index: indexPath.row)
        return cell
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
}


extension PatientDetailCollectionViewController{
    
    func generateLayout() -> UICollectionViewLayout {

           let layout = UICollectionViewCompositionalLayout { [weak self]
               sectionIndex, environment -> NSCollectionLayoutSection in

               guard let self = self else {
                   return self!.generateSectionForDetailCells()
               }

               switch sectionIndex {
               case 0:
                   return self.generateSectionForProfile()
               default:
                   return self.generateSectionForDetailCells()
               }
           }
            
            
        layout.register(RoundedBackgroundCollectionReusableView.self,
                        forDecorationViewOfKind: "background")

           return layout
       }
    func cardStyle(cell:UICollectionViewCell){
        cell.backgroundColor = .systemBackground
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.08
        cell.layer.shadowRadius = 10
        cell.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    func generateSectionForProfile() -> NSCollectionLayoutSection{
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(160))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(160))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        return section
    }
    
//    func generateSectionForDetailCells() -> NSCollectionLayoutSection{
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
//        return section
//    }
    
    func generateSectionForDetailCells() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(70)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(70)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )

        let section = NSCollectionLayoutSection(group: group)

        section.contentInsets = NSDirectionalEdgeInsets(
            top: 4,
            leading: 28,
            bottom: 4,
            trailing: 28
        )

        let backgroundItem = NSCollectionLayoutDecorationItem.background(
            elementKind: "background"
        )

        backgroundItem.contentInsets = NSDirectionalEdgeInsets(
            top: -8,
            leading: 16,
            bottom: -8,
            trailing: 16
        )

        
        section.decorationItems = [backgroundItem]
        return section
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            performSegue(withIdentifier: "Summarised", sender: nil)
        case 2:
            performSegue(withIdentifier: "mood", sender: nil)
        case 3:
            performSegue(withIdentifier: "activity", sender: nil)
        case 4:
            performSegue(withIdentifier: "vitals", sender: nil)
        default:
            break
        }
    }
    
}
