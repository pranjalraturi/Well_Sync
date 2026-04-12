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
    var sessionNotes : [SessionNote] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        let Layout = generateLayout()
        PatientProfileCollectionView.setCollectionViewLayout(Layout, animated: true)
        
        PatientProfileCollectionView.delegate = self
        PatientProfileCollectionView.dataSource = self
        
        updateDoneButtonColor()
        loadSessionNotes()
        if let sessionDate = patient?.nextSessionDate{
            let cal = Calendar.current
            
            if !cal.isDateInToday(sessionDate){
                doneButton.isEnabled = false
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
        return 6
     }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let profilecell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewCell", for: indexPath) as! ProfileCollectionViewCell
            profilecell.configureCell(with: patient!)
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
        if segue.identifier == "Summarised" {
            let destination     = segue.destination as! SummarisedReportTableViewController
            destination.patient = patient
        }
        if segue.identifier == "activity" {
            let destination     = segue.destination as! DoctorActivityStatusCollectionViewController
            destination.patient = patient
        }
        if segue.identifier == "sessionNotes",
               let vc = segue.destination as? SessionNoteCollectionViewController {
                vc.patient = self.patient   
            }
        if segue.identifier == "mood",let vc = segue.destination as? MoodAnalysisCollectionViewController{
            vc.currPatient = self.patient
        }
        if segue.identifier == "case",let vc = segue.destination as? CaseHistoryViewController{
            vc.patient = self.patient
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
            
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        return section
    }
    
    func generateSectionForDetailCells() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(70)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(70)
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
                performSegue(withIdentifier: "Summarised", sender: nil)
            case 2:
                performSegue(withIdentifier: "mood", sender: nil)
            case 3:
                performSegue(withIdentifier: "activity", sender: nil)
            case 4:
                performSegue(withIdentifier: "vitals", sender: nil)
            case 5:
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
                }
            }catch{
                    print("Session Notes can't be fetched")
            }
        }
    }
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem){
        guard let patient = self.patient else { return }
        
        if patient.sessionStatus == true{
            updateDoneButtonColor()
            showAlreadyDone()
            return
        }
        if hasSessionNote(){
            handleAlertFlow(patient)
        }
        let alert = UIAlertController(title: "Session Note", message: "Add the session Note?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Later", style: .default, handler: { _ in
                self.handleAlertFlow(patient)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            present(alert, animated: true)
        }
    
    func hasSessionNote() -> Bool{
        guard let sessionDate = patient?.nextSessionDate else { return false }
        let cal = Calendar.current
        guard cal.isDateInToday(sessionDate) else { return false }
        let sessionDay = cal.startOfDay(for: sessionDate)
        let hasNote = sessionNotes.contains {
                let noteDay = cal.startOfDay(for: $0.date)
                return noteDay == sessionDay
            }
        return hasNote
    }
    func handleAlertFlow(_ patient: Patient){
        let calendar = Calendar.current
            if let nextDate = patient.nextSessionDate,
               nextDate > Date(),
               !calendar.isDateInToday(nextDate) {
                showThirdAlert()
                
            } else {
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
                    let appts = try await AccessSupabase.shared.fetchAppointments(patientID: patient.patientID)
                    let calendar = Calendar.current
                    if var currentAppt = appts.first(where: {($0.status == .scheduled || $0.status == .missed) && calendar.isDateInToday($0.scheduledAt)}){
                        currentAppt.status = .completed
                      let x = try await AccessSupabase.shared.updateAppointment(currentAppt)
                        print(x)
                    }
                    
                    patient.previousSessionDate = Date()

                    patient.sessionStatus = true
                    
                    try await AccessSupabase.shared.updatePatient(patient)
                    
                    await MainActor.run {
                        self.patient = patient
                        self.updateDoneButtonColor()
//                                        self.PatientProfileCollectionView?.reloadData()
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
        if patient?.sessionStatus == true {
                doneButton.tintColor = .systemGreen
            }
    }
}


extension PatientDetailCollectionViewController: ProfileCellDelegate {
    func calendarButtonTapped(from view: UIView){
        showScheduleAlert(sourceView: view)
    }
    func showScheduleAlert(sourceView: UIView){
        let popoverVC = ScheduleViewController()
        popoverVC.patient = self.patient
        let originalDateBeforeChange = self.patient?.nextSessionDate
        popoverVC.scheduleDate = originalDateBeforeChange
       
        
        popoverVC.modalPresentationStyle = .popover
        
        popoverVC.preferredContentSize = CGSize(width: 300, height: 500)
        
        if let popover = popoverVC.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
            popover.permittedArrowDirections = .any
            popover.delegate = self
        }
        
        popoverVC.onScheduleCancelled = { [weak self] in
                guard let self = self, var patient = self.patient else { return }
                Task {
                    do {
                        let appointments = try await AccessSupabase.shared.fetchAppointments(patientID: patient.patientID)
                        if let apptToDelete = appointments.first(where: { $0.status == .scheduled }), let id = apptToDelete.appointmentId {
                            try await AccessSupabase.shared.deleteAppointment(id: id)
                        }
                        try await AccessSupabase.shared.clearNextSessionDate(patientID: patient.patientID)
                        await MainActor.run {
                            self.patient?.nextSessionDate = nil
                            self.PatientProfileCollectionView.reloadData()
                        }
                    } catch {
                        print("Error deleting: \(error)")
                    }
                }
            }
        
        
        popoverVC.onScheduleConfirmed = { [weak self] selectedFullDate in
            guard let self = self,
            var patient = self.patient else{return}
            Task{
                do{
                    let appointments = try await AccessSupabase.shared.fetchAppointments(patientID: patient.patientID)
                    let futureUpcomingAppt = appointments.first(where:{
                        $0.status == .scheduled
                    })
                    if let apptToUpdate = futureUpcomingAppt{
                        print(patient.nextSessionDate)
                        var updatedAppt = apptToUpdate
                        updatedAppt.scheduledAt = selectedFullDate
                        _ = try await AccessSupabase.shared.updateAppointment(updatedAppt)
                        print("Schedule update")
                    }else{
                        let newAppointment = Appointment(
                            appointmentId: UUID(), patientId: patient.patientID, doctorId: patient.docID, scheduledAt: selectedFullDate, status: .scheduled
                        )
                        _ = try await AccessSupabase.shared.createAppointment(newAppointment)
                        print("new Appointment")
                    }
//                    if let currentNext = patient.nextSessionDate, currentNext < selectedFullDate {
//                                     patient.previousSessionDate = currentNext
//                                }
                    patient.nextSessionDate = selectedFullDate
                    print(patient.previousSessionDate)
                    try await AccessSupabase.shared.updatePatient(patient)
                    await MainActor.run {
                        self.patient = patient
                        self.PatientProfileCollectionView.reloadData()
                    }
                }catch{
                    print("Scheduling Error: \(error)")
                }
            }
        }
        popoverVC.onScheduleChange = { [weak self] newDate in
            guard let self = self, var patient = self.patient else { return }
            
            Task {
                do {
                    let appointments = try await AccessSupabase.shared.fetchAppointments(patientID: patient.patientID)
                    
                    if let apptToUpdate = appointments.first(where: { $0.status == .scheduled }) {
                        var updatedAppt = apptToUpdate
                        updatedAppt.scheduledAt = newDate
                        
                        _ = try await AccessSupabase.shared.updateAppointment(updatedAppt)
                        
                        patient.nextSessionDate = newDate
                        try await AccessSupabase.shared.updatePatient(patient)
                        
                        await MainActor.run {
                            self.patient = patient
                            self.PatientProfileCollectionView.reloadData()
                            print("Session successfully changed to \(newDate)")
                        }
                    }
                } catch {
                    print("Error changing session: \(error)")
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
}
