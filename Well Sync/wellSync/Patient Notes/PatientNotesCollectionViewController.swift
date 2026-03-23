//
//  PatientNotesCollectionViewController.swift
//  wellSync
//
//  Created by Rishika Mittal on 13/03/26.
//

import UIKit
import Foundation

private let reuseIdentifier = "Cell"

class PatientNotesCollectionViewController: UICollectionViewController {
    
    var onAdd: (() -> Void)?
    var notes: [PatientNote]?
    var patientID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task{
            do{
                notes = try await AccessSupabase.shared.fetchPatientNotes(patientID: patientID!)
            }
            catch{
                print("Error: ",error)
            }
        }
        collectionView.register(
            UINib(nibName: "PatientNotesCollectionReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "pateintNoteHeader"
        )
        self.collectionView.collectionViewLayout = createLayout()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return notes?.count ?? 0
        default:
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "currentNotes", for: indexPath)
            if let button = cell.viewWithTag(2) as? UIButton {
                button.addTarget(self, action: #selector(addNoteTapped), for: .touchUpInside)
                
                // ← bring button to front so nothing blocks it
                button.superview?.bringSubviewToFront(button)
                button.isUserInteractionEnabled = true
            }
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "patientNotesCell", for: indexPath) as! PatientNoteCollectionViewCell
        cell.configure(with: notes![indexPath.row], index: indexPath.row)
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView,
                                     viewForSupplementaryElementOfKind kind: String,
                                     at indexPath: IndexPath) -> UICollectionReusableView {

            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "pateintNoteHeader",
                for: indexPath
            ) as! PatientNotesCollectionReusableView

            if indexPath.section == 0 {
                header.configure(with: "Quick note to remember for your next session")
            } else if indexPath.section == 1 {
                header.configure(with: "Previous Notes")
            }
            return header
    }
    
    func headerItem() -> NSCollectionLayoutBoundarySupplementaryItem {

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )

        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
    func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            return self.sectionLayout(for: sectionIndex)
        }
    }
    func sectionLayout(for section: Int) -> NSCollectionLayoutSection {

        let header = headerItem()
        let layout = noteSectionLayout()
        layout.boundarySupplementaryItems = [header]
        return layout
    }
    func noteSectionLayout() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(200)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8

        return section
    }
    
    @objc func addNoteTapped() {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)),
              let textField = cell.viewWithTag(1) as? UITextField else {
            print("cell or textField not found")
            return
        }

        guard let text = textField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("text is empty")
            return
        }

        let newNote = PatientNote(
            noteId: UUID(),
            patientId: patientID!,
            date: Date(),
            note: text
        )

        Task{
            do{
                try await AccessSupabase.shared.savePatientNote(newNote)
            }
            catch{
                print("Error: ",error)
            }
        }
//        notes.insert(newNote, at: 0)
        textField.text = ""
        textField.resignFirstResponder()
        collectionView.reloadData()
    }
}
