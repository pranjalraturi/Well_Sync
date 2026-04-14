////
////  ActivityTableViewController.swift
////  patientSide
////
////  Created by Rishika Mittal on 27/01/26.
////
////
//
//import UIKit
//import PhotosUI
//
//class ActivityTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
//
//    var todayItems:   [TodayActivityItem] = []
//    var logSummaries: [LogSummaryItem]    = []
//    var patient:      Patient?
//    var uploads: [UIImage] = []
//    var selectedItem: TodayActivityItem?
//
//    let sectionTitles    = ["Today", "Logs"]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.separatorStyle     = .none
//        tableView.rowHeight          = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 100
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        loadData()
//    }
//
////    private func loadData() {
////        guard let patientID = patient?.patientID else { return }
////
////        Task {
////            do {
////                todayItems   = try await buildTodayItems(for: patientID)
////                logSummaries = try await buildLogSummaries(for: patientID)
////                print("3-->",patientID)
////
////                DispatchQueue.main.async {
////                    self.tableView.reloadData()
////                }
////            } catch {
////                print("loadData error:", error)
////            }
////        }
////    }
//    private func loadData() {
//        guard let patientID = patient?.patientID else { return }
//
//        Task {
//            do {
//                async let todayTask = buildTodayItems(for: patientID)
//                async let logsTask  = buildLogSummaries(for: patientID)
//
//                let today = try await todayTask
//
//                // 🔥 Show TODAY instantly
//                await MainActor.run {
//                    self.todayItems = today
//                    self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
//                }
//
//                let logs = try await logsTask
//
//                // 🔥 Then show LOGS
//                await MainActor.run {
//                    self.logSummaries = logs
//                    self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
//                }
//
//            } catch {
//                print("loadData error:", error)
//            }
//        }
//    }
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return sectionTitles.count
//    }
//
//    override func tableView(_ tableView: UITableView,
//                            numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case 0:  return todayItems.count
//        case 1:  return logSummaries.count
//        default: return 0
//        }
//    }
//
//    override func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(
//            withIdentifier: "activityCell",
//            for: indexPath
//        ) as! TodayTableViewCell
//
//        if indexPath.section == 0 {
//            cell.configure(with: todayItems[indexPath.row])
//            cell.onPhotoSourceSelected = { [weak self] sourceType in
//                
//                self?.selectedItem = self?.todayItems[indexPath.row]
//                self?.uploads = []
//                print("DEBUG 1 — selectedItem:", self?.selectedItem?.activity.name ?? "NIL")
//                print("DEBUG 1 — patient:", self?.patient?.patientID.uuidString ?? "NIL")
//                self?.openImagePicker(sourceType: sourceType)
//            }
//        } else {
//            let summary = logSummaries[indexPath.row]
//            cell.configureAsLog(
//                activityName: summary.activity.name,
//                iconName:     summary.activity.iconName,
//                logCount:     summary.totalLogs
//            )
//        }
//
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView,viewForHeaderInSection section: Int) -> UIView? {
//
//        let headerView    = UIView()
//
//        let titleLabel    = UILabel()
//        titleLabel.font   = UIFont.preferredFont(forTextStyle: .title2)
//        titleLabel.textColor = .label
//
//        let subtitleLabel    = UILabel()
//        subtitleLabel.font   = UIFont.preferredFont(forTextStyle: .footnote)
//        subtitleLabel.textColor = .secondaryLabel
//
//        if section == 0 {
//            let completed      = todayItems.filter { $0.isCompletedToday }.count
//            let pending        = todayItems.count - completed
//            titleLabel.text    = "Today"
//            subtitleLabel.text = "\(pending) pending · \(completed) completed"
//        } else {
//            titleLabel.text    = "Logs"
//            subtitleLabel.text = "\(logSummaries.count) activities logged"
//        }
//
//        titleLabel.translatesAutoresizingMaskIntoConstraints    = false
//        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        headerView.addSubview(titleLabel)
//        headerView.addSubview(subtitleLabel)
//
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
//
//            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
//            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0)
//        ])
//
//        return headerView
//    }
//
//    override func tableView(_ tableView: UITableView,heightForHeaderInSection section: Int) -> CGFloat {
//        return 60
//    }
//    
//    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
//        
//        if sourceType == .camera {
//            // Camera still uses UIImagePickerController (PHPicker doesn't support camera)
//            let picker           = UIImagePickerController()
//            picker.delegate      = self
//            picker.sourceType    = .camera
//            picker.allowsEditing = true
//            present(picker, animated: true)
//
//        } else {
//            // Photo Library uses PHPickerViewController for multi-select
//            var config           = PHPickerConfiguration()
//            config.selectionLimit = 5   // ← set 0 for unlimited, or any number you want
//            config.filter        = .images
//
//            let picker           = PHPickerViewController(configuration: config)
//            picker.delegate      = self
//            present(picker, animated: true)
//        }
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController,
//                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        if let editedImage = info[.editedImage] as? UIImage {
//            uploads.append(editedImage)
//        } else if let originalImage = info[.originalImage] as? UIImage {
//            uploads.append(originalImage)
//        }
//
//        dismiss(animated: true){
//            self.saveActivityLog()
//            print("DEBUG 2 — uploads count:", self.uploads.count)
//        }
//    }
//    
//    func picker(_ picker: PHPickerViewController,
//                didFinishPicking results: [PHPickerResult]) {
//
//        picker.dismiss(animated: true)
//        guard !results.isEmpty else { return }
//
//        let total   = results.count   // how many images to wait for
//        var loaded  = 0               // how many have finished loading
//
//        for result in results {
//            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
//                DispatchQueue.main.async {
//
//                    if let image = object as? UIImage {
//                        self.uploads.append(image)
//                        print("Got image:", image.size)
//                    }
//
//                    loaded += 1
//
//                    // Only call saveActivityLog when ALL images are done
//                    if loaded == total {
//                        self.saveActivityLog()
//                    }
//                }
//            }
//        }
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true)
//    }
//    
//    private func saveActivityLog() {
//        print("DEBUG 4 — saveActivityLog called")
//        print("DEBUG 4 — selectedItem:", selectedItem?.activity.name ?? "NIL")
//        print("DEBUG 4 — patient:", patient?.patientID.uuidString ?? "NIL")
//        print("DEBUG 4 — uploads count:", uploads.count)
//        guard let item    = selectedItem,
//              let patient = patient else {
//            print("saveActivityLog: missing item or patient")
//            return
//        }
//
//        guard !uploads.isEmpty else {
//            print("saveActivityLog: no images to upload")
//            return
//        }
//
//        Task {
//            do {
//                var uploadedPaths: [String] = []
//                for image in uploads {
//                    let path = try await AccessSupabase.shared.uploadActivityImage(image)
//                    uploadedPaths.append(path)
//                    print("Uploaded:", path)
//                }
//
//                // Step 2: Format current time
//                let formatter        = DateFormatter()
//                formatter.dateFormat = "HH:mm:ss"
//                let timeString       = formatter.string(from: Date())
//
//                // Step 3: Build ActivityLog
//                let log = ActivityLog(
//                    logID:      UUID(),
//                    assignedID: item.assignment.assignedID,
//                    activityID: item.activity.activityID,
//                    patientID:  patient.patientID,
//                    date:       Date(),
//                    time:       timeString,
//                    duration:   nil,
//                    uploadPath: uploadedPaths.joined(separator: ",")
//                )
//
//                let saved = try await AccessSupabase.shared.saveActivityLog(log)
//                print("ActivityLog saved:", saved.logID)
//
//                // Step 5: Reset and reload
//                DispatchQueue.main.async {
//                    self.uploads      = []
//                    self.selectedItem = nil
//                    self.loadData()
//                }
//
//            } catch {
//                print("saveActivityLog error:", error)
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Upload Failed",
//                                                  message: "\(error)",
//                                                  preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default))
//                    self.present(alert, animated: true)
//                }
//            }
//        }
//    }
//}
import UIKit
import PhotosUI

