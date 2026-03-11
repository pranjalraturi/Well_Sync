//
//  CaseHistoryViewController.swift
//  wellSync
//
//  Created by GEU on 09/03/26.
//

import UIKit

class CaseHistoryViewController: UIViewController {
    @IBOutlet weak var CaseHistoryCollectionView: UICollectionView!
    
    var caseHistory: CaseHistory!
    var timeline: [Timeline] = []
    var reports: [Report] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        caseHistory = historyMockData()
        timeline = caseHistory.timeline ?? []
        reports = caseHistory.report ?? []
       registerCells()
        let layout = generateLayout()
        CaseHistoryCollectionView.setCollectionViewLayout(layout, animated: true)
        
        CaseHistoryCollectionView.dataSource = self
    }
    func registerCells(){
        CaseHistoryCollectionView.register(UINib(nibName: "ReportCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ReportCell")
        CaseHistoryCollectionView.register(UINib(nibName: "TimelineCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TimelineCell")
        CaseHistoryCollectionView.register(UINib(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: "header", withReuseIdentifier: "Heading")
    }
  

}

extension CaseHistoryViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return reports.count
        }else if section == 1{
            return timeline.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReportCell", for: indexPath)
            guard let reportCell = cell as? ReportCollectionViewCell else {
                return cell
            }
            let report = reports[indexPath.item]
            reportCell.configureCell(report: report)
            return cell
        }else if indexPath.section == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineCell", for: indexPath)
            guard let TimelineCell = cell as? TimelineCollectionViewCell else {
                return cell
            }
            let timeline = timeline[indexPath.item]
            TimelineCell.configureCell(timeline: timeline)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineCell", for: indexPath)
        guard let TimelineCell = cell as? TimelineCollectionViewCell else {
            return cell
        }
        let timeline = timeline[indexPath.item]
        TimelineCell.configureCell(timeline: timeline)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var Heading: HeaderView!
        
        if kind == "header"{
            Heading = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Heading", for: indexPath) as? HeaderView
            if indexPath.section == 0{
                Heading.configure(title: "Medical Report")
            }else if indexPath.section == 1{
                Heading.configure(title: "Treatment Timeline")
            }
        }
        return Heading
    }
    func generateLayout() -> UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .topLeading)
            if sectionIndex == 0{
                let section = self.generateSectionForReport()
                section.boundarySupplementaryItems = [header]
                return section
            }else if sectionIndex == 1{
                let section = self.generateSectionForTimeline()
                section.boundarySupplementaryItems = [header]
                return section
            }
            return self.generateSectionForTimeline()
        }
        return layout
    }
        
        func generateSectionForReport() -> NSCollectionLayoutSection{
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 12
            )
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .absolute(120.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
    
      func generateSectionForTimeline() -> NSCollectionLayoutSection{
          let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
          let item = NSCollectionLayoutItem(layoutSize: itemSize)
          item.contentInsets = NSDirectionalEdgeInsets(
                  top: 6,
                  leading: 6,
                  bottom: 6,
                  trailing: 6
              )
          let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
          let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
          group.interItemSpacing = .fixed(5)
          let section = NSCollectionLayoutSection(group: group)
          section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16)
  //        section.orthogonalScrollingBehavior = .groupPaging
          section.interGroupSpacing = 12
          return section
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
   
}
