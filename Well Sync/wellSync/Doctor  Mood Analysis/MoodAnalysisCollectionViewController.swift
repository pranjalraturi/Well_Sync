//
//  MoodAnalysisCollectionViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 04/02/26.
//

import UIKit


private let reuseIdentifier = "Cell"

class MoodAnalysisCollectionViewController: UICollectionViewController {

    let cards = ["Segment","Calender","Mood Count","Mood Chart","Insights"]
    private var selectedSegmentIndex: Int = 0
    private var calendarCellHeight: CGFloat = 250
    private var moodLogs: [MoodLog] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView.register(UINib(nibName: "CalendarCell1", bundle: nil), forCellWithReuseIdentifier: "calender")
        self.collectionView.register(UINib(nibName: "MoodChartCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "bar_cell")
        self.collectionView.register(UINib(nibName: "MoodCountCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "count_cell")
        self.collectionView.register(UINib(nibName: "insightsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "insights_cell")
        collectionView.collectionViewLayout = generateLayout()
        // Do any additional setup after loading the view.
    }

    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cards.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calender", for: indexPath) as! CalendarCell1
                        style(cell)
            cell.moodLogs = monthlyMoodLogs
                        cell.onHeightChange = { [weak self] newHeight in
                            guard let self = self else { return }

                            self.calendarCellHeight = newHeight + 16

                            self.collectionView.collectionViewLayout = self.generateLayout()
                        }
                    
                        cell.configure(segment: selectedSegmentIndex)
                        return cell

        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "count_cell", for: indexPath) as! MoodCountCollectionViewCell
            style(cell)
            cell.moodLogs = weeklyMoodLog
            return cell

        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bar_cell", for: indexPath) as! MoodChartCollectionViewCell
            style(cell)
            cell.moodLogs = weeklyMoodLog
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "insights_cell", for: indexPath) as! insightsCollectionViewCell
            style(cell)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "segment", for: indexPath)
            return cell
        }
    }

    func style(_ cell: UICollectionViewCell) {
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
    }

    func generateLayout() -> UICollectionViewCompositionalLayout {

        return UICollectionViewCompositionalLayout { sectionIndex, _ in

            let height: NSCollectionLayoutDimension
            
            switch sectionIndex {
            case 0:
                height = .estimated(50)
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: height
                )

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                group.interItemSpacing = .fixed(12)
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

                return section
            case 1:
                height = .absolute(self.calendarCellHeight)
            case 2:
                height = .estimated(250)
            case 3:
                height = .estimated(240)
            default:
                height = .estimated(160)
            }

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: height
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(8)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
            

            return section
        }
    }
    
    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex

            if let calCell = collectionView.cellForItem(
                at: IndexPath(item: 0, section: 1)
            ) as? CalendarCell1 {
                calCell.configure(segment: selectedSegmentIndex)
            }
        if let chartCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 3)) as? MoodChartCollectionViewCell {
            chartCell.isWeekly = (selectedSegmentIndex == 0)
            if chartCell.isWeekly{
                chartCell.moodLogs = weeklyMoodLog
            }
            else{
                chartCell.moodLogs = monthlyMoodLogs
            }
        }
        if let countCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 2)) as? MoodCountCollectionViewCell {
            countCell.isWeekly = (selectedSegmentIndex == 0)
            if countCell.isWeekly{
                countCell.moodLogs = weeklyMoodLog
            }
            else{
                countCell.moodLogs = monthlyMoodLogs
            }
        }
    }
}
