//
//  HomeCollectionViewController.swift
//  wellSync
//
//  Created by Pranjal on 04/02/26.
//

import UIKit

class HomeCollectionViewController: UICollectionViewController {
    var patients: [Patient] = []
    var sessionCountByPatient: [UUID: Int] = [:]
    var appointments: [AppointmentWithPatient] = []
    var selectedAppointment: AppointmentWithPatient?
    var viewModel: AccessSupabase?
    var doctor: Doctor?{
        didSet{
            guard doctor != nil else { return }
            loadPatients()
            loadAppointments()
        }
    }
    @IBOutlet weak var ellipsisButtonTapped: UIBarButtonItem!
    @IBOutlet weak var addPatientButtonTapped: UIBarButtonItem!
    var selectedFilter: FilterType = .all
    var selectedPatient: Patient?
    
    let spinner = UIActivityIndicatorView(style: .large)
    private var onboardingSequence: FeatureOnboardingSequence?
    private var hasLoadedAppointmentsOnce = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        collectionView.backgroundColor = .clear
//        applyGradientBackground()
        spinner.center = view.center
        view.addSubview(spinner)
        viewModel = AccessSupabase.shared
        setupCollectionView()
        self.collectionView.collectionViewLayout = createLayout()
        setupMenu()
        onboardingSequence = FeatureOnboardingSequence(
            viewController: self,
            storageKey: "doctor_home"
        ) { [weak self] in
            self?.makeOnboardingSteps() ?? []
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPatients()
        loadAppointments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startOnboardingIfPossible()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // fixes gradient frame on all device sizes
        view.layer.sublayers?
            .compactMap { $0 as? CAGradientLayer }
            .first?
            .frame = view.bounds
    }

    
//    private func applyGradientBackground() {
//        let gradient = CAGradientLayer()
//
//        gradient.colors = [
//            UIColor(red: 0.91, green: 0.98, blue: 0.95, alpha: 1.0).cgColor,
//               UIColor(red: 0.97, green: 1.00, blue: 0.999, alpha: 1.0).cgColor
//        ]
//
//        gradient.startPoint = CGPoint(x: 0.5, y: 0.0) // TOP
//        gradient.endPoint   = CGPoint(x: 0.5, y: 1.0) // BOTTOM
//
//        gradient.frame = view.bounds
//
//        view.layer.insertSublayer(gradient, at: 0)
//    }
    
