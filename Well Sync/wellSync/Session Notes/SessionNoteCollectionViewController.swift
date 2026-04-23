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
    var appointment: Appointment?
    var sessions: [SessionNote] = []
    var sizeOfNotes: Int?
//    var sessionNotes: [SessionNote] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = generateLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if self.sessions.isEmpty{
            loadSessionNotes()
        }else{
            collectionView.reloadData()
        }
    }
    func loadSessionNotes() {
        Task {
            guard let patientID = patient?.patientID else { return }

            do {
                let fetched = try await AccessSupabase.shared.fetchSessionNotes(patientID: patientID)
                await MainActor.run {
                    self.sessions = fetched
                    self.sizeOfNotes = self.sessions.count
                    self.collectionView.reloadData()
                }
            } catch {
                print("❌ fetch error:", error)
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sessions.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sessionCell", for: indexPath) as! SessionNoteCollectionViewCell
        cell
            .configur(
                with: sessions[indexPath.row],
                index: (sizeOfNotes ?? 0) - indexPath.row
            )
        return cell
    }

    func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(150.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .flexible(16)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 12)
        section.interGroupSpacing = 16

        return UICollectionViewCompositionalLayout(section: section)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSession", sender: indexPath)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSession",
           let indexPath = sender as? IndexPath,
           let vc = segue.destination as? DetailSessionCollectionViewController {

            vc.session = sessions[indexPath.row]
            vc.title = "Session \(indexPath.row + 1)"
        }

        if let navVC = segue.destination as? UINavigationController,
           let addVC = navVC.topViewController as? AddSessionCollectionViewController {
            addVC.patientID = patient?.patientID
            addVC.appointmentID = appointment?.appointmentId
            addVC.onSessionAdded = { [weak self] in
                self?.loadSessionNotes()
            }
        }
    }
    
}
