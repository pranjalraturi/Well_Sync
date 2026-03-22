//
//  SessionNoteCollectionViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 10/03/26.
//

import UIKit
import Foundation
class SessionNoteCollectionViewController: UICollectionViewController {

    var patient: Patient?
    
    var sessions:[SessionNote]?
    override func viewDidLoad() {
        super.viewDidLoad()
        Task{
            sessions = try await AccessSupabase.shared
                .fetchSessionNotes(
                    patientID: patient?.patientID ?? UUID(
                        uuidString:"00000000-0000-0000-0000-000000000000"
                    )!
                )
            sessions = sessions?.filter { $0.patientId == patient?.patientID }
            self.collectionView.reloadData()
        }
        self.collectionView.collectionViewLayout = generateLayout()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sessions?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sessionCell", for: indexPath) as! SessionNoteCollectionViewCell
            
            
        cell.configur(with: sessions?[indexPath.row], indexPath: indexPath)
        return cell
    }
    func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(200.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .flexible(16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 12)
        section.interGroupSpacing = 16
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSession", sender: indexPath)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath {
            let vc = segue.destination
            vc.title = "Session \(indexPath.row + 1)"
        }
    }
}