class ActivityTableViewController: UITableViewController {

    var todayItems:   [TodayActivityItem] = []
    var logSummaries: [LogSummaryItem]    = []
    
    var patient: Patient? {
        didSet {
            guard patient != nil else { return }
            actionHandler.patient = patient
            loadData()
        }
    }

    // MARK: - Existing Logic (UNCHANGED)
    private let actionHandler = ActivityActionHandler()
    private let spinner       = UIActivityIndicatorView(style: .large)
    let sectionTitles         = ["Today", "Logs"]

    // MARK: - ✅ Onboarding Logic (ADDED)
    private var onboardingSequence: FeatureOnboardingSequence?

    required init?(coder: NSCoder) { super.init(coder: coder) }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle     = .none
        tableView.rowHeight          = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        // MARK: - Existing handler wiring (UNCHANGED)
        actionHandler.presentingViewController = self
        actionHandler.onSuccess = { [weak self] in self?.loadData() }
        actionHandler.onFailure = { [weak self] error in
            let alert = UIAlertController(title: "Upload Failed",
                                          message: "\(error)",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        actionHandler.onTimerTapped = { [weak self] item in
            self?.performSegue(withIdentifier: "Timer", sender: item)
        }

        // MARK: - Spinner (UNCHANGED)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // MARK: - ✅ Onboarding Init (ADDED)
        onboardingSequence = FeatureOnboardingSequence(
            viewController: self,
            storageKey: "patient_activity"
        ) { [weak self] in
            self?.makeOnboardingSteps() ?? []
        }
    }

    // MARK: - ✅ Trigger after screen appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startOnboardingIfPossible()
    }

    // MARK: - Data

    private func loadData() {
        guard let patientID = patient?.patientID else { return }
        
        DispatchQueue.main.async { self.spinner.startAnimating() }

        Task {
            do {
                let today = try await buildTodayItems(for: patientID)
                let logs  = try await buildLogSummaries(for: patientID)

                await MainActor.run {
                    self.todayItems   = today
                    self.logSummaries = logs
                    self.tableView.reloadData()
                    self.spinner.stopAnimating()
                }

                // MARK: - ✅ Start onboarding AFTER data loads
                DispatchQueue.main.async {
                    self.startOnboardingIfPossible()
                }

            } catch {
                print("loadData error:", error)
                await MainActor.run { self.spinner.stopAnimating() }
            }
        }
    }

