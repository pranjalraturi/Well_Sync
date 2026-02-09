import UIKit

class VitalsCollectionViewController: UICollectionViewController, VitalsRangeNavigating, VitalsBarRangeNavigating {
    
    enum DisplayRange: Int {
        case weekly = 0
        case monthly = 1
    }
    
    private struct LineGraphData {
        let xLabels: [String]
        let points: [Double]
    }
    
    private let allVitals: [(title: String, color: UIColor)] = [
        ("Sleep", .systemIndigo),
        ("Steps", .systemOrange)
    ]
    
    private var displayedVitals: [(title: String, color: UIColor)] = []
    
    private var displayRange: DisplayRange = .weekly {
        didSet {
            // Sync bar ranges with main segment selection while keeping offsets independent
            barRanges = Array(repeating: displayRange, count: allVitals.count)
            reloadAllCharts()
        }
    }
    
    private var lineOffset: Int = 0
    
    private let barMetrics: [VitalsBarCollectionViewCell.MetricType] = [
        .sleep,
        .steps
    ]

    
    // Independent bar ranges and offsets per bar index (0: Sleep, 1: Steps)
    private var barRanges: [DisplayRange] = [.weekly, .weekly]
    private var barOffsets: [Int] = [0, 0]

    
    private func currentRangeText() -> String {
        let calendar = Calendar.current
        let today = Date()

        switch displayRange {

        case .weekly:
            // 3 week window
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)!.start
            let targetStart = calendar.date(byAdding: .weekOfYear, value: lineOffset, to: startOfWeek)!

            let targetEnd = calendar.date(byAdding: .day, value: 6, to: targetStart)!

            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"

            return "\(formatter.string(from: targetStart)) – \(formatter.string(from: targetEnd))"


        case .monthly:
            let startOfMonth = calendar.dateInterval(of: .month, for: today)!.start
            let target = calendar.date(byAdding: .month, value: lineOffset, to: startOfMonth)!

            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"

            return formatter.string(from: target)
        }
    }
    
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

    private func makeLineGraphData(for range: DisplayRange) -> LineGraphData {

        switch range {
            case .weekly:

                let calendar = Calendar.current
                let today = Date()

                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)!.start
                let targetStart = calendar.date(byAdding: .weekOfYear, value: lineOffset, to: startOfWeek)!

                var labels: [String] = []

                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"

                for i in 0..<7 {
                    let date = calendar.date(byAdding: .day, value: i, to: targetStart)!
                    labels.append(formatter.string(from: date))
                }

                let points = (0..<7).map { _ in Double.random(in: 60...100) }

                return LineGraphData(xLabels: labels, points: points)
                
            case .monthly:

                let labels = ["W1","W2","W3","W4"]

                let points = (0..<4).map { _ in Double.random(in: 400...600) }

                return LineGraphData(xLabels: labels, points: points)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UINib(nibName: "VitalsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "vitalCell")
        self.collectionView!.register(UINib(nibName: "VitalsBarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "vitalBarCell")
        collectionView.collectionViewLayout = generateLayout()
        
        reloadAllCharts()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0{
            return 1
        }
        return 1 + displayedVitals.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            if indexPath.row == 0{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "segment", for: indexPath)
                return cell
            }
        }
        
        if indexPath.section == 1 && indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "vitalCell", for: indexPath) as! VitalsCollectionViewCell
            cell.rangeDelegate = self
            let lineData = makeLineGraphData(for: displayRange)
            cell.configure(rangeText: currentRangeText(), xLabels: lineData.xLabels, points: lineData.points)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "vitalBarCell",
            for: indexPath
        ) as! VitalsBarCollectionViewCell

        let barIndex = indexPath.row - 1
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
    
    
    // MARK: - VitalsRangeNavigating
    func didTapPrevRange() {
        lineOffset = max(lineOffset - 1, -2)
        reloadLineSection()
    }
    
    func didTapNextRange() {
        lineOffset = min(lineOffset + 1, 0)
        reloadLineSection()
    }
    
    // MARK: - VitalsBarRangeNavigating
    func didTapPrevBarRange(for index: Int) {
        barOffsets[index] = max(barOffsets[index] - 1, -2)
        reloadBar(at: index)
    }

    func didTapNextBarRange(for index: Int) {
        barOffsets[index] = min(barOffsets[index] + 1, 0)
        reloadBar(at: index)
    }

    func reloadBar(at barIndex: Int) {
        let indexPath = IndexPath(item: barIndex + 1, section: 1)
        collectionView.reloadItems(at: [indexPath])
    }

    
    func didChangeBarRange(for barIndex: Int, to range: Int) {
        let newRange = DisplayRange(rawValue: range) ?? .weekly
        barRanges[barIndex] = newRange
        barOffsets[barIndex] = min(max(barOffsets[barIndex], -2), 0)
        reloadBar(at: barIndex)
    }

    func reloadAllCharts() {
        displayedVitals = allVitals
        let items = [
            IndexPath(item: 0, section: 1),
            IndexPath(item: 1, section: 1),
            IndexPath(item: 2, section: 1)
        ]
        collectionView.reloadItems(at: items)
    }
    
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

