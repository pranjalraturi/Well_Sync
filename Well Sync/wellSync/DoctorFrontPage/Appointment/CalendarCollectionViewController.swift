//
//  CalendarCollectionViewController.swift
//  calendar
//
//  Created by Vidit Saran Agarwal on 14/03/26.
//

import UIKit
import FSCalendar

// Note: Removed invalid IBOutlet to a UITableView that was connected to repeating content (e.g., inside a cell).
class CalendarCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    var selectedDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.collectionViewLayout = generateLayout()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "c",
                    for: indexPath
                ) as! CalendarCell

                cell.delegate = self

                return cell
            }

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "table",
                for: indexPath
            ) as! deatilsCollectionViewCell

            cell.updateDate(selectedDate)

            return cell
    }
    func generateLayout() -> UICollectionViewLayout {

        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        group.interItemSpacing = .fixed(12)

        // Section
        let section = NSCollectionLayoutSection(group: group)

        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 16,
            bottom: 0,
            trailing: 16
        )

        // Layout
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}

extension CalendarCollectionViewController: CalendarCellDelegate {

    func didSelect(date: Date) {

        selectedDate = date

        let index = IndexPath(item: 0, section: 1)

        if let cell = collectionView.cellForItem(at: index) as? deatilsCollectionViewCell {
            cell.updateDate(date)
        }
    }
}