    // MARK: - TableView

    override func numberOfSections(in tableView: UITableView) -> Int {
        sectionTitles.count
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        section == 0 ? todayItems.count : logSummaries.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "activityCell",
            for: indexPath
        ) as! TodayTableViewCell

        if indexPath.section == 0 {
            let item = todayItems[indexPath.row]

            if item.isUploadType {
                cell.configure(with: item)
                cell.onPhotoSourceSelected = { [weak self] sourceType in
                    guard let self else { return }
                    self.actionHandler.selectedItemPublic = item
                    self.actionHandler.openPickerDirectly(sourceType: sourceType)
                }
            } else {
                cell.configureAsTimer(with: item)
                cell.onTimerTapped = { [weak self] in
                    self?.actionHandler.handle(item: item)
                }
            }

            cell.addPhotoButton.isEnabled = !item.isCompletedToday

        } else {
            let summary = logSummaries[indexPath.row]
            cell.configureAsLog(
                activityName: summary.activity.name,
                iconName: summary.activity.iconName,
                logCount: summary.totalLogs
            )
        }

        return cell
    }

    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView()

        let titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.textColor = .label

        let subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        subtitleLabel.textColor = .secondaryLabel

        if section == 0 {
            let completed = todayItems.filter { $0.isCompletedToday }.count
            let pending   = todayItems.count - completed
            titleLabel.text = "Today"
            subtitleLabel.text = "\(pending) pending · \(completed) completed"
        } else {
            titleLabel.text = "Logs"
            subtitleLabel.text = "\(logSummaries.count) activities logged"
        }

        [titleLabel, subtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        return headerView
    }

    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        60
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            let identifier = todayItems[indexPath.row].isUploadType ? "Journal" : "timerSegue"
            performSegue(withIdentifier: identifier, sender: indexPath)
        } else {
            let identifier = logSummaries[indexPath.row].isUploadType ? "Journal" : "timerSegue"
            performSegue(withIdentifier: identifier, sender: indexPath)
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "Timer",
           let nav = segue.destination as? UINavigationController,
           let timerVC = nav.viewControllers.first as? timerViewController,
           let item = sender as? TodayActivityItem {

            timerVC.onSave = { self.loadData() }
            timerVC.activityItem = item
            timerVC.patient = patient
        }

        guard let indexPath = sender as? IndexPath else { return }

        if segue.identifier == "Journal",
           let journalVC = segue.destination as? JournalTableViewController {

            if indexPath.section == 0 {
                let item = todayItems[indexPath.row]
                journalVC.selectedAssignment = item.assignment
                journalVC.selectedActivity = item.activity
            } else {
                let item = logSummaries[indexPath.row]
                journalVC.selectedAssignment = item.assignment
                journalVC.selectedActivity = item.activity
            }

            journalVC.patient = patient
        }

        if segue.identifier == "timerSegue",
           let graphVC = segue.destination as? GraphCollectionViewController {

            if indexPath.section == 0 {
                let item = todayItems[indexPath.row]
                graphVC.activity = item.activity
                graphVC.logs = item.logs
            } else {
                let item = logSummaries[indexPath.row]
                graphVC.activity = item.activity
                graphVC.logs = item.logs
            }

            graphVC.patient = patient
        }
    }

    // MARK: - ✅ Onboarding Steps

    private func makeOnboardingSteps() -> [FeatureSpotlightStep] {
        tableView.layoutIfNeeded()

        let firstTodayIndexPath = todayItems.isEmpty ? nil : IndexPath(row: 0, section: 0)
        let firstLogIndexPath   = logSummaries.isEmpty ? nil : IndexPath(row: 0, section: 1)

        return [
            FeatureSpotlightStep(
                title: "Complete today’s assigned work",
                message: "Your current activities appear here so you can upload progress or start a timer for the task.",
                placement: .below,
                targetProvider: { [weak self] in
                    guard let self, let indexPath = firstTodayIndexPath else { return nil }
                    return (self.tableView.cellForRow(at: indexPath) as? TodayTableViewCell)?.cardView
                }
            ),
            FeatureSpotlightStep(
                title: "Add proof or start the task",
                message: "Use this button to log photos or begin a timed session.",
                placement: .below,
                targetProvider: { [weak self] in
                    guard let self, let indexPath = firstTodayIndexPath else { return nil }
                    return (self.tableView.cellForRow(at: indexPath) as? TodayTableViewCell)?.addPhotoButton
                }
            ),
            FeatureSpotlightStep(
                title: "Review previous logs",
                message: "Your completed history is shown here.",
                placement: .above,
                targetProvider: { [weak self] in
                    guard let self, let indexPath = firstLogIndexPath else { return nil }
                    return (self.tableView.cellForRow(at: indexPath) as? TodayTableViewCell)?.cardView
                }
            )
        ]
    }

    // MARK: - ✅ Onboarding Starter

    private func startOnboardingIfPossible() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.onboardingSequence?.startIfNeeded()
        }
    }
}
