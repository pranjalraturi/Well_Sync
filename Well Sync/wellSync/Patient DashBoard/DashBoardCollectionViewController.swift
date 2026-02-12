import UIKit

class ActivityRingView: UIView {

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
        let clamped = min(max(value, 0), 1)

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

class DashboardCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // cell names....
    let items = ["Streak", "Activity Ring", "Mood Count", "Next Session", "Mood Log", "Logs", "Journaling", "Art"]
    let  images = [
        UIImage(systemName: "book"),
        UIImage(systemName: "paintpalette")
    ]
    
    
    private func makeDashboardMenu() -> UIMenu {
        let profile = UIAction(title: "Profile", image: UIImage(systemName: "person")) { _ in
            self.performSegue(withIdentifier: "PatientProfile", sender: nil)
        }
        let appointments = UIAction(title: "Appointments", image: UIImage(systemName: "calendar")) { _ in
            // TODO: Show Appointments
        }
        let settings = UIAction(title: "Settings", image: UIImage(systemName: "gear")) { _ in
            self.performSegue(withIdentifier: "PateintSetting", sender: nil)
        }
        let menu = UIMenu(title: "", children: [profile, appointments, settings])
        return menu
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        
        collectionView.alwaysBounceVertical = true

        let menu = makeDashboardMenu()
        let more = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: menu)
        navigationItem.rightBarButtonItem = more
    }
    
    // MARK: - Data Source
    
    // number of sections in a collection view
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    // Number of items in a single section
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        
        // setting custom cells to every index path
        if indexPath.row == 0{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "streakCell", for: indexPath)
        }
        
        else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "activityRing",
                for: indexPath
            ) as! ActivityRingCell
            
            cell.configure(progress: 1/3)
            
            if let label = cell.viewWithTag(1) as? UILabel {
                label.text = items[indexPath.row]
            }
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true

            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.2
            cell.layer.shadowOffset = CGSize(width: 0, height: 4)
            cell.layer.shadowRadius = 8
            cell.layer.masksToBounds = false
            return cell
        }
        
        else if indexPath.row == 2{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moodCount", for: indexPath)
        }
        
        else if indexPath.row == 3{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nextSession", for: indexPath)
        }
        
        else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "moodLog",
                for: indexPath
            ) as! MoodLogCollectionViewCell

            cell.configureTap(target: self, action: #selector(moodTapped(_:)))
            if let label = cell.viewWithTag(1) as? UILabel { label.text = items[indexPath.row] }
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true

            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.2
            cell.layer.shadowOffset = CGSize(width: 0, height: 4)
            cell.layer.shadowRadius = 8
            cell.layer.masksToBounds = false
            return cell
        }
        else if indexPath.row == 5{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "section", for: indexPath)
        }
        else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BasicCell", for: indexPath)
        }
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = items[indexPath.row]
        }
        if let image = cell.viewWithTag(2) as? UIImageView {
            image.image = images[indexPath.row-6]
            
        }
        // Adding shadow to the cell
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowOffset = CGSize(width: 0, height: 4)
        cell.layer.shadowRadius = 8
        cell.layer.masksToBounds = false
        
        // returning cell
        return cell
    }
    
    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fullWidth = collectionView.frame.width
        let halfWidth = (fullWidth - 3) / 2
        
        switch indexPath.row {
        case 1, 2: return CGSize(width: halfWidth, height: 150)
        case 0:    return CGSize(width: fullWidth, height: 116)
        case 3:    return CGSize(width: fullWidth, height: 110)
        case 4:    return CGSize(width: fullWidth, height: 180)
        case 5:    return CGSize(width: fullWidth, height: 30)
        default:   return CGSize(width: fullWidth, height: 70)
        }
    }
    
    // what to done after mood view is tapped
    @objc func moodTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedView = sender.view else { return }
        let selectedIndex = selectedView.tag
        // scale animation
        UIView.animate(withDuration: 0.15,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: []) {
            selectedView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.performSegue(
                        withIdentifier: "moodLog",
                        sender: (selectedIndex, selectedView.backgroundColor))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moodLog",
           let nav = segue.destination as? UINavigationController,
           let vc = nav.viewControllers.first as? MoodLogCollectionViewController,
           let data = sender as? (Int, UIColor) {

            vc.selectedMood = data.0
            vc.selectedMoodColor = data.1

            vc.onDismiss = { [weak self] in
                self?.resetMoodViews()
            }
        }
    }

    
    // resting back the scale of mood view
    func resetMoodViews() {
        for cell in collectionView.visibleCells {
            if let moodCell = cell as? MoodLogCollectionViewCell {
                UIView.animate(withDuration: 0.1) {
                    for view in moodCell.moodView {
                        view.transform = .identity
                    }
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetMoodViews()
    }
    
}

