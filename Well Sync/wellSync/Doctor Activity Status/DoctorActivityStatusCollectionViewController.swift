//
//  DoctorActivityStatusCollectionViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 06/02/26.
//

import UIKit

private let reuseIdentifier = "Cell"

class ActivityStatusRingView: UIView {

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private var didSetup = false

    override func layoutSubviews() {
        super.layoutSubviews()

        if !didSetup {
            setupLayers()
            didSetup = true
        }
    }

    private func setupLayers() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 8

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )

        trackLayer.path = path.cgPath
        trackLayer.strokeColor = UIColor.systemGray4.cgColor
        trackLayer.lineWidth = 12
        trackLayer.fillColor = UIColor.clear.cgColor

        progressLayer.path = path.cgPath
        progressLayer.strokeColor = UIColor.systemOrange.cgColor
        progressLayer.lineWidth = 12
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0

        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
    }

    func setProgress(_ value: CGFloat, animated: Bool = true, duration: CFTimeInterval = 0.8) {
        let clamped = min(max(value, 0), 1)

        if animated {
            animateProgress(to: clamped, duration: duration)
        } else {
            progressLayer.strokeEnd = clamped
        }
    }
    
    private func animateProgress(to value: CGFloat, duration: CFTimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = value
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)

        progressLayer.strokeEnd = value
        progressLayer.add(animation, forKey: "progress")
    }
    
    func reset() {
        progressLayer.removeAllAnimations()
        progressLayer.strokeEnd = 0
    }
}

struct ActivityStatsManager {

    static func completionBetween(
        startDate: Date,
        endDate: Date,
        assignments: [AssignedActivity],
        logs: [ActivityLog]
    ) -> CGFloat {

        let calendar = Calendar.current
        let rangeStart = calendar.startOfDay(for: startDate)
        let rangeEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate

        var totalExpected = 0
        var totalActual = 0

        for assignment in assignments where assignment.status == .active {
            let effectiveStart = max(calendar.startOfDay(for: assignment.startDate), rangeStart)
            let effectiveEnd = min(calendar.startOfDay(for: assignment.endDate), calendar.startOfDay(for: endDate))

            guard effectiveStart <= effectiveEnd else { continue }

            let days = (calendar.dateComponents([.day], from: effectiveStart, to: effectiveEnd).day ?? 0) + 1
            let expected = days * assignment.frequency

            let actual = logs.filter {
                $0.assignedID == assignment.assignedID &&
                $0.date >= effectiveStart &&
                $0.date <= rangeEnd
            }.count

            totalExpected += expected
            totalActual += min(actual, expected)
        }

        guard totalExpected > 0 else { return 0 }
        return CGFloat(totalActual) / CGFloat(totalExpected)
    }

    static func weekRanges(from date: Date = Date()) -> (
        thisWeek: (start: Date, end: Date),
        lastWeek: (start: Date, end: Date)
    ) {
        let calendar = Calendar.current
        let thisWeek = calendar.dateInterval(of: .weekOfYear, for: date)!

        let thisStart = thisWeek.start
        let thisEnd = thisWeek.end.addingTimeInterval(-1)

        let lastStart = calendar.date(byAdding: .day, value: -7, to: thisStart)!
        let lastEnd = thisStart.addingTimeInterval(-1)

        return ((thisStart, thisEnd), (lastStart, lastEnd))
    }
}

class DoctorActivityStatusCollectionViewController: UICollectionViewController {
    
    var patient: Patient?