    func loadAppointments() {
        guard let id = self.doctor?.docID else { return }
        spinner.startAnimating()

        Task {
            do {
                try await viewModel?.markMissedAppointments(for: id)
                let data = try await viewModel?.fetchTodayAppointmentsWithPatients(doctorID: id) ?? []
               let patientIDs = self.patients.map { $0.patientID }
                let counts = try await viewModel?.fetchCompletedSessionCounts(patientIDs: patientIDs) ?? [:]
                await MainActor.run {
                    self.appointments = data
                    self.sessionCountByPatient = counts
                    self.categorizeAppointments()
                    self.hasLoadedAppointmentsOnce = true
                    self.collectionView.reloadData()
                    self.updateEmptyState()
                    self.startOnboardingIfPossible()
                    self.spinner.stopAnimating()
                }
            } catch {
                print(error)
                await MainActor.run {
                    self.hasLoadedAppointmentsOnce = true
                    self.collectionView.reloadSections(IndexSet(integer: 2))
                    self.spinner.stopAnimating()
                }
            }
        }
    }
    func loadPatients() {
        guard let id = self.doctor?.docID else { return }

        Task {
            do {
                let data = try await viewModel?.fetchPatients(for: id) ?? []

                await MainActor.run {
                    self.patients = data
                    self.collectionView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }
    
    
    var upcoming: [AppointmentWithPatient] = []
    var missed: [AppointmentWithPatient] = []
    var done: [AppointmentWithPatient] = []
    private func categorizeAppointments() {
        upcoming.removeAll()
        missed.removeAll()
        done.removeAll()

        for item in appointments {
            switch item.status {
            case .completed:
                done.append(item)

            case .scheduled:
                upcoming.append(item)

            case .missed:
                missed.append(item)
            }
        }
    }
    func filteredAppointments() -> [AppointmentWithPatient] {
        switch selectedFilter {
        case .all:
            return upcoming + missed + done
        case .upcoming:
            return upcoming
        case .missed:
            return missed
        case .done:
            return done
        }
    }

    
    private func setupCollectionView() {

        collectionView.register(
            UINib(nibName: "PatientCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "PatientCell"
        )

        collectionView.register(
            UINib(nibName: "TopSectionCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "TopCell"
        )

        collectionView.register(
            UINib(nibName: "SectionHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        
        collectionView.register(
            UINib(nibName: "FilterCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "FilterCell"
        )

        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "HomeEmptyStateCell"
        )
    }
    func setupMenu() {

      
        let profile = UIAction(title: "Profile",image: UIImage(systemName: "person")) { _ in
            self.openProfile()
        }

        let allPatients = UIAction(title: "All Patients",
                                    image: UIImage(systemName: "person.3")) { _ in
            self.openAllPatients()
        }

        let appointments = UIAction(title: "Appointments",
                                image: UIImage(systemName: "calendar")) { _ in
            self.openAppointments()
        }

        let settings = UIAction(title: "Settings",
                                image: UIImage(systemName: "gearshape")) { _ in
            self.openSettings()
        }

        let menu = UIMenu(title: "", children: [
            profile,
            allPatients,
            appointments,
            settings
        ])

        ellipsisButtonTapped.menu = menu
//        ellipsisButtonTapped.showsMenuAsPrimaryAction = true
    }
    func openAllPatients() {

        let storyboard = UIStoryboard(name: "AllPatient", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "AllPatientViewController"
        ) as! AllPatientCollectionViewController
        vc.doctor = doctor
        navigationController?.pushViewController(vc, animated: true)
    }

    func openAppointments() {

        let storyboard = UIStoryboard(name: "Appointment", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "appointment"
        ) as! AppointmentCollectionViewController   // ✅ cast

        vc.doctorID = doctor?.docID   // 🔥 THIS IS THE FIX

        navigationController?.pushViewController(vc, animated: true)
    }

    func openProfile() {
        let storyboard = UIStoryboard(name: "Doctor_Profile", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "doctorProfile"
        )

        navigationController?.pushViewController(vc, animated: true)
    }

    func openSettings() {
        let storyboard = UIStoryboard(name: "DoctorSetting", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "docSetting"
        )
        navigationController?.pushViewController(vc, animated: true)
    }



    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {

        if section == 0 {
            return 2
        } else if section == 1{
            return 1
        } else {
            guard hasLoadedAppointmentsOnce else { return 0 }
            return max(filteredAppointments().count, 1)
        }
    }

}
extension HomeCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TopCell",
                for: indexPath
            ) as! TopSectionCollectionViewCell

            if indexPath.row == 0 {
                    cell.configure(title: "Total Patients", subtitle: "\(patients.count)")
                    
            } else {
                cell.configure(title: "Today's Session", subtitle: "\(upcoming.count+done.count+missed.count)")
            }

            style(cell)
            return cell
        }
        
        if indexPath.section == 1 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "FilterCell",
                    for: indexPath
                ) as! FilterCollectionViewCell

                cell.configure(
                    allCount: upcoming.count + missed.count + done.count,
                    upcomingCount: upcoming.count,
                    missedCount: missed.count,
                    doneCount: done.count
                )
                cell.onFilterSelected = { [weak self] filter in
                    guard let self = self else { return }
                    self.selectedFilter = filter
                    self.collectionView.reloadData()
                }

                return cell
            }
        if filteredAppointments().isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HomeEmptyStateCell",
                for: indexPath
            )
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            let empty = EmptyStateCardView(
                title: "No appointment today",
                subtitle: "No sessions are scheduled for today yet.",
                iconSystemName: "person.2.slash"
            )
            cell.contentView.addSubview(empty)
            NSLayoutConstraint.activate([
                empty.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                empty.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                empty.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                empty.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PatientCell",
            for: indexPath
        ) as! PatientCollectionViewCell

        let item = filteredAppointments()[indexPath.row]
        let patient = item.patient
        let count = sessionCountByPatient[patient.patientID] ?? 0
        cell.configureCell(with: patient, status: item.status, sessionCount: count)
        cell.onAction = { [weak self] action, sourceView in
            guard let self = self else { return }

            switch action {

            case .nextSession:
                self.selectedPatient = patient
                self.selectedAppointment = item
                self.performSegue(
                    withIdentifier: "PatientDetail",
                    sender: PatientNavigationIntent.nextSession
                )

            case .reschedule:
                self.selectedPatient = patient
                self.selectedAppointment = item
                self.performSegue(
                    withIdentifier: "PatientDetail",
                    sender: PatientNavigationIntent.reschedule
                )
                case .addNote:
                    self.addSessionNote(for: patient)

                case .markDone:
                    self.showMarkAsDoneAlert(for: item, at: indexPath)

                case .notify:
                    self.notifyPatient(for: item)
                }
            }
            style(cell)
            return cell
    }
}
extension HomeCollectionViewController {
    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              indexPath.section == 1 else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header",
            for: indexPath
        ) as! SectionHeaderView
        header.configure(withTitle: "Patients")
        return header
    }


    func applyShadow(cell: UICollectionViewCell) {
        cell.contentView.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.25
        cell.layer.shadowRadius  = 4
        cell.layer.shadowOffset  = CGSize(width: 0, height: 4)
        cell.layer.masksToBounds = false
    }

    func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            return self.sectionLayout(for: sectionIndex)
        }
    }

    func sectionLayout(for section: Int) -> NSCollectionLayoutSection {

        switch section {
        case 0:
            return topSectionLayout()

        case 1:
            return filterSectionLayout()
            
        case 2:
            return patientSectionLayout()
        default:
            return patientSectionLayout()
        }
    }

    func topSectionLayout() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(120)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        group.interItemSpacing = .fixed(10)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        return section
    }

    func patientSectionLayout() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(170)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        group.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0)

        return section
    }
    
    func filterSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading
        )
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "allPatientSegue", sender: self)
            return
        }
        if indexPath.section == 2 {
            guard !filteredAppointments().isEmpty else { return }
            let item = filteredAppointments()[indexPath.row]
            selectedPatient = item.patient
            selectedAppointment = item
            performSegue(withIdentifier: "PatientDetail", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PatientDetail" {
            let destinationVC = segue.destination as! PatientDetailCollectionViewController
            destinationVC.patient = selectedPatient
            destinationVC.selectedAppointment = selectedAppointment
            
            if let intent = sender as? PatientNavigationIntent {
                   destinationVC.actionIntent = intent
               }
        }
        if segue.identifier == "allPatientSegue" {
            let AllPatientVC = segue.destination as! AllPatientCollectionViewController
            AllPatientVC.doctor = doctor
        }
        if segue.identifier == "DoctorActionToNotes",
               let vc = segue.destination as? SessionNoteCollectionViewController,
               let patient = sender as? Patient {
                
                vc.patient = patient
            }
        if segue.identifier == "AddPatientSegue" {
            
            if let nav = segue.destination as? UINavigationController,
               let destinationVC = nav.topViewController as? AddPatientTableViewController {
                destinationVC.doctor = doctor
                destinationVC.onDismiss = { [weak self] in
                    guard let self = self else { return }

                    guard let newPatient = destinationVC.patient,
                              let doctorID = self.doctor?.docID else { return }
                    
                    Task {
                           do {
                               let appointment = Appointment(
                                   appointmentId: nil,
                                   patientId: newPatient.patientID,
                                   doctorId: doctorID,
                                   scheduledAt: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!,
                                   status: .scheduled
                               )
                               _ = try await self.viewModel?.createAppointment(appointment)
                               await MainActor.run {
                                   self.loadPatients()
                                   self.loadAppointments()
                               }

                           } catch {
                               print("Error creating appointment:", error)
                           }
                       }
                }
            }
        }
    }
}
extension HomeCollectionViewController{
    private func updateEmptyState() {
        guard isViewLoaded else { return }
        // collectionView.backgroundView = nil
        collectionView.reloadSections(IndexSet(integer: 2))
    }
    
