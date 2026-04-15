//
//  MoodAnalysisCollectionViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 04/02/26.
//

import UIKit

class GraphCollectionViewController: UICollectionViewController {

    var activity: Activity?
    var logs: [ActivityLog] = []
    var patient: Patient?
    var assigned: AssignedActivity?

    private var selectedSegmentIndex: Int = 0          // 0 = weekly, 1 = monthly
    private var selectedDate: Date = Date()
    private var calendarHeight: CGFloat = 300


    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .systemBackground
        title = activity?.name

        collectionView.register(
            UINib(nibName: "CalendarCellAct", bundle: nil),
            forCellWithReuseIdentifier: "calenderA"
        )
        collectionView.register(
            UINib(nibName: "BreathingChartCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "breathingGraphCell"
        )
        collectionView.register(
            UINib(nibName: "SectionHeaderViewAp", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeaderViewAp"
        )
        collectionView.register(
            UINib(nibName: "insightCollectionViewCellGr", bundle: nil),
            forCellWithReuseIdentifier: "insightCellGr"
        )

        collectionView.collectionViewLayout = generateLayout()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int { 4 }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int { 1 }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {

        case 0:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "segment", for: indexPath)

        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "calenderA", for: indexPath
            ) as! CalendarCellAct

            style(cell)

            cell.onHeightChange = { [weak self] newHeight in
                guard let self else { return }
                self.calendarHeight = newHeight + 16
                UIView.animate(withDuration: 0.25) {
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    self.collectionView.layoutIfNeeded()
                }
            }

            cell.onDateSelected = { [weak self] date in
                guard let self else { return }
                self.selectedDate = date
                self.collectionView.reloadSections(IndexSet(integer: 2))
            }

            cell.onPageChange = { [weak self] pageStartDate in
                guard let self else { return }
                self.selectedDate = pageStartDate
                self.collectionView.reloadSections(IndexSet(integer: 2))
            }

            cell.configure(segment: selectedSegmentIndex)
            return cell

        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "breathingGraphCell", for: indexPath
            ) as! BreathingChartCollectionViewCell

            style(cell)

            cell.configure(
                with: logs,
                mode: selectedSegmentIndex,
                referenceDate: selectedDate
            )

            return cell

        case 3:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "insightCellGr",
                for: indexPath
            ) as! insightCollectionViewCellGr

            style(cell)


            cell.configure(
                with: logs,
                frequency: assigned!.frequency        
            )

            return cell

        default:
            return UICollectionViewCell()
        }
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "SectionHeaderViewAp",
            for: indexPath
        ) as! SectionHeaderViewAp

        switch indexPath.section {
        case 2: header.configure(withTitle: "Graph")
        case 3: header.configure(withTitle: "Engagement Insights")
        default: header.configure(withTitle: "")
        }

        return header
    }


    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex

        if let calCell = collectionView.cellForItem(
            at: IndexPath(item: 0, section: 1)
        ) as? CalendarCellAct {
            calCell.configure(segment: selectedSegmentIndex)
        }

        collectionView.reloadSections(IndexSet(integer: 2))
    }


    func generateLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )

            switch sectionIndex {
            case 0:
                let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 16, bottom: 16, trailing: 16)
                return section

            case 1:
                let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(self.calendarHeight)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
                return section

            case 2:
                let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
                return section

            case 3:
                let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
                return section

            default:
                let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)), subitems: [item])
                return NSCollectionLayoutSection(group: group)
            }
        }
    }


    func style(_ cell: UICollectionViewCell) {
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
    }
}