    var activities: [TodayActivityItem] = []
    var previousActivity: [LogSummaryItem] = []
    var currentWeekProgress: CGFloat = 0
    var previousWeekProgress: CGFloat = 0
    var delta: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.register(UINib(nibName: "UploadCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "uploadCell")
        self.collectionView!.register(UINib(nibName: "GraphCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "graphCell")
        self.collectionView.register(UINib(nibName: "HeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: "header", withReuseIdentifier: "headerCell")
        
        self.collectionView!.collectionViewLayout = generateLayout()
    }

    func loadActivity(){
        Task{
            do{
                activities = try await buildTodayItems(for: patient!.patientID)
                previousActivity = try await buildLogSummaries(for: patient!.patientID)
            }catch{
                print("Activity log error: \(error)")
            }
            let allAssignments = try await AccessSupabase.shared.fetchAssignments(for: patient!.patientID)
            let allLogs = try await AccessSupabase.shared.fetchLogs(for: patient!.patientID)

            let ranges = ActivityStatsManager.weekRanges()

            currentWeekProgress = ActivityStatsManager.completionBetween(
                startDate: ranges.thisWeek.start,
                endDate: ranges.thisWeek.end,
                assignments: allAssignments,
                logs: allLogs
            )

            previousWeekProgress = ActivityStatsManager.completionBetween(
                startDate: ranges.lastWeek.start,
                endDate: ranges.lastWeek.end,
                assignments: allAssignments,
                logs: allLogs
            )
                        
            delta = currentWeekProgress - previousWeekProgress
            collectionView.reloadSections(IndexSet([0,1,2]))
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else if section == 1{
            return activities.count
        }
        return previousActivity.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "activityStateCell",
                for: indexPath
            ) as! activitystatusringCollectionViewCell
            
            cell.configure(progress: currentWeekProgress)
            
            if let percentLabel = cell.viewWithTag(101) as? UILabel {
                percentLabel.text = "\(Int(currentWeekProgress * 100))%"
            }
            
            if let deltaLabel = cell.viewWithTag(102) as? UILabel {
                let sign = delta >= 0 ? "+" : ""
                deltaLabel.text = "\(sign)\(Int(delta * 100))%"
                deltaLabel.textColor = delta >= 0 ? .systemGreen : .systemRed
            }
            
            return cell
        }
        
        if indexPath.section == 1 {
            let item = activities[indexPath.row]

            if item.isUploadType {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "uploadCell",
                    for: indexPath
                ) as! UploadCollectionViewCell
                
                cell.configure(with: item.logs)
                
                // existing UI
                if let label = cell.viewWithTag(2) as? UILabel {
                    label.text = item.activity.name
                }
                if let logLabel = cell.viewWithTag(3) as? UILabel {
                    logLabel.text = String(item.logs.count)
                }
                if let iconView = cell.viewWithTag(4) as? UIImageView {
                    iconView.image = UIImage(systemName: item.activity.iconName)
                }

                return cell

            } else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "graphCell",
                    for: indexPath
                ) as! GraphCollectionViewCell
                // In cellForItemAt, section == 1, graph cell branch:
                print("🔍 Logs count for \(item.activity.name): \(item.logs.count)")
                // Also print each log's date:
                item.logs.forEach { print("   📅 \($0.date)") }
                
                cell.configure(with: item.logs)
                
                // existing UI
                if let label = cell.viewWithTag(2) as? UILabel {
                    label.text = item.activity.name
                }
                if let logLabel = cell.viewWithTag(3) as? UILabel {
                    logLabel.text = String(item.logs.count)
                }
                if let iconView = cell.viewWithTag(4) as? UIImageView {
                    iconView.image = UIImage(systemName: item.activity.iconName)
                }

                return cell
            }
        }
        else {
            let item = previousActivity[indexPath.row]

            if item.isUploadType {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "uploadCell",
                    for: indexPath
                ) as! UploadCollectionViewCell
                
                cell.configure(with: item.logs)
                
                if let label = cell.viewWithTag(2) as? UILabel {
                    label.text = item.activity.name
                }
                if let logLabel = cell.viewWithTag(3) as? UILabel {
                    logLabel.text = String(item.totalLogs)
                }
                if let iconView = cell.viewWithTag(4) as? UIImageView {
                    iconView.image = UIImage(systemName: item.activity.iconName)
                }

                return cell

            } else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "graphCell",
                    for: indexPath
                ) as! GraphCollectionViewCell
                
                cell.configure(with: item.logs)
                
                if let label = cell.viewWithTag(2) as? UILabel {
                    label.text = item.activity.name
                }
                if let logLabel = cell.viewWithTag(3) as? UILabel {
                    logLabel.text = String(item.totalLogs)
                }
                if let iconView = cell.viewWithTag(4) as? UIImageView {
                    iconView.image = UIImage(systemName: item.activity.iconName)
                }

                return cell
            }
        }
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            let headeSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(35.0))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headeSize, elementKind: "header", alignment: .topLeading)
            
            if sectionIndex == 0 {
                return self.generateLayoutForS1()
            } else {
                let section = self.generateLayoutForS2()
                section.boundarySupplementaryItems = [headerItem]
                return section
            }
        }
        return layout
    }

    
    func generateLayoutForS1() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(160)
            )

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 16, leading: 16, bottom: 8, trailing: 16)

            return section
    }
    
    func generateLayoutForS2() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(120)
            )

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 8, leading: 16, bottom: 16, trailing: 16)
            section.interGroupSpacing = 10

            return section
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 && activities[indexPath.row].isUploadType == true{
            performSegue(withIdentifier: "Journal", sender: indexPath)
        }else if indexPath.section == 2 && previousActivity[indexPath.row].isUploadType == true{
            performSegue(withIdentifier: "Journal", sender: indexPath)
        }
        if indexPath.section == 1 && activities[indexPath.row].isUploadType == false{
            performSegue(withIdentifier: "graph", sender: indexPath)
        }else if indexPath.section == 2 && previousActivity[indexPath.row].isUploadType == false{
            performSegue(withIdentifier: "graph", sender: indexPath)
        }
        
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var headerView:HeaderCollectionReusableView!
        if kind == "header"{
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath) as? HeaderCollectionReusableView
            
            if indexPath.section == 0{
                
            }
            else if indexPath.section == 1{
                headerView.configure(withTitle: "Current")
            }
            else if indexPath.section == 2{
                headerView.configure(withTitle: "Previous")
            }
        }
        return headerView
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadActivity()
//        Task{
//            do{
//                activities   = try await buildTodayItems(for: patient!.patientID)
//                previousActivity = try await buildLogSummaries(for: patient!.patientID)
//                print("2-->",patient!.patientID)
//            }catch{
//                print("Activity log error: \(error)")
//            }
//            collectionView.reloadData()
//        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // MARK: Add Activity
        if segue.identifier == "showAddActivity",
           let nav = segue.destination as? UINavigationController,
           let addVC = nav.topViewController as? AddActivityTableViewController {

            addVC.patient = self.patient
            addVC.onSave = {
                self.loadActivity()
            }
        }

        guard let indexPath = sender as? IndexPath else { return }

        // MARK: Journal (upload-type)
        if segue.identifier == "Journal",
           let journalVC = segue.destination as? JournalTableViewController {

            if indexPath.section == 1 {
                let item = activities[indexPath.row]
                journalVC.selectedAssignment = item.assignment
                journalVC.selectedActivity   = item.activity
                journalVC.patient            = self.patient

            } else if indexPath.section == 2 {
                let item = previousActivity[indexPath.row]
                journalVC.selectedAssignment = item.assignment
                journalVC.selectedActivity   = item.activity
                journalVC.patient            = self.patient
            }
        }

        // MARK: Graph (timer-type) ← NEW BLOCK
        if segue.identifier == "graph",
           let graphVC = segue.destination as? GraphCollectionViewController {

            if indexPath.section == 1 {
                // Current activity — all logs for that assignment
                let item = activities[indexPath.row]
                graphVC.assigned = item.assignment
                graphVC.activity = item.activity
                graphVC.logs     = item.logs        // [ActivityLog] already fetched
                graphVC.patient  = self.patient

            } else if indexPath.section == 2 {
                // Previous activity — all logs for that assignment
                let item = previousActivity[indexPath.row]
                graphVC.assigned = item.assignment
                graphVC.activity = item.activity
                graphVC.logs     = item.logs        // [ActivityLog] already fetched
                graphVC.patient  = self.patient
            }
        }
    }

    
}