    private func makeOnboardingSteps() -> [FeatureSpotlightStep] {
        collectionView.layoutIfNeeded()
        return [
            FeatureSpotlightStep(
                title: "Active patients",
                message: "Quick view of your current patient load.",
                placement: .below,
                targetProvider: { [weak self] in self?.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) }
            ),
            FeatureSpotlightStep(
                title: "Today’s sessions",
                message: "Shows the total sessions scheduled for today.",
                placement: .below,
                targetProvider: { [weak self] in self?.collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) }
            ),
            FeatureSpotlightStep(
                title: "Patients for today",
                message: "Patients scheduled today appear in this area.",
                placement: .below,
                targetProvider: { [weak self] in
                    guard let self else { return nil }
                    if let header = self.collectionView.supplementaryView(
                        forElementKind: UICollectionView.elementKindSectionHeader,
                        at: IndexPath(item: 0, section: 1)
                    ) {
                        return header
                    }
                    return self.collectionView.cellForItem(at: IndexPath(item: 0, section: 2))
                }
            ),
            FeatureSpotlightStep(
                title: "Add patient",
                message: "Use this control to add a new patient profile.",
                placement: .below,
                targetProvider: { [weak self] in
                    self?.addPatientButtonTapped.value(forKey: "view") as? UIView
                }
            )
        ]
    }
    
    private func startOnboardingIfPossible() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.onboardingSequence?.startIfNeeded()
        }
    }
    
    func notifyPatient(for item: AppointmentWithPatient) {
        let confirmAlert = UIAlertController(
            title: "Notify Patient",
            message: "Send a session reminder to \(item.patient.name)?",
            preferredStyle: .alert
        )

        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            let doctorName = self?.doctor?.name ?? "your doctor"
            Task { @MainActor in
                let now = Date()
                let tenMinutesFromNow = now.addingTimeInterval(10 * 60)
                let isWithinTenMinutes = item.scheduledAt <= tenMinutesFromNow

                let body: String
                if isWithinTenMinutes {
                    body = "Session with \(doctorName) starts in 10 minutes."
                } else {
                    let formatter = DateFormatter()
                    formatter.locale = Locale.current
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .short
                    let scheduleText = formatter.string(from: item.scheduledAt)
                    body = "Your session with \(doctorName) is scheduled on \(scheduleText)."
                }

                let dashboardSaved: Bool
                let pushDelivery: PushNotificationService.DeliveryResult

                do {
                    _ = try await AccessSupabase.shared.createPatientNotification(
                        patientID: item.patient.patientID,
                        doctorID: item.doctorId,
                        title: "Session Reminder",
                        body: body,
                        kind: "manual_notify"
                    )
                    dashboardSaved = true
                } catch {
                    dashboardSaved = false
                    print("Dashboard notification save failed: \(error.localizedDescription)")
                }

                pushDelivery = await PushNotificationService.shared.sendPatientRemotePush(
                    patientID: item.patient.patientID,
                    title: "Session Reminder",
                    body: body,
                    kind: "manual_notify"
                )

                let didSend = dashboardSaved || pushDelivery.success
                let successMessage = dashboardSaved
                    ? "A reminder will appear in \(item.patient.name)'s patient dashboard."
                    : "A reminder was sent to \(item.patient.name)'s notification bar."

                let sentAlert = UIAlertController(
                    title: didSend ? "Notification Sent" : "Send Failed",
                    message: didSend
                    ? successMessage
                    : (pushDelivery.message ?? "Could not send reminder right now. Please try again."),
                    preferredStyle: .alert
                )
                sentAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(sentAlert, animated: true)
            }
        })

        present(confirmAlert, animated: true)
    }

    func addSessionNote(for patient: Patient) {
        performSegue(withIdentifier: "DoctorActionToNotes", sender: patient)
    }
    
    func showMarkAsDoneAlert(for item: AppointmentWithPatient, at indexPath: IndexPath) {
        
        let alert = UIAlertController(
            title: "Mark as Done",
            message: "You are marking \(item.patient.name)'s session as completed.",
            preferredStyle: .alert
        )
        
        let confirm = UIAlertAction(title: "OK", style: .default) { _ in
            
            self.showCheckmarkAnimation(at: indexPath)
            Task {
                do {
                    let updatedAppointment = Appointment(
                                        appointmentId: item.appointmentId,
                                        patientId: item.patientId,
                                        doctorId: item.doctorId,
                                        scheduledAt: item.scheduledAt,
                                        status: .completed
                                    )
                    
                    _ = try await AccessSupabase.shared.updateAppointment(updatedAppointment)
                    try await Task.sleep(nanoseconds: 1_200_000_000)
                    await MainActor.run {
                        self.loadAppointments()
                    }
                    
                } catch {
                    print("Error:", error)
                }
            }
        }
        confirm.setValue(UIColor.systemGreen, forKey: "titleTextColor")
        alert.addAction(confirm)
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alert, animated: true)
    }
    
    
    private func showCheckmarkAnimation(at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // — Ripple ring —
        let ripple = UIView()
        ripple.layer.cornerRadius = 30
        ripple.layer.borderWidth  = 2
        ripple.layer.borderColor  = UIColor.systemGreen.cgColor
        ripple.frame              = CGRect(x: 0, y: 0, width: 60, height: 60)
        ripple.center             = cell.contentView.center
        ripple.alpha              = 0.8
        cell.contentView.addSubview(ripple)

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            ripple.transform = CGAffineTransform(scaleX: 2.8, y: 2.8)
            ripple.alpha     = 0
        } completion: { _ in
            ripple.removeFromSuperview()
        }

        // — Checkmark icon with spring bounce —
        let checkmark = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkmark.tintColor                          = .systemGreen
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        checkmark.alpha                              = 0
        checkmark.transform                          = CGAffineTransform(scaleX: 0.3, y: 0.3)
        cell.contentView.addSubview(checkmark)

        NSLayoutConstraint.activate([
            checkmark.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            checkmark.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 52),
            checkmark.heightAnchor.constraint(equalToConstant: 52)
        ])

        // Pop in with spring
        UIView.animate(withDuration: 0.4, delay: 0.05,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.8) {
            checkmark.alpha     = 1
            checkmark.transform = .identity
        } completion: { _ in

            // Hold for a moment, then fade + slide up
            UIView.animate(withDuration: 0.3, delay: 0.5,
                           options: .curveEaseIn) {
                checkmark.alpha     = 0
                checkmark.transform = CGAffineTransform(translationX: 0, y: -10)
            } completion: { _ in
                checkmark.removeFromSuperview()
            }
        }
    }
}
