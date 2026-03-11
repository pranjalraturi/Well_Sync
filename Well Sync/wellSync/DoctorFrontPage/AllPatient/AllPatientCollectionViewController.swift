//
//  AllPatientCollectionViewController.swift
//  wellSync
//
//  Created by Pranjal on 11/03/26.
//
import UIKit

class AllPatientCollectionViewController: UICollectionViewController {

    var patients: [Patient] = []
    var filteredPatients: [Patient] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        loadPatients()

        filteredPatients = patients

        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }

    // MARK: Register Cells

    func setupCollectionView() {

        collectionView.register(
            UINib(nibName: "PatientCell", bundle: nil),
            forCellWithReuseIdentifier: "PatientCell"
        )

        collectionView.register(
            UINib(nibName: "TopSecCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "TopCell"
        )
    }

    // MARK: Data

    func makeDate(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy"
        return formatter.date(from: string) ?? Date()
    }

    func loadPatients() {

        patients = [

            Patient(
                patientID: UUID(),
                docID: UUID(),
                name: "Vidit Saran Agarwal",
                email: "vidit@email.com",
                password: "123",
                contact: "9876543210",
                dob: makeDate("10 Jan 00"),
                nextSessionDate: makeDate("11 Nov 25"),
                imageURL: "profile",
                address: "Delhi",
                condition: "BPD",
                sessionStatus: true,
                mood: 7,
                previousSessionDate: makeDate("11 Nov 25")
            ),

            Patient(
                patientID: UUID(),
                docID: UUID(),
                name: "Arjun Mehta",
                email: "arjun@email.com",
                password: "123",
                contact: "9876543211",
                dob: makeDate("05 Mar 01"),
                nextSessionDate: makeDate("15 Nov 25"),
                imageURL: "profile",
                address: "Mumbai",
                condition: "Anxiety",
                sessionStatus: false,
                mood: 5,
                previousSessionDate: makeDate("15 Nov 25")
            )
        ]
    }

    // MARK: Sections

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {

        if section == 0 { return 1 }

        return filteredPatients.count
    }

    // MARK: Cells

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TopCell",
                for: indexPath
            ) as! TopSecCollectionViewCell

            cell.onSearchTextChanged = { [weak self] text in
                self?.filterPatients(searchText: text)
            }

            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PatientCell",
            for: indexPath
        ) as! PatientCell

        let patient = filteredPatients[indexPath.row]
        cell.configureCell(with: patient)

        return cell
    }

    // MARK: Search

    func filterPatients(searchText: String) {

        if searchText.isEmpty {
            filteredPatients = patients
        } else {

            filteredPatients = patients.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }

        collectionView.reloadSections(IndexSet(integer: 1))
    }

    // MARK: Layout

    func createLayout() -> UICollectionViewCompositionalLayout {

        UICollectionViewCompositionalLayout { sectionIndex, _ in
            return self.sectionLayout(for: sectionIndex)
        }
    }

    func sectionLayout(for section: Int) -> NSCollectionLayoutSection {

        switch section {

        case 0:
            return topSectionLayout()

        case 1:
            return patientSectionLayout()

        default:
            return patientSectionLayout()
        }
    }

    func topSectionLayout() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(120)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        return NSCollectionLayoutSection(group: group)
    }

    func patientSectionLayout() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(120)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        group.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 16,
            bottom: 0,
            trailing: 16
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10

        return section
    }
}
