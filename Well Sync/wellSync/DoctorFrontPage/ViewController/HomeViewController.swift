//
//  homeViewController.swift
//  DoctorProfile
//
//  Created by Pranjal on 04/02/26.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
//    private var selectedPatient: Patient?
    
        private let viewModel = HomeViewModel()
        override func viewDidLoad() {
            super.viewDidLoad()

            setupCollectionView()
            viewModel.loadPatients()
            
            collectionView.setCollectionViewLayout(createLayout(), animated: false)
        }
    
        private func setupCollectionView() {
            collectionView.delegate = self
            collectionView.dataSource = self

            collectionView.register(
                UINib(nibName: "PatientCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "PatientCell"
            )
            collectionView.register(
                UINib(nibName: "TopSectionCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "TopCell"
            )
            collectionView.register(
                UINib(nibName: "SectionHeaderView", bundle: nil),
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "header"
            )

        }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "PatientDetail" {
//            if let destination = segue.destination as? PatientDetailViewController {
//                destination.patient = selectedPatient
//            }
//        }
//    }
}




extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        if section == 0 {
            return 2   // only one top stats card
        } else {
            return viewModel.numberOfPatients()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header",
            for: indexPath
        ) as! SectionHeaderView

        if indexPath.section == 1 {
            header.configure(withTitle: "Upcoming")
        } else if indexPath.section == 2 {
            header.configure(withTitle: "Missed")
        }
        else if indexPath.section == 3 {
        header.configure(withTitle: "Done")
    }

        return header
    }

    func headerItem() -> NSCollectionLayoutBoundarySupplementaryItem {

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        return header
    }

    func createLayout() -> UICollectionViewCompositionalLayout {

        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            return self.sectionLayout(for: sectionIndex)
        }
    }
    func sectionLayout(for section: Int) -> NSCollectionLayoutSection {

        let header = headerItem()

        switch section {
        case 0:
            let sectionLayout = topSectionLayout()
            return sectionLayout

        case 1:
            let sectionLayout = patientSectionLayout()
            sectionLayout.boundarySupplementaryItems = [header]
            return sectionLayout
            
        case 2:
            let sectionLayout = patientSectionLayout()
            sectionLayout.boundarySupplementaryItems = [header]
            return sectionLayout
            
        case 3:
            let sectionLayout = patientSectionLayout()
            sectionLayout.boundarySupplementaryItems = [header]
            return sectionLayout

        default:
            return patientSectionLayout()
        }
    }
    
    func topSectionLayout() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5) ,
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(120)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        return section
    }
    func patientSectionLayout() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150)
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

    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            let cell: TopSectionCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCell", for: indexPath) as! TopSectionCollectionViewCell
            
            
            if indexPath.row == 0 {
                    cell.configure(title: "Active Patients", subtitle: "24")
                } else {
                    cell.configure(title: "Today's Session", subtitle: "5")
                }
            
            cell.contentView.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.15
            cell.layer.shadowOffset = CGSize(width: 0, height: 6)
            cell.layer.shadowRadius = 10
            cell.layer.masksToBounds = false

            return cell
        }
        else if indexPath.section == 1 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "PatientCell",
                    for: indexPath
                ) as! PatientCollectionViewCell
                cell.contentView.layer.masksToBounds = true
                cell.layer.cornerRadius = 16
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOpacity = 0.15
                cell.layer.shadowOffset = CGSize(width: 0, height: 6)
                cell.layer.shadowRadius = 10
                cell.layer.masksToBounds = false
                let patient = viewModel.patient(at: indexPath.row)
                cell.configureCell(with: patient)

                return cell
            }
        else if indexPath.section == 2 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "PatientCell",
                    for: indexPath
                ) as! PatientCollectionViewCell
                cell.contentView.layer.masksToBounds = true
                cell.layer.cornerRadius = 16
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOpacity = 0.15
                cell.layer.shadowOffset = CGSize(width: 0, height: 6)
                cell.layer.shadowRadius = 10
                cell.layer.masksToBounds = false
                let patient = viewModel.patient(at: indexPath.row)
                cell.configureCell(with: patient)

                return cell
            }
        else{
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PatientCell",
                for: indexPath
            ) as! PatientCollectionViewCell
            cell.contentView.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.15
            cell.layer.shadowOffset = CGSize(width: 0, height: 6)
            cell.layer.shadowRadius = 10
            cell.layer.masksToBounds = false
            let patient = viewModel.patient(at: indexPath.row)
            cell.configureCell(with: patient)
            return cell
        }

        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Only proceed for patient sections (exclude top stats section 0)
        guard indexPath.section != 0 else { return }
        let patient = viewModel.patient(at: indexPath.row)
//        selectedPatient = patient
        performSegue(withIdentifier: "PatientDetail", sender: self)
    }
}

