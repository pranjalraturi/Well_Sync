import UIKit

class ActivityRingView: UIView {

    private let trackLayer    = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private var didSetup      = false
    private var onboardingSequence: FeatureOnboardingSequence?

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

        trackLayer.path         = path.cgPath
        trackLayer.strokeColor  = UIColor.systemGray4.cgColor
        trackLayer.lineWidth    = 12
        trackLayer.fillColor    = UIColor.clear.cgColor

        progressLayer.path        = path.cgPath
        progressLayer.strokeColor = UIColor.systemCyan.cgColor
        progressLayer.lineWidth   = 12
        progressLayer.fillColor   = UIColor.clear.cgColor
        progressLayer.lineCap     = .round
        progressLayer.strokeEnd   = 0

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
        let animation              = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue        = 0
        animation.toValue          = value
        animation.duration         = duration
        animation.timingFunction   = CAMediaTimingFunction(name: .easeInEaseOut)
        progressLayer.strokeEnd    = value
        progressLayer.add(animation, forKey: "progress")
    }

    func reset() {
        progressLayer.removeAllAnimations()
        progressLayer.strokeEnd = 0
    }
}

class DashboardCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let items  = ["Streak", "Activity Ring", "Mood Count", "Next Session", "Mood Log", "Logs", "Journaling", "Art"]
    let images = [UIImage(systemName: "book"), UIImage(systemName: "paintpalette")]

    @IBOutlet var moodCount: UILabel!

    var toDoItems:    [TodayActivityItem] = []
    var ActivityLogs: [ActivityLog]       = []
    var mood:         [MoodLog]           = []
    
    var currentStreak: Int = 0
    var totalTodayItems: Int = 0
    private var onboardingSequence: FeatureOnboardingSequence?
    var patient: Patient? {
        didSet {
            guard patient != nil else { return }
            load()
            AccessHealthKit.healthKit.syncSleepToSupabase(
                patientID: patient!.patientID,
                nightsBack: 30
            )
            AccessHealthKit.healthKit.syncStepsToSupabase(patientID: patient!.patientID, daysBack: 30)
        }
    }
    
    private let actionHandler = ActivityActionHandler()

    private func makeDashboardMenu() -> UIMenu {
        let profile = UIAction(title: "Profile", image: UIImage(systemName: "person")) { _ in
            self.performSegue(withIdentifier: "PatientProfile", sender: nil)
        }
        let appointments = UIAction(title: "Appointments", image: UIImage(systemName: "calendar")) { _ in }
        let settings = UIAction(title: "Settings", image: UIImage(systemName: "gear")) { _ in
            self.performSegue(withIdentifier: "PateintSetting", sender: nil)
        }
        return UIMenu(title: "", children: [profile, appointments, settings])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        collectionView.register(UINib(nibName: "StreakCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StreakCell")
        collectionView.collectionViewLayout  = generateLayout()
        collectionView.alwaysBounceVertical  = true

        onboardingSequence = FeatureOnboardingSequence(
            viewController: self,
            storageKey: "patient_dashboard"
        ) { [weak self] in
            self?.makeOnboardingSteps() ?? []
        }
        let menu = makeDashboardMenu()
        let more = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: menu)
        navigationItem.rightBarButtonItem = more

        // Add this in viewDidLoad, after super
        actionHandler.presentingViewController = self
        actionHandler.onSuccess = { [weak self] in self?.load() }
        actionHandler.onFailure = { [weak self] error in
            let alert = UIAlertController(title: "Upload Failed",
                                          message: "\(error)",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        actionHandler.onTimerTapped = { [weak self] item in
            // Dashboard doesn't have a timer segue yet — add identifier if needed
            self?.performSegue(withIdentifier: "Timer", sender: item)
        }
        
        
    }

    private func startOnboardingIfPossible() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.onboardingSequence?.startIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load()
        resetMoodViews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startOnboardingIfPossible()
    }

    func load() {
        guard let patientID = patient?.patientID else { return }
        let today = Date()
        let cal   = Calendar.current

        Task {
            do {
                // ✅ All 3 fetched in parallel
                async let todayTask = buildTodayItems(for: patientID)
                async let logsTask  = AccessSupabase.shared.fetchLogs(for: patientID)
                async let moodTask  = AccessSupabase.shared.fetchMoodLogs(patientID: patientID)

                let allItems = try await todayTask
                let logs     = try await logsTask
                let moods    = try await moodTask

                let allToday = allItems.map { item -> TodayActivityItem in
                    let todayLogs = item.logs.filter {
                        cal.isDate($0.date, inSameDayAs: today)
                    }
                    return TodayActivityItem(
                        activity:       item.activity,
                        assignment:     item.assignment,
                        completedToday: todayLogs.count,
                        logs:           todayLogs
                    )
                }

                // ✅ Compute streak here once, not inside cellForItemAt
                let allLoggedDates: Set<Date> = Set(logs.map { cal.startOfDay(for: $0.date) })
                var streak = 0
                if let mostRecentDate = allLoggedDates.sorted().last {
                    var checkDate = mostRecentDate
                    while allLoggedDates.contains(checkDate) {
                        streak += 1
                        guard let prev = cal.date(byAdding: .day, value: -1, to: checkDate) else { break }
                        checkDate = prev
                    }
                }

                await MainActor.run {
                    self.ActivityLogs   = logs
                    self.mood           = moods
                    self.currentStreak  = streak
                    self.totalTodayItems = allToday.count
                    self.toDoItems      = allToday.filter { !$0.isCompletedToday }
                    self.collectionView.reloadSections(IndexSet([0, 2]))
                    self.collectionView.reloadItems(at: [IndexPath(row: 0, section: 1),IndexPath(row: 1, section: 1)])
                    
                    DispatchQueue.main.async {
                        self.startOnboardingIfPossible()
                    }
                }

            } catch {
                print("Load error: \(error)")
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int { 3 }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:  return 1
        case 1:  return 5
        default: return toDoItems.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
            
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "StreakCell", for: indexPath
            ) as! StreakCollectionViewCell

            let cal = Calendar.current

            var weekComponents = cal.dateComponents(
                [.yearForWeekOfYear, .weekOfYear], from: Date()
            )
            weekComponents.weekday = 1
            let sunday = cal.date(from: weekComponents)!

            let weekDates: [Date] = (0..<7).compactMap {
                cal.date(byAdding: .day, value: $0, to: sunday)
            }

            let loggedDaysSet = Set(
                ActivityLogs.map { cal.startOfDay(for: $0.date) }
            )
            let streakData: [(date: Date, isCompleted: Bool)] = weekDates.map { date in
                let day = cal.startOfDay(for: date)
                return (date: date, isCompleted: loggedDaysSet.contains(day))
            }

            cell.configure(with: streakData, currentStreak: currentStreak)

            style(cell)
            return cell
            
        case 1:
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "activityRing", for: indexPath
                ) as! ActivityRingCell
                let completed = totalTodayItems - toDoItems.count
                let progress  = totalTodayItems > 0
                ? CGFloat(completed) / CGFloat(totalTodayItems)
                : 0
                cell.configure(progress: progress)
                if let label = cell.viewWithTag(1) as? UILabel { label.text = items[indexPath.row + 1] }
                if let label1 = cell.viewWithTag(2) as? UILabel { label1.text = "\(completed)/\(totalTodayItems)" }
                style(cell)
                return cell
            }
            else if indexPath.row == 1 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "moodCount", for: indexPath
                ) as! MoodCollectionViewCell
                cell.configure(mood: mood)
                style(cell)
                return cell
            }
            else if indexPath.row == 2 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "nextSession", for: indexPath
                ) as! NextSessionCell
                var comps  = DateComponents()
                comps.year = 2026; comps.month = 3; comps.day = 26
                comps.hour = 14;   comps.minute = 0
                let sessionDate = patient?.nextSessionDate
                cell.configure(doctorName: "Dr. Meena Kumari", sessionDate: sessionDate)
                style(cell)
                return cell
            }
            else if indexPath.row == 3 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "moodLog", for: indexPath
                ) as! MoodLogCollectionViewCell
                cell.configureTap(target: self, action: #selector(moodTapped(_:)))
                if let label = cell.viewWithTag(1) as? UILabel { label.text = items[indexPath.row + 1] }
                style(cell)
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "section", for: indexPath
                )
                return cell
            }
            
        default:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "BasicCell", for: indexPath
            ) as! BasicCollectionViewCell

            let item = toDoItems[indexPath.row]

            if let label = cell.viewWithTag(1) as? UILabel     { label.text  = item.activity.name }
            if let image = cell.viewWithTag(2) as? UIImageView { image.image = UIImage(systemName: item.activity.iconName) }

            if item.isUploadType {
                // Shows Camera / Photo Library popover attached to the button — same as table view
                cell.setupPhotoMenu()
                cell.onPhotoSourceSelected = { [weak self] sourceType in
                    guard let self else { return }
                    self.actionHandler.selectedItemPublic = item
                    self.actionHandler.openPickerDirectly(sourceType: sourceType)
                }
            } else {
                // Timer type — button triggers timer segue
                cell.setupTimerButton()
                cell.onTimerTapped = { [weak self] in
                    self?.actionHandler.handle(item: item)  // routes to onTimerTapped → segue
                }
            }

            style(cell)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fullWidth = collectionView.frame.width - 32
        let halfWidth = (fullWidth - 8) / 2

        switch indexPath.section {
        case 0:  return CGSize(width: fullWidth, height: 140)
        case 1:
            if indexPath.row == 0 || indexPath.row == 1 { return CGSize(width: halfWidth, height: 150) }
            else if indexPath.row == 2 { return CGSize(width: fullWidth, height: 122) }
            else if indexPath.row == 3 { return CGSize(width: fullWidth, height: 172) }
            else                        { return CGSize(width: fullWidth, height: 30)  }
        default: return CGSize(width: fullWidth, height: 70)
        }
    }

    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing      = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 12, bottom: 8, right: 12)
        return layout
    }

