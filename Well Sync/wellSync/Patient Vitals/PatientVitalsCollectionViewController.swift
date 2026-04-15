//
//  PatientVitalsCollectionViewController.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 10/02/26.
//
import UIKit

class PatientVitalsCollectionViewController: UICollectionViewController, VitalsBarRangeNavigating1 {
    
    var patient: Patient?
    
    // ✅ ONBOARDING
    private var onboardingSequence: FeatureOnboardingSequence?
    
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
        
        self.collectionView!.register(
            UINib(nibName: "PatientBarVitalsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "patientBarVitalsCell"
        )
        
        collectionView.collectionViewLayout = generateLayout()
        
        onboardingSequence = FeatureOnboardingSequence(
            viewController: self,
            storageKey: "patient_vitals"
        ) { [weak self] in
            self?.makeOnboardingSteps() ?? []
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startOnboardingIfPossible()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return displayedVitals.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: "segment1",
                for: indexPath
            )
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "patientBarVitalsCell",
            for: indexPath
        ) as! PatientBarVitalsCollectionViewCell

        let barIndex = indexPath.row
        guard barIndex < barMetrics.count else { return cell }

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
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            
            let height: NSCollectionLayoutDimension
            
            switch sectionIndex {
            case 0:
                height = .estimated(50)
            default:
                height = .absolute(280)
            }
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: height
                ),
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.interGroupSpacing = 16
            
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 16,
                leading: 16,
                bottom: 0,
                trailing: 16
            )
            
            return section
        }
    }
    // MARK: - Actions

    @IBAction func valueChnaged(_ sender: UISegmentedControl) {
        guard let range = DisplayRange(rawValue: sender.selectedSegmentIndex) else { return }
        displayRange = range
    }

    func didTapPrevBarRange(for index: Int) {
        barOffsets[index] = max(barOffsets[index] - 1, -10)
        reloadBar(at: index)
    }

    func didTapNextBarRange(for index: Int) {
        barOffsets[index] = min(barOffsets[index] + 1, 0)
        reloadBar(at: index)
    }

    func reloadBar(at barIndex: Int) {
        collectionView.reloadItems(at: [IndexPath(item: barIndex, section: 1)])
        
        DispatchQueue.main.async {
            self.startOnboardingIfPossible()
        }
    }

    func reloadAllCharts() {
        collectionView.reloadItems(at: [
            IndexPath(item: 0, section: 1),
            IndexPath(item: 1, section: 1)
        ])
        
        DispatchQueue.main.async {
            self.startOnboardingIfPossible()
        }
    }

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sleepLog",
           let nav = segue.destination as? UINavigationController,
           let vc  = nav.viewControllers.first as? VitalLogTableViewController {
            
            vc.patient = patient
            vc.onSave = { self.reloadAllCharts() }
        }
    }

    // MARK: - ✅ ONBOARDING

    private func makeOnboardingSteps() -> [FeatureSpotlightStep] {
        collectionView.layoutIfNeeded()

        return [
            FeatureSpotlightStep(
                title: "Switch time range",
                message: "Toggle between weekly and monthly views.",
                placement: .below,
                targetProvider: { [weak self] in
                    self?.collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
                }
            ),
            FeatureSpotlightStep(
                title: "Sleep insights",
                message: "Track your sleep trends here.",
                placement: .below,
                targetProvider: { [weak self] in
                    self?.collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
                }
            ),
            FeatureSpotlightStep(
                title: "Steps tracking",
                message: "Monitor your daily movement.",
                placement: .above,
                targetProvider: { [weak self] in
                    self?.collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
                }
            )
        ]
    }

    private func startOnboardingIfPossible() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.onboardingSequence?.startIfNeeded()
        }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
