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
    
    let items = ["Streak", "Activity Ring", "Mood Count", "Next Session", "Mood Log", "Logs", "Journaling", "Art"]
    let  images = [
        UIImage(systemName: "book"),
        UIImage(systemName: "paintpalette")
    ]
    @IBOutlet var moodCount: UILabel!
    var toDoItems: [TodayActivityItem] = []
    var patient: Patient?
    
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
        
        collectionView.collectionViewLayout = generateLayout()
        
        collectionView.alwaysBounceVertical = true

        let menu = makeDashboardMenu()
        let more = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: menu)
        navigationItem.rightBarButtonItem = more
        load()
    }
    func load() {
        let today = Date()

        Task{
            do{
                let allToday = try await buildTodayItems(for: patient!.patientID).map { item in
                    let todayLogs = item.logs.filter {
                        Calendar.current.isDate($0.date, inSameDayAs: today)
                    }
                    return TodayActivityItem(
                        activity: item.activity,
                        assignment: item.assignment,
                        completedToday: todayLogs.count,
                        logs: todayLogs
                    )
                }
                self.toDoItems = allToday.filter { !$0.isCompletedToday }
                self.collectionView.reloadData()
            }catch{
                print("Load activity error: \(error)")
            }
        }        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return 6 + toDoItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        
//        if indexPath.row == 0 {
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "streakCell",
//                for: indexPath
//            ) as! StreakCell                           // ✅ cast to StreakCell
//
//            // ✅ Build this week's logged dates from your activity logs
//            let cal = Calendar.current
//            let thisWeeksLogs: [Date] = toDoItems
//                .flatMap { $0.logs }
//                .filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }
//                .map { $0.date }
//
//            cell.configure(streakCount: 7, loggedDates: thisWeeksLogs)  // ✅ actually calls configure
//            return cell                                // ✅ early return
//        }
        if indexPath.row == 0 {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "streakCell",
                for: indexPath
            ) as! StreakCell

            let cal = Calendar.current

            let thisWeeksLogs: [Date] = toDoItems
                .flatMap { $0.logs }
                .map { $0.date }
                .filter {
                    cal.isDate($0, equalTo: Date(), toGranularity: .weekOfYear)
                }

//            cell.loggedDates = thisWeeksLogs

            return cell
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
            cell.backgroundColor = .secondarySystemBackground
            return cell
        }
        
        else if indexPath.row == 2{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moodCount", for: indexPath)
        }
        
        else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "nextSession",
                for: indexPath
            ) as! NextSessionCell

            var comps        = DateComponents()
            comps.year       = 2026; comps.month = 3; comps.day = 26
            comps.hour       = 14;   comps.minute = 0
            let sessionDate  = Calendar.current.date(from: comps) ?? Date()

            cell.configure(doctorName: "Dr. Meena Kumari", sessionDate: sessionDate)
            return cell
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
            cell.backgroundColor = .secondarySystemBackground
            return cell
        }
        else if indexPath.row == 5{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "section", for: indexPath)
        }
        else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BasicCell", for: indexPath)
            
            let toDoIndex = indexPath.row - 6
            let item = toDoItems[toDoIndex]
            
            if let label = cell.viewWithTag(1) as? UILabel {
                label.text = item.activity.name
            }
            if let image = cell.viewWithTag(2) as? UIImageView {
                image.image = UIImage(systemName: item.activity.iconName)
            }
            
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            cell.backgroundColor = .secondarySystemBackground
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let leftInset: CGFloat  = 16
            let rightInset: CGFloat = 16
            let interItemSpacing: CGFloat = 8

            let fullWidth = collectionView.frame.width - leftInset - rightInset
            let halfWidth = (fullWidth - interItemSpacing) / 2

            switch indexPath.row {
            case 0:       return CGSize(width: fullWidth, height: 230)
            case 1, 2:    return CGSize(width: halfWidth, height: 150)
            case 3:       return CGSize(width: fullWidth, height: 122)
            case 4:       return CGSize(width: fullWidth, height: 200)
            case 5:       return CGSize(width: fullWidth, height: 30)
            default:      return CGSize(width: fullWidth, height: 70)
            }
    }
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        return layout
    }
    
    @objc func moodTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedView = sender.view else { return }
        let selectedIndex = selectedView.tag
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
                        sender: (selectedIndex))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moodLog",
           let nav = segue.destination as? UINavigationController,
           let vc = nav.viewControllers.first as? MoodLogCollectionViewController,
           let data = sender as? Int {

            vc.selectedMood = data

            vc.patientId = self.patient?.patientID

            vc.onDismiss = { [weak self] in
                self?.resetMoodViews()
            }
            vc.onCheck = { [weak self] in
                self?.resetMoodViews()
            }
        }
    }
    
    func resetMoodViews() {
        for cell in collectionView.visibleCells {
            if let moodCell = cell as? MoodLogCollectionViewCell {
                UIView.animate(withDuration: 0.1) {
                    for view in moodCell.moodViews {
                        view.transform = .identity
                    }
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load()
        
        collectionView.reloadData()
        resetMoodViews()
    }
    
}

