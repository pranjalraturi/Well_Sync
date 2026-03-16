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
            cell.moodLogs = moodLogs
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
            cell.moodLogs = moodLogs
            return cell

        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bar_cell", for: indexPath) as! MoodChartCollectionViewCell
            style(cell)
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
//        cell.layer.shadowColor = UIColor.black.cgColor
//        cell.layer.shadowOpacity = 0.2
//        cell.layer.shadowOffset = CGSize(width: 0, height: 4)
//        cell.layer.shadowRadius = 8
//        cell.layer.masksToBounds = false
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
                height = .absolute(self.calendarCellHeight) // Calendar
            case 2:
                height = .estimated(250) // Mood Count
            case 3:
                height = .estimated(240) // Chart
            default:
                height = .estimated(160) // Insights
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

        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CalendarCell1 {
            cell.configure(segment: selectedSegmentIndex)
        }
    }
}


//
//  MoodAnalysisCollectionViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 04/02/26.
//
//
//import UIKit
//
//private let reuseIdentifier = "Cell"
//
//class MoodAnalysisCollectionViewController: UICollectionViewController {
//
//    let cards = ["Segment","Calender","Mood Count","Mood Chart","Insights"]
//    private var selectedSegmentIndex: Int = 0
//
//    // ✅ Store the calendar height here — starts at week height
//    private var calendarCellHeight: CGFloat = 250
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.collectionView.register(UINib(nibName: "CalendarCell1", bundle: nil), forCellWithReuseIdentifier: "calender")
//        self.collectionView.register(UINib(nibName: "MoodChartCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "bar_cell")
//        self.collectionView.register(UINib(nibName: "MoodCountCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "count_cell")
//        self.collectionView.register(UINib(nibName: "insightsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "insights_cell")
//        collectionView.collectionViewLayout = generateLayout()
//    }
//
//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return cards.count
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 1
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        switch indexPath.section {
//        case 1:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calender", for: indexPath) as! CalendarCell1
//            style(cell)
//
//            cell.onHeightChange = { [weak self] newHeight in
//                guard let self = self else { return }
//                self.calendarCellHeight = newHeight + 16
//                self.collectionView.collectionViewLayout = self.generateLayout()
//            }
//
//            cell.configure(segment: selectedSegmentIndex)
//            return cell
//
//        case 2:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "count_cell", for: indexPath) as! MoodCountCollectionViewCell
//            style(cell)
//            return cell
//
//        case 3:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bar_cell", for: indexPath) as! MoodChartCollectionViewCell
//            style(cell)
//            return cell
//
//        case 4:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "insights_cell", for: indexPath) as! insightsCollectionViewCell
//            style(cell)
//            return cell
//
//        default:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "segment", for: indexPath)
//            return cell
//        }
//    }
//
//    func style(_ cell: UICollectionViewCell) {
//        cell.layer.cornerRadius = 16
//        cell.layer.masksToBounds = true
//    }
//
//    func generateLayout() -> UICollectionViewCompositionalLayout {
//        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
//            guard let self = self else { return nil }
//
//            switch sectionIndex {
//            case 0:
//                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
//                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//                let section = NSCollectionLayoutSection(group: group)
//                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
//                return section
//
//            case 1:
//                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(self.calendarCellHeight))
//                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//                let section = NSCollectionLayoutSection(group: group)
//                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
//                return section
//
//            default:
//                let heights: [Int: CGFloat] = [2: 250, 3: 240, 4: 160]
//                let height = heights[sectionIndex] ?? 160
//                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(height))
//                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//                let section = NSCollectionLayoutSection(group: group)
//                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
//                return section
//            }
//        }
//    }
//
//    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
//        selectedSegmentIndex = sender.selectedSegmentIndex
//        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CalendarCell1 {
//            cell.configure(segment: selectedSegmentIndex)
//        }
//    }
//}
