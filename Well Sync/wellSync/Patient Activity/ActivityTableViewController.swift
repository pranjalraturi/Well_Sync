//
//  ActivityTableViewController.swift
//  patientSide
//
//  Created by Rishika Mittal on 27/01/26.
//
//

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
    private let actionHandler = ActivityActionHandler()
    private let spinner       = UIActivityIndicatorView(style: .large)
    let sectionTitles         = ["Current", "Previous"]

    private var onboardingSequence: FeatureOnboardingSequence?

    required init?(coder: NSCoder) { super.init(coder: coder) }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle     = .none
        tableView.rowHeight          = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
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
            guard let self else { return }
            if self.isBreathingActivity(item) {
                self.presentBreathingController(for: item)
            } else {
                self.performSegue(withIdentifier: "Timer", sender: item)
            }
        }
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        onboardingSequence = FeatureOnboardingSequence(
            viewController: self,
            storageKey: "patient_activity"
        ) { [weak self] in
            self?.makeOnboardingSteps() ?? []
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startOnboardingIfPossible()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        if let navigationBar = navigationController?.navigationBar {
            let standardAppearance = UINavigationBarAppearance()
            standardAppearance.configureWithDefaultBackground()
            
            let scrollEdgeAppearance = UINavigationBarAppearance()
            scrollEdgeAppearance.configureWithTransparentBackground()
            
            navigationBar.standardAppearance = standardAppearance
            navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
            navigationBar.compactAppearance = standardAppearance
        }
    }
    
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
                
                DispatchQueue.main.async {
                    self.startOnboardingIfPossible()
                }

            } catch {
                print("loadData error:", error)
                await MainActor.run { self.spinner.stopAnimating() }
            }
        }
    }
    
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
        styleTableCell(cell)

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
            titleLabel.text = "\(sectionTitles[0])"
            subtitleLabel.text = "\(pending) pending · \(completed) completed"
        } else {
            titleLabel.text = "\(sectionTitles[1])"
//            subtitleLabel.text = "\(logSummaries.count) activities logged"
        }

        [titleLabel, subtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        return headerView
    }

    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        50
    }

    override func tableView(_ tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat {
        8
    }

    override func tableView(_ tableView: UITableView,
                            viewForFooterInSection section: Int) -> UIView? {
        // Return an empty view so the grouped style doesn't add its default footer
        UIView()
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
            journalVC.isPatientSide = true
        }

        if segue.identifier == "timerSegue",
           let graphVC = segue.destination as? GraphCollectionViewController {

            if indexPath.section == 0 {
                let item = todayItems[indexPath.row]
                graphVC.activity = item.activity
                graphVC.logs = item.logs
                graphVC.assigned = item.assignment
            } else {
                let item = logSummaries[indexPath.row]
                graphVC.activity = item.activity
                graphVC.logs = item.logs
                graphVC.assigned = item.assignment
            }

            graphVC.patient = patient
        }
    }
    
    private func isBreathingActivity(_ item: TodayActivityItem) -> Bool {
        let combined = "\(item.activity.name) \(item.assignment.doctorNote ?? "") \(item.activity.iconName)".lowercased()

        // Meditation should always use the timer workflow.
        if combined.contains("meditat") {
            return false
        }

        return combined.contains("breath")
            || combined.contains("4-7-8")
            || combined.contains("pranayama")
            || combined.contains("box breathing")
    }
    
    private func presentBreathingController(for item: TodayActivityItem) {
        let storyboard = UIStoryboard(name: "breathcircle", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? breatheCircleViewController else {
            performSegue(withIdentifier: "Timer", sender: item)
            return
        }
        vc.activityItem = item
        vc.patient = patient
        vc.onSave = { [weak self] in self?.loadData() }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .automatic
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 32
        }
        present(nav, animated: true)
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
                prepare: { [weak self] in
                    self?.scrollToFirstLogForOnboarding()
                },
                targetProvider: { [weak self] in
                    guard let self, let indexPath = firstLogIndexPath else { return nil }
                    return (self.tableView.cellForRow(at: indexPath) as? TodayTableViewCell)?.cardView
                }
            )
        ]
    }

    private func scrollToFirstLogForOnboarding() {
        let indexPath = IndexPath(row: 0, section: 1)
        guard tableView.numberOfSections > indexPath.section,
              tableView.numberOfRows(inSection: indexPath.section) > indexPath.row else { return }

        tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        tableView.layoutIfNeeded()
    }

    // MARK: - ✅ Onboarding Starter

    private func startOnboardingIfPossible() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.onboardingSequence?.startIfNeeded()
        }
    }
}
