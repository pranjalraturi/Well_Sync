//
//  PatientDetailCollectionViewController.swift
//  wellSync
//
//  Created by Rishika Mittal on 06/02/26.
//

import UIKit

class PatientDetailCollectionViewController: UICollectionViewController{

    @IBOutlet weak var PatientProfileCollectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var patient: Patient?
    var selectedAppointment: AppointmentWithPatient?
    var sessionNotes : [SessionNote] = []
    // ✅ ADD THIS PROPERTY
    var moodLogs: [MoodLog] = []
    var patientAppointments: [Appointment] = []
    var actionIntent: PatientNavigationIntent?
    private var onboardingSequence: FeatureOnboardingSequence?
    func loadMoodLogs() {
        guard let patientID = patient?.patientID else { return }

        Task {
            do {
                let logs = try await AccessSupabase.shared.fetchMoodLogs(patientID: patientID)
                await MainActor.run {
                    self.moodLogs = logs.sorted{$0.date < $1.date}
                }
            } catch {
                print("❌ Mood logs error:", error)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
        let Layout = generateLayout()
        PatientProfileCollectionView.setCollectionViewLayout(Layout, animated: true)

        PatientProfileCollectionView.delegate = self
        PatientProfileCollectionView.dataSource = self

        updateDoneButtonColor()
        loadSessionNotes()
        loadPatientAppointments()
        loadMoodLogs()
        
        onboardingSequence = FeatureOnboardingSequence(
            viewController: self,
            storageKey: "doctor_patient_detail"
        ) { [weak self] in
            self?.makeOnboardingSteps() ?? []
        }

        if let appointment = selectedAppointment {
            let isToday = Calendar.current.isDateInToday(appointment.scheduledAt)
            doneButton.isEnabled = isToday
        } else {
            doneButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSessionNotes()
        loadPatientAppointments()
    }
    
    private var hasTriggeredIntent = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startOnboardingIfPossible()

        guard let intent = actionIntent,
              !hasTriggeredIntent else { return }

        hasTriggeredIntent = true
        actionIntent = nil

        triggerCalendar(for: intent)
    }
    
    func loadPatientAppointments() {
        guard let patientID = patient?.patientID else { return }
        Task {
            do {
                let appts = try await AccessSupabase.shared
                    .fetchAppointments(patientID: patientID)
                await MainActor.run {
                    self.patientAppointments = appts
                    self.PatientProfileCollectionView.reloadData()
                    self.startOnboardingIfPossible()
                }
            } catch {
                print("❌ Error loading appointments: \(error)")
            }
        }
    }
    
    func registerCells(){
        PatientProfileCollectionView.register(UINib(nibName: "ProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProfileCollectionViewCell")
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        return 5
     }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let profilecell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewCell", for: indexPath) as! ProfileCollectionViewCell
            profilecell.configureCell(with: patient!, appointments: patientAppointments)
            profilecell.delegate = self
            return profilecell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as! DetailCollectionViewCell
        cell.configure(index: indexPath.row)
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "mood",
           let vc = segue.destination as? MoodAnalysisCollectionViewController {
            vc.currPatient = self.patient
            vc.moodLogs = self.moodLogs
            vc.isPreloaded = true
        }

        if segue.identifier == "activity" {
            let destination = segue.destination as! DoctorActivityStatusCollectionViewController
            destination.patient = patient
        }

        if segue.identifier == "sessionNotes",
           let vc = segue.destination as? SessionNoteCollectionViewController {
            vc.patient = self.patient
            vc.sessions = self.sessionNotes
        }

        if segue.identifier == "case",
           let vc = segue.destination as? CaseHistoryViewController {
            vc.patient = self.patient
            vc.sessions = self.sessionNotes
        }

        if segue.identifier == "vitals" {
            let destination = segue.destination as! VitalsCollectionViewController
            destination.patient = self.patient
        }
    }
}


extension PatientDetailCollectionViewController{
    
    func generateLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { [weak self]
            sectionIndex, environment -> NSCollectionLayoutSection in
            
            guard let self = self else {
                return self!.generateSectionForDetailCells()
            }
            
            switch sectionIndex {
            case 0:
                return self.generateSectionForProfile()
            default:
                return self.generateSectionForDetailCells()
            }
        }
        
        
        layout.register(RoundedBackgroundCollectionReusableView.self,
                        forDecorationViewOfKind: "background")
        
        return layout
    }
    func cardStyle(cell:UICollectionViewCell){
        cell.backgroundColor = .systemBackground
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.08
        cell.layer.shadowRadius = 10
        cell.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    func generateSectionForProfile() -> NSCollectionLayoutSection{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(160))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(160))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 32, trailing: 0)
        return section
    }
    
    func generateSectionForDetailCells() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(80)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(80)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 4,
            leading: 28,
            bottom: 4,
            trailing: 28
        )
        
        let backgroundItem = NSCollectionLayoutDecorationItem.background(
            elementKind: "background"
        )
        
        backgroundItem.contentInsets = NSDirectionalEdgeInsets(
            top: -8,
            leading: 16,
            bottom: -8,
            trailing: 16
        )
        
        
        section.decorationItems = [backgroundItem]
        return section
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section
        {
        case 1:
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "sessionNotes", sender: nil)
            case 1:
                performSegue(withIdentifier: "mood", sender: nil)
            case 2:
                performSegue(withIdentifier: "activity", sender: nil)
            case 3:
                performSegue(withIdentifier: "vitals", sender: nil)
            case 4:
                performSegue(withIdentifier: "case", sender: nil)
            default:
                break
            }
        default:
            break
            
        }
    }
    
    func loadSessionNotes(){
        Task{
            guard let patientID = patient?.patientID else { return }
            do{
                let fetchedNotes = try await AccessSupabase.shared.fetchSessionNotes(patientID: patientID)
                await MainActor.run{
                    self.sessionNotes = fetchedNotes
                    self.startOnboardingIfPossible()
                }
            }catch{
                print("Session Notes can't be fetched")
            }
        }
    }
    
    private func makeOnboardingSteps() -> [FeatureSpotlightStep] {
        collectionView.layoutIfNeeded()
        let profileCellProvider: () -> ProfileCollectionViewCell? = { [weak self] in
            self?.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? ProfileCollectionViewCell
        }
        return [
            FeatureSpotlightStep(
                title: "Patient profile overview",
                message: "Review patient identity and clinical basics here.",
                placement: .below,
                targetProvider: { [weak self] in
                    self?.collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
                }
            ),
            FeatureSpotlightStep(
                title: "Call patient",
                message: "Tap to contact the patient directly.",
                placement: .below,
                targetProvider: {
                    profileCellProvider()?.callButton
                }
            ),
            FeatureSpotlightStep(
                title: "Schedule appointment",
                message: "Set or update the next appointment quickly.",
                placement: .below,
                targetProvider: {
                    profileCellProvider()?.calendarButton
                }
            ),
            FeatureSpotlightStep(
                title: "Session notes",
                message: "Open notes to review past sessions and add new entries.",
                placement: .below,
                targetProvider: { [weak self] in
                    self?.collectionView.cellForItem(at: IndexPath(item: 0, section: 1))
                }
            ),
            FeatureSpotlightStep(
                title: "Mood analysis",
                message: "Track mood distribution and trends over time.",
                placement: .below,
                targetProvider: { [weak self] in
                    self?.collectionView.cellForItem(at: IndexPath(item: 1, section: 1))
                }
            ),
            FeatureSpotlightStep(
                title: "Activity status",
                message: "Monitor current and previous activity completion.",
                placement: .below,
                targetProvider: { [weak self] in
                    self?.collectionView.cellForItem(at: IndexPath(item: 2, section: 1))
                }
            ),
            FeatureSpotlightStep(
                title: "Health stats",
                message: "Review sleep and steps trends for clinical tracking.",
                placement: .above,
                prepare: { [weak self] in
                    self?.collectionView.scrollToItem(at: IndexPath(item: 3, section: 1), at: .centeredVertically, animated: false)
                    self?.collectionView.layoutIfNeeded()
                },
                targetProvider: { [weak self] in
                    self?.collectionView.cellForItem(at: IndexPath(item: 3, section: 1))
                }
            ),
            FeatureSpotlightStep(
                title: "Patient history",
                message: "Open reports and treatment timeline records.",
                placement: .above,
                prepare: { [weak self] in
                    self?.collectionView.scrollToItem(at: IndexPath(item: 4, section: 1), at: .centeredVertically, animated: false)
                    self?.collectionView.layoutIfNeeded()
                },
                targetProvider: { [weak self] in
                    self?.collectionView.cellForItem(at: IndexPath(item: 4, section: 1))
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
extension PatientDetailCollectionViewController{
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem){
        guard let patient = self.patient else { return }
        guard let selectedAppointment = self.selectedAppointment else { return }
        if selectedAppointment.status == .completed{
            updateDoneButtonColor()
            showAlreadyDone()
            return
        }
        if hasSessionNote(){
            handleAlertFlow(patient)
            return
        }
        let alert = UIAlertController(title: "Session Note", message: "Add the session Note?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Later", style: .default, handler: { _ in
                self.handleAlertFlow(patient)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            present(alert, animated: true)
        }
    
    
    func hasSessionNote() -> Bool {
        let calendar = Calendar.current
        return sessionNotes.contains {
            calendar.isDateInToday($0.date)
        }
    }
    
    func handleAlertFlow(_ patient: Patient) {
        let calendar = Calendar.current
        
        // Check if a future scheduled appointment already exists
        let hasFutureAppointment = patientAppointments.contains {
            $0.status == .scheduled &&
            $0.scheduledAt > Date() &&
            !calendar.isDateInToday($0.scheduledAt)
        }
        
        if hasFutureAppointment {
            // Next session already booked — go straight to marking done
            showThirdAlert()
        } else {
            // No future appointment — ask doctor to schedule one
            showSecondAlert()
        }
    }
    func showSecondAlert() {
        let alert = UIAlertController(title: "Next Session Date", message: "Schedule the next session", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Later", style: .default, handler: { _ in
            self.showThirdAlert()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alert, animated: true)
    }
    func showThirdAlert() {
        let alert = UIAlertController(title: "Session Completed", message:  "Marking this session as Done", preferredStyle: .alert)
        let done = UIAlertAction(title: "OK", style: .default){_ in
            guard var patient = self.patient else {return}
            Task{
                do{
                    if let selected = self.selectedAppointment {

                        let updated = Appointment(
                            appointmentId: selected.appointmentId,
                            patientId: selected.patientId,
                            doctorId: selected.doctorId,
                            scheduledAt: selected.scheduledAt,
                            status: .completed
                        )

                        try await AccessSupabase.shared.updateAppointment(updated)
                        self.selectedAppointment = AppointmentWithPatient(
                            appointmentId: selected.appointmentId,
                            patientId: selected.patientId,
                            doctorId: selected.doctorId,
                            scheduledAt: selected.scheduledAt,
                            status: .completed,
                            patient: patient
                        )

                    } else {
                        print("No selected appointment")
                    }
                    patient.previousSessionDate = Date()
                    patient.sessionStatus = true
                    try await AccessSupabase.shared.updatePatient(patient)
                    
                    await MainActor.run {
                        self.patient = patient
                        self.updateDoneButtonColor()
//                                        self.PatientProfileCollectionView?.reloadData()
                        self.loadPatientAppointments()
                    }
                }catch{
                    print("Completion Error: \(error)")
                }
            }
        }
        done.setValue(UIColor.systemGreen, forKey: "titleTextColor")
        alert.addAction(done)
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alert, animated: true)
    }
    func showAlreadyDone(){
        let alert = UIAlertController(title: "Session Already Done", message: "This session has already been marked as Done", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func updateDoneButtonColor(){
        if selectedAppointment?.status == .completed {
                doneButton.tintColor = .systemGreen
            }
    }
}


extension PatientDetailCollectionViewController: ProfileCellDelegate {
    func callButtonTapped() {
        Task {
            await callPatient()
        }
    }

    private func callPatient() async {
        guard let patientID = patient?.patientID else {
            showAlert(
                title: "Patient unavailable",
                message: "Could not find this patient record. Please reopen the patient profile and try again."
            )
            return
        }

        do {
            let phoneNumber = try await AccessSupabase.shared.fetchPatientContact(patientID: patientID)
            guard let sanitizedPhoneNumber = sanitizedPhoneNumber(from: phoneNumber) else {
                showAlert(
                    title: "Phone number missing",
                    message: "This patient does not have a phone number saved."
                )
                return
            }

            openPhoneApp(with: sanitizedPhoneNumber)
        } catch {
            showAlert(
                title: "Could not fetch phone number",
                message: "Please check your connection and try again."
            )
        }
    }

    private func sanitizedPhoneNumber(from value: String?) -> String? {
        guard let value else { return nil }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let digits = trimmed.filter { $0.isNumber }
        let prefix = trimmed.hasPrefix("+") ? "+" : ""
        let sanitized = prefix + digits

        return sanitized.isEmpty ? nil : sanitized
    }

    private func openPhoneApp(with phoneNumber: String) {
        guard let url = URL(string: "tel://\(phoneNumber)") else {
            showAlertOnMain(
                title: "Invalid phone number",
                message: "This phone number could not be used for a call."
            )
            return
        }

        guard UIApplication.shared.canOpenURL(url) else {
            showAlertOnMain(
                title: "Calls unavailable",
                message: "This device cannot open the Phone app."
            )
            return
        }

        UIApplication.shared.open(url)
    }

    private func showAlert(title: String, message: String) {
        showAlertOnMain(title: title, message: message)
    }

    private func showAlertOnMain(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func calendarButtonTapped(from view: UIView){
        showScheduleAlert(sourceView: view)
    }
    func showScheduleAlert(sourceView: UIView){
        let popoverVC = ScheduleViewController()
        popoverVC.patient = self.patient
        popoverVC.scheduleDate = self.selectedAppointment?.scheduledAt
        
        
        popoverVC.modalPresentationStyle = .popover
        
        popoverVC.preferredContentSize = CGSize(width: 300, height: 500)
        
        if let popover = popoverVC.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
            popover.permittedArrowDirections = .any
            popover.delegate = self
        }
        
        popoverVC.onScheduleCancelled = { [weak self] in
            guard let self = self, let patient = self.patient else { return }
            
            Task {
                do {
                    let appointments = try await AccessSupabase.shared
                        .fetchAppointments(patientID: patient.patientID)
                    
                    if let apptToDelete = appointments.first(where: {
                        $0.status == .scheduled &&
                        !Calendar.current.isDateInToday($0.scheduledAt)
                    }), let id = apptToDelete.appointmentId {
                        try await AccessSupabase.shared.deleteAppointment(
                            id: id,
                            patientID: patient.patientID
                        )
                        print("✅ Appointment deleted")
                    }
                    
                    try await AccessSupabase.shared.clearNextSessionDate(patientID: patient.patientID)
                    print("✅ Next session date cleared")
                    await MainActor.run {
                        self.patient?.nextSessionDate = nil
                        self.loadPatientAppointments()
                        self.PatientProfileCollectionView.reloadData()
                    }
                    
                } catch {
                    print("❌ Error cancelling appointment: \(error)")
                }
            }
        }
        popoverVC.onScheduleConfirmed = { [weak self] selectedFullDate in
            guard let self = self, var patient = self.patient else { return }

            Task {
                do {
                    let calendar = Calendar.current

                    // ✅ Safety check: never create a duplicate for the same day
                    let existingSameDay = self.patientAppointments.first {
                        calendar.isDate($0.scheduledAt, inSameDayAs: selectedFullDate)
                    }

                    if let existing = existingSameDay, let existingID = existing.appointmentId {
                        // ✅ Already has one today (possibly missed) → UPDATE instead of INSERT
                        let updatedAppt = Appointment(
                            appointmentId: existingID,
                            patientId: existing.patientId,
                            doctorId: existing.doctorId,
                            scheduledAt: selectedFullDate,
                            status: .scheduled
                        )
                        try await AccessSupabase.shared.updateAppointment(updatedAppt)
                        print("✅ Existing appointment updated (confirm path, no duplicate)")
                    } else {
                        // ✅ No existing appointment → create new
                        let newAppointment = Appointment(
                            appointmentId: UUID(),
                            patientId: patient.patientID,
                            doctorId: patient.docID,
                            scheduledAt: selectedFullDate,
                            status: .scheduled
                        )
                        let created = try await AccessSupabase.shared.createAppointment(newAppointment)
                        print("✅ New appointment created: \(created.scheduledAt)")
                    }

                    patient.nextSessionDate = selectedFullDate
                    try await AccessSupabase.shared.updatePatient(patient)
                    print("✅ Patient next session date updated")

                    await MainActor.run {
                        self.patient = patient
                        self.loadPatientAppointments()
                        self.PatientProfileCollectionView.reloadData()
                    }

                } catch {
                    print("❌ Scheduling Error: \(error)")
                }
            }
        }
        
        popoverVC.onScheduleChange = { [weak self] newDate in
            guard let self = self, var patient = self.patient else { return }

            Task {
                do {
                    let calendar = Calendar.current

                    if let selected = self.selectedAppointment {
                        let oldID = selected.appointmentId

                        if calendar.isDate(selected.scheduledAt, inSameDayAs: newDate) {
                            // ✅ Same day — just changing time → UPDATE in place, no new row
                            let updatedAppt = Appointment(
                                appointmentId: oldID,
                                patientId: selected.patientId,
                                doctorId: selected.doctorId,
                                scheduledAt: newDate,
                                status: .scheduled
                            )
                            try await AccessSupabase.shared.updateAppointment(updatedAppt)
                            print("✅ Same-day reschedule: time updated")

                            self.selectedAppointment = AppointmentWithPatient(
                                appointmentId: oldID,
                                patientId: selected.patientId,
                                doctorId: selected.doctorId,
                                scheduledAt: newDate,
                                status: .scheduled,
                                patient: patient
                            )

                        } else {
                            // ✅ Different day → update in place so patient receives one reschedule notification
                            let updatedAppt = Appointment(
                                appointmentId: oldID,
                                patientId: selected.patientId,
                                doctorId: selected.doctorId,
                                scheduledAt: newDate,
                                status: .scheduled
                            )
                            let created = try await AccessSupabase.shared.updateAppointment(updatedAppt)
                            print("✅ Different-day reschedule: appointment updated")

                            self.selectedAppointment = AppointmentWithPatient(
                                appointmentId: created.appointmentId!,
                                patientId: created.patientId,
                                doctorId: created.doctorId,
                                scheduledAt: created.scheduledAt,
                                status: .scheduled,
                                patient: patient
                            )
                        }

                    } else {
                        // ✅ No selectedAppointment — check patientAppointments for a same-day conflict first
                        let existingSameDay = self.patientAppointments.first {
                            calendar.isDate($0.scheduledAt, inSameDayAs: newDate)
                        }

                        if let existing = existingSameDay, let existingID = existing.appointmentId {
                            // ✅ Same-day appointment exists → UPDATE time only, do NOT insert a new row
                            let updatedAppt = Appointment(
                                appointmentId: existingID,
                                patientId: existing.patientId,
                                doctorId: existing.doctorId,
                                scheduledAt: newDate,
                                status: .scheduled
                            )
                            try await AccessSupabase.shared.updateAppointment(updatedAppt)
                            print("✅ Existing same-day appointment time updated (no new row created)")

                            self.selectedAppointment = AppointmentWithPatient(
                                appointmentId: existingID,
                                patientId: existing.patientId,
                                doctorId: existing.doctorId,
                                scheduledAt: newDate,
                                status: .scheduled,
                                patient: patient
                            )

                        } else {
                            // ✅ Truly no appointment on this day → create fresh
                            let newAppointment = Appointment(
                                appointmentId: UUID(),
                                patientId: patient.patientID,
                                doctorId: patient.docID,
                                scheduledAt: newDate,
                                status: .scheduled
                            )
                            let created = try await AccessSupabase.shared.createAppointment(newAppointment)
                            print("✅ Fresh appointment created: \(created.scheduledAt)")

                            self.selectedAppointment = AppointmentWithPatient(
                                appointmentId: created.appointmentId!,
                                patientId: created.patientId,
                                doctorId: created.doctorId,
                                scheduledAt: created.scheduledAt,
                                status: .scheduled,
                                patient: patient
                            )
                        }
                    }

                    // ✅ Always sync the patient's next session date
                    patient.nextSessionDate = newDate
                    try await AccessSupabase.shared.updatePatient(patient)

                    await MainActor.run {
                        self.patient = patient
                        self.loadPatientAppointments()
                        self.PatientProfileCollectionView.reloadData()
                        
                    }

                } catch {
                    print("❌ Error rescheduling: \(error)")
                }
            }
        }
        present(popoverVC, animated: true)
    }
}
      

extension PatientDetailCollectionViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func triggerCalendar(for intent: PatientNavigationIntent) {

        let indexPath = IndexPath(item: 0, section: 0)
        guard let cell = PatientProfileCollectionView.cellForItem(at: indexPath) as? ProfileCollectionViewCell else {
            print("❌ Profile cell not found")
            return
        }
        guard let sourceView = cell.calendarButton else { return }
        if intent == .nextSession {
            self.selectedAppointment = nil
        }
        self.calendarButtonTapped(from: sourceView)
    }
}
