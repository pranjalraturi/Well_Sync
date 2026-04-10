//
//  PatientVitalsCollectionViewController.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 10/02/26.
//

import UIKit

class PatientVitalsCollectionViewController: UICollectionViewController, VitalsBarRangeNavigating1 {
    
    var patient: Patient?
    enum DisplayRange: Int {
        case weekly = 0
        case monthly = 1
    }

    private let allVitals: [(title: String, color: UIColor)] = [
        ("Sleep", .systemIndigo),
        ("Steps", .systemOrange)
    ]
    
    private var displayedVitals: [(title: String, color: UIColor)] = [
        ("Sleep", .systemIndigo),
        ("Steps", .systemOrange)
    ]

    
    private var displayRange: DisplayRange = .weekly {
        didSet {
            barRanges = Array(repeating: displayRange, count: allVitals.count)
            reloadAllCharts()
        }
    }

    private let barMetrics: [PatientBarVitalsCollectionViewCell.MetricType] = [
        .sleep,
        .steps
    ]

    
    private var barRanges: [DisplayRange] = [.weekly, .weekly]
    private var barOffsets: [Int] = [0, 0]

    private func barRangeText(for index: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        let barRange = barRanges[safe: index] ?? .weekly
        let offset = barOffsets[safe: index] ?? 0
        switch barRange {
        case .weekly:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)!.start
            let targetStart = calendar.date(byAdding: .weekOfYear, value: offset, to: startOfWeek)!
            let targetEnd = calendar.date(byAdding: .day, value: 6, to: targetStart)!
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: targetStart)) – \(formatter.string(from: targetEnd))"
        case .monthly:
            let startOfMonth = calendar.dateInterval(of: .month, for: today)!.start
            let target = calendar.date(byAdding: .month, value: offset, to: startOfMonth)!
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            return formatter.string(from: target)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UINib(nibName: "PatientBarVitalsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "patientBarVitalsCell")
        collectionView.collectionViewLayout = generateLayout()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        return displayedVitals.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "segment1", for: indexPath)
                return cell
            }
        }
        
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "patientBarVitalsCell",
            for: indexPath
        ) as! PatientBarVitalsCollectionViewCell

        let barIndex = indexPath.row
        guard barIndex >= 0, barIndex < barMetrics.count else { return cell }

        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = displayedVitals[barIndex].title
            label.textColor = displayedVitals[barIndex].color
        }

        cell.rangeDelegate = self

        cell.configure(
            barIndex: barIndex,
            metric: barMetrics[barIndex],
            range: barRanges[barIndex] == .weekly ? .weekly : .monthly,
            offset: barOffsets[barIndex]
        )

        return cell


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
                
            default:
                height = .absolute(280)
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
    
    func reloadLineSection() {
        displayedVitals = allVitals
        let lineIndexPath = IndexPath(item: 0, section: 1)
        if collectionView.numberOfSections > 1 && collectionView.numberOfItems(inSection: 1) > 0 {
            collectionView.reloadItems(at: [lineIndexPath])
        } else {
            collectionView.reloadData()
        }
    }
    
    @IBAction func valueChnaged(_ sender: UISegmentedControl) {
        guard let range = DisplayRange(rawValue: sender.selectedSegmentIndex) else { return }
        displayRange = range
    }
    
    func didTapPrevBarRange(for index: Int) {
        barOffsets[index] = max(barOffsets[index] - 1, -2)
        reloadBar(at: index)
    }

    func didTapNextBarRange(for index: Int) {
        barOffsets[index] = min(barOffsets[index] + 1, 0)
        reloadBar(at: index)
    }

    func reloadBar(at barIndex: Int) {
        let indexPath = IndexPath(item: barIndex, section: 1)
        collectionView.reloadItems(at: [indexPath])
    }

    
    func didChangeBarRange(for barIndex: Int, to range: Int) {
        let newRange = DisplayRange(rawValue: range) ?? .weekly
        barRanges[barIndex] = newRange
        barOffsets[barIndex] = min(max(barOffsets[barIndex], -2), 0)
        reloadBar(at: barIndex)
    }

    func reloadAllCharts() {
        let items = [
            IndexPath(item: 0, section: 1),
            IndexPath(item: 1, section: 1)
        ]
        collectionView.reloadItems(at: items)
    }
    
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