//    @objc func moodTapped(_ sender: UITapGestureRecognizer) {
//        guard let selectedView = sender.view else { return }
//        let selectedIndex = selectedView.tag
//        UIView.animate(withDuration: 0.15, delay: 0,
//                       usingSpringWithDamping: 0.6,
//                       initialSpringVelocity: 0.8, options: []) {
//            selectedView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.performSegue(withIdentifier: "moodLog", sender: selectedIndex)
//        }
//    }
    @objc func moodTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedView = sender.view else { return }

        // ✅ Find the mood count cell and check cooldown
        if let moodCell = collectionView.cellForItem(at: IndexPath(row: 1, section: 1)) as? MoodCollectionViewCell,
           !moodCell.canLogNow {
            // Shake to signal "not yet"
            let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
            shake.values   = [0, -8, 8, -6, 6, -4, 4, 0]
            shake.duration = 0.4
            selectedView.layer.add(shake, forKey: "shake")

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            return
        }

        let selectedIndex = selectedView.tag
        UIView.animate(withDuration: 0.15, delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8, options: []) {
            selectedView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.performSegue(withIdentifier: "moodLog", sender: selectedIndex)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moodLog",
           let nav  = segue.destination as? UINavigationController,
           let vc   = nav.viewControllers.first as? MoodLogCollectionViewController,
           let data = sender as? Int {
            vc.selectedMood = data
            vc.patientId    = self.patient?.patientID
            vc.onDismiss    = { [weak self] in self?.resetMoodViews() }
            vc.onCheck      = { [weak self] in
                self?.load()
                self?.resetMoodViews()
            }
        }
        if segue.identifier == "Timer",
           let nav    = segue.destination as? UINavigationController,
           let timerVC = nav.viewControllers.first as? timerViewController,
           let item   = sender as? TodayActivityItem {
            timerVC.onSave       = { self.load() }
            timerVC.activityItem = item
            timerVC.patient      = patient
        }
    }

    func resetMoodViews() {
        for cell in collectionView.visibleCells {
            if let moodCell = cell as? MoodLogCollectionViewCell {
                UIView.animate(withDuration: 0.1) {
                    for view in moodCell.moodViews { view.transform = .identity }
                }
            }
        }
    }

    func style(_ cell: UICollectionViewCell) {
        cell.layer.shadowColor             = UIColor.white.cgColor
        cell.layer.shadowOpacity           = 0.2
        cell.layer.shadowOffset            = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius            = 5
        cell.layer.masksToBounds           = false
        cell.contentView.layer.cornerRadius  = 20
        cell.contentView.layer.masksToBounds = true
        cell.layer.cornerRadius            = 20
        cell.layer.shadowPath              = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 20).cgPath
    }
    private func makeOnboardingSteps() -> [FeatureSpotlightStep] {
        collectionView.layoutIfNeeded()

        return [
            FeatureSpotlightStep(
                title: "Your streak at a glance",
                message: "This shows your weekly consistency.",
                placement: .below,
                prepare: nil,
                targetProvider: { [weak self] in
                    guard let self,
                          let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
                    else { return nil }
                    return self.spotlightTarget(in: cell)
                }
            ),
            FeatureSpotlightStep(
                title: "Track daily progress",
                message: "See how much of today’s tasks are complete.",
                placement: .below,
                prepare: nil,
                targetProvider: { [weak self] in
                    guard let self,
                          let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
                    else { return nil }
                    return self.spotlightTarget(in: cell)
                }
            ),
            FeatureSpotlightStep(
                title: "Monitor mood",
                message: "Track your mood trends here.",
                placement: .below,
                prepare: { [weak self] in
                    self?.scrollDashboard(to: IndexPath(item: 1, section: 1))
                },
                targetProvider: { [weak self] in
                    guard let self,
                          let cell = self.collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
                    else { return nil }
                    return self.spotlightTarget(in: cell)
                }
            ),
            FeatureSpotlightStep(
                title: "Next session info",
                message: "Your upcoming appointment is shown here.",
                placement: .below,
                prepare: { [weak self] in
                    self?.scrollDashboard(to: IndexPath(item: 2, section: 1))
                },
                targetProvider: { [weak self] in
                    guard let self,
                          let cell = self.collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
                    else { return nil }
                    return self.spotlightTarget(in: cell)
                }
            ),
            FeatureSpotlightStep(
                title: "Log mood quickly",
                message: "Tap here to record your mood.",
                placement: .above,
                prepare: { [weak self] in
                    self?.scrollDashboard(to: IndexPath(item: 3, section: 1))
                },
                targetProvider: { [weak self] in
                    guard let self,
                          let cell = self.collectionView.cellForItem(at: IndexPath(item: 3, section: 1))
                    else { return nil }
                    return self.spotlightTarget(in: cell)
                }
            ),
            FeatureSpotlightStep(
                title: "Your tasks",
                message: "Pending activities appear here.",
                placement: .above,
                prepare: { [weak self] in
                    self?.scrollToTodoStep()
                },
                targetProvider: { [weak self] in
                    self?.todoSpotlightTarget()
                }
            )
        ]
    }
    private func spotlightTarget(in cell: UICollectionViewCell) -> UIView {
        cell.contentView.subviews.first ?? cell.contentView
    }

    private func scrollDashboard(to indexPath: IndexPath) {
        guard collectionView.numberOfSections > indexPath.section else { return }
        guard collectionView.numberOfItems(inSection: indexPath.section) > indexPath.item else { return }

        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        collectionView.layoutIfNeeded()
    }

    private func scrollToTodoStep() {
        if !toDoItems.isEmpty {
            scrollDashboard(to: IndexPath(item: 0, section: 2))
        } else {
            scrollDashboard(to: IndexPath(item: 4, section: 1))
        }
    }

    private func todoSpotlightTarget() -> UIView? {
        if !toDoItems.isEmpty,
           let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 2)) {
            return spotlightTarget(in: cell)
        }

        if let cell = collectionView.cellForItem(at: IndexPath(item: 4, section: 1)) {
            return spotlightTarget(in: cell)
        }

        return nil
    }
}
