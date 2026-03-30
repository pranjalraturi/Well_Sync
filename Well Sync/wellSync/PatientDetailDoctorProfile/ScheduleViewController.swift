//
//  ScheduleViewController.swift
//  wellSync
//
//  Created by GEU on 19/03/26.
//

import UIKit

class ScheduleViewController: UIViewController, UICalendarSelectionSingleDateDelegate, UICalendarViewDelegate {
    var patient: Patient?
    var allAppointments: [Appointment] = []
    let calendarView = UICalendarView()
    let timePicker = UIDatePicker()
    let scheduleButton = UIButton()
    var onScheduleConfirmed: ((Date) -> Void)?
    var onScheduleCancelled: (() -> Void)?
    var onScheduleChange:((Date) -> Void)?
    var selectedDate: DateComponents?
    var selection: UICalendarSelectionSingleDate?
    var scheduleDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        calendarLogic()
        loadAllAppointments()
    }
    func loadAllAppointments(){
        guard let patient = patient else{return}
        Task{
            do{
                let fetched = try await AccessSupabase.shared
                    .fetchAppointments(patientID: patient.patientID)
                await MainActor.run {
//                    self.allAppointments = patientPreviousAppointments.filter { $0.status == .completed || $0.status == .missed }
                    self.allAppointments = fetched
                    self.calendarView.delegate = nil
                    self.calendarView.delegate = self
                    self.calendarView.reloadDecorations(forDateComponents: [], animated: true)
                    self.updateButtonText()
                    self.calendarView.setNeedsLayout()
                    self.calendarView.layoutIfNeeded()
                }
            }catch{
                print("Error loading appointments: \(error)")
            }
        }
    }
    func updateButtonText(){
//        let calendar = Calendar.current
        var config = UIButton.Configuration.tinted()
        config.cornerStyle = .capsule
        
        guard let selected = selectedDate?.date else {
            scheduleButton.setTitle("Select a Date", for: .normal)
            scheduleButton.isEnabled = false
            config.baseBackgroundColor = .systemGray4
            scheduleButton.configuration = config
            return
        }
        scheduleButton.isEnabled = true
        let calendar = Calendar.current
        
        if let currentScheduled = patient?.nextSessionDate{
            if calendar.isDateInToday(currentScheduled){
                scheduleButton.setTitle("Schedule", for: .normal)
                config.baseBackgroundColor = .systemGreen
            } else if calendar.isDate(currentScheduled, inSameDayAs: selected) {
                scheduleButton.setTitle("Cancel Session", for: .normal)
                config.baseBackgroundColor = .systemRed
            }
            else if patient?.nextSessionDate != nil {
                scheduleButton.setTitle("Reschedule", for: .normal)
                config.baseBackgroundColor = .systemBlue
            }
        }else{
            scheduleButton.setTitle("Schedule", for: .normal)
            config.baseBackgroundColor = .systemGreen
        }
        scheduleButton.configuration = config

    }
    func setupUI(){
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        
        calendarView.calendar = .current
        calendarView.fontDesign = .rounded
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .compact
        updateButtonText()
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        view.addSubview(calendarView)
        view.addSubview(timePicker)
        view.addSubview(scheduleButton)
        
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            calendarView.heightAnchor.constraint(equalToConstant: 400),
            
            timePicker.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 5),
            timePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            timePicker.heightAnchor.constraint(equalToConstant: 40),
            
            scheduleButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 15),
            scheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            scheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            scheduleButton.heightAnchor.constraint(equalToConstant: 40),
            ])
        
    }
    
    @objc func scheduleButtonTapped(){
        
        let currentTitle = scheduleButton.title(for: .normal)
                if currentTitle == "Cancel Session" {
                    handleCancellation()
                } else {
                    handleScheduling()
                }
    }
    private func handleCancellation() {
            guard let schedule = scheduleDate else { return }
           
            onScheduleCancelled?()
            
    
            dismiss(animated: true)
        }
    private func handleScheduling() {
            guard let day = selectedDate?.date else { return }
            
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: timePicker.date)
            var finalComponents = calendar.dateComponents([.year, .month, .day], from: day)
            finalComponents.hour = timeComponents.hour
            finalComponents.minute = timeComponents.minute
            
            if let finalDate = calendar.date(from: finalComponents) {
                let currentTitle = scheduleButton.title(for: .normal)
                if currentTitle == "Change Session" {
                    onScheduleChange?(finalDate)
                }else{
                    onScheduleConfirmed?(finalDate)
                }
                dismiss(animated: true)
            }
        }
    
    func calendarLogic(){
        calendarView.delegate = self
        let pastDate = Calendar.current.date(byAdding: .year, value: -2, to : Date())!
        calendarView.availableDateRange = DateInterval(start: pastDate, end: .distantFuture)
        
        self.selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = self.selection
    }
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        let previousSelected = self.selectedDate
        self.selectedDate = dateComponents
        
        var datesToReload: [DateComponents] = []
                if let old = previousSelected { datesToReload.append(old) }
                if let current = dateComponents { datesToReload.append(current) }
                
                calendarView.reloadDecorations(forDateComponents: datesToReload, animated: true)
                
                let today = Calendar.current.startOfDay(for: Date())
                if let date = dateComponents?.date, date <= today {
                    selection.setSelected(nil, animated: true)
                    self.selectedDate = nil
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                updateButtonText()
        
        
    }
}


extension ScheduleViewController{
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let calendar = Calendar.current
        guard let date = dateComponents.date else{return nil}
        
        if let schedule = patient?.nextSessionDate, calendar.isDate(schedule, inSameDayAs: date){
            return .default(color: .systemGray, size: .medium)
        }
        let apptOnDate = allAppointments.first { appointment in
            return calendar.isDate(appointment.scheduledAt, inSameDayAs: date)
                }
        if let appt = apptOnDate {
            switch appt.status {
            case .completed:
                return .default(color: .systemGreen, size: .medium)
            case .missed:
                return .default(color: .systemRed, size: .medium)
            default:
                return nil
            }
        }
        return nil
    }
}
