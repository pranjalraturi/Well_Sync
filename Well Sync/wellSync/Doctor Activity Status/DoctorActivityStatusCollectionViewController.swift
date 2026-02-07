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
        progressLayer.strokeColor = UIColor.systemCyan.cgColor
        progressLayer.lineWidth = 12
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0

        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
    }

    func setProgress(_ value: CGFloat, animated: Bool = true, duration: CFTimeInterval = 0.8) {
        let clamped = min(max(value, 0), 0)

        if animated {
            animateProgress(to: clamped, duration: duration)
        } else {
            progressLayer.strokeEnd = clamped
        }
    }
    
    private func animateProgress(to value: CGFloat, duration: CFTimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1
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

    var activities = ["Art","Journal","Breathing","Walking"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UINib(nibName: "UploadCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "uploadCell")
        self.collectionView!.register(UINib(nibName: "GraphCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "graphCell")
        
        self.collectionView!.collectionViewLayout = generateLayout()
        // Do any additional setup after loading the view.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0{
            return 1
        }
        return activities.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityStateCell", for: indexPath) as! activitystatusringCollectionViewCell
            cell.configure(progress: 3.0/7.0)
            return cell
        }
        
        if activities[indexPath.row] == "Art" || activities[indexPath.row] == "Journal" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "uploadCell", for: indexPath) as! UploadCollectionViewCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "graphCell", for: indexPath) as! GraphCollectionViewCell
        return cell
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            if sectionIndex == 0 {
                return self.generateLayoutForS1()
            } else {
                return self.generateLayoutForS2()
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
}
