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


class DoctorActivityStatusCollectionViewController: UICollectionViewController {
    
    var patient: Patient?

    var activities: [TodayActivityItem] = []
    var previousActivity: [LogSummaryItem] = []
    
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
                print("1-->",patient!.patientID)
            }catch{
                print("Activity log error: \(error)")
            }
            collectionView.reloadSections(IndexSet([1,2]))
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityStateCell", for: indexPath) as! activitystatusringCollectionViewCell
            cell.configure(progress: 3.0/7.0)
            return cell
        }
        
        if indexPath.section == 1 {
            // Current activities
            let item = activities[indexPath.row]
            let cell: UICollectionViewCell
            
            // Cell type determined by ASSIGNMENT's tracking method
            if item.isUploadType {  // Uses assignment.hasImage || assignment.hasRecording
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "uploadCell", for: indexPath) as! UploadCollectionViewCell
            } else {
                // Timer type
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "graphCell", for: indexPath) as! GraphCollectionViewCell
            }
            
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
        else {
            // Previous activities
            let item = previousActivity[indexPath.row]
            let cell: UICollectionViewCell
            
            // Cell type determined by ASSIGNMENT's tracking method
            if item.isUploadType {  // Uses assignment.hasImage || assignment.hasRecording
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "uploadCell", for: indexPath) as! UploadCollectionViewCell
            } else {
                // Timer type
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "graphCell", for: indexPath) as! GraphCollectionViewCell
            }
            
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
        if segue.identifier == "showAddActivity",
           let nav = segue.destination as? UINavigationController,
           let addVC = nav.topViewController as? AddActivityTableViewController {
            
            addVC.patient = self.patient
            addVC.onSave = {
                self.loadActivity()
            }
        }
        print(sender)
        if segue.identifier == "Journal",
           let journalVC = segue.destination as? JournalTableViewController,
           let indexPath = sender as? IndexPath {
            
            if indexPath.section == 1 {
                // Current activity
                let item = activities[indexPath.row]
                print(item,self.patient!)
                journalVC.selectedAssignment = item.assignment
                journalVC.selectedActivity = item.activity
                journalVC.patient = self.patient
                
            } else if indexPath.section == 2 {
                // Previous activity
                let item = previousActivity[indexPath.row]
                print(item,self.patient!)
                journalVC.selectedAssignment = item.assignment
                journalVC.selectedActivity = item.activity
                journalVC.patient = self.patient
            }
        }
    }
    
}
