//
//  ScheduleViewController.swift
//  wellSync
//
//  Created by GEU on 19/03/26.
//

import UIKit

class ScheduleViewController: UIViewController, UICalendarSelectionSingleDateDelegate, UICalendarViewDelegate {
    var patient: Patient?
    var patientPreviousSession: [SessionNote] = []
    let calendarView = UICalendarView()
    let timePicker = UIDatePicker()
    let scheduleButton = UIButton()
    var onScheduleConfirmed: ((Date) -> Void)?
    var selectedDate: DateComponents?
    var selection: UICalendarSelectionSingleDate?
    var scheduleDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        loadPatientPreviousSession()
        setupUI()
        calendarLogic()
        updateButtonText()
    }
    
    func loadPatientPreviousSession(){
        guard let patient = patient else{return}
        Task{
            patientPreviousSession = try await AccessSupabase.shared
                .fetchSessionNotes(patientID: patient.patientID)
        }
//        patientPreviousSession.sort { $0.date > $1.date }
//        
//        if let lastSession = patientPreviousSession.first{
//            patient?.previousSessionDate = lastSession.date
//        }
    }
    func updateButtonText(){
        if scheduleDate != nil{
            scheduleButton.setTitle("Schedule Session", for: .normal )
        }else{
            scheduleButton.setTitle("Schedule", for: .normal )
        }
    }
    func setupUI(){
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        
        calendarView.calendar = .current
        calendarView.fontDesign = .rounded
//        let selection = UICalendarSelectionSingleDate(delegate: self)
//        calendarView.selectionBehavior = selection
        
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .compact
        
        scheduleButton.setTitle("Schedule", for: .normal)
        scheduleButton.setTitleColor(.white, for: .normal)
        scheduleButton.backgroundColor = .systemBlue
        scheduleButton.layer.cornerRadius = 20
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
//            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePicker.heightAnchor.constraint(equalToConstant: 40),
            
            scheduleButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 15),
            scheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            scheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            scheduleButton.heightAnchor.constraint(equalToConstant: 40),
            
//            scheduleButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -15)
            ])
        
    }
    
    @objc func scheduleButtonTapped(){
        guard let day = selectedDate?.date else{return}
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timePicker.date)
        var finalComponents = calendar.dateComponents([.year, .month, .day], from: day)
        finalComponents.hour = timeComponents.hour
        finalComponents.minute = timeComponents.minute
        
        if let finalDate = calendar.date(from: finalComponents){
            self.scheduleDate = finalDate
            onScheduleConfirmed?(finalDate)
            calendarView.reloadDecorations(forDateComponents: [selectedDate!], animated: true)
            dismiss(animated: true)
        }
    }
    
    func calendarLogic(){
        calendarView.delegate = self
        let pastDate = Calendar.current.date(byAdding: .year, value: -2, to : Date())!
        calendarView.availableDateRange = DateInterval(start: pastDate, end: .distantFuture)
        
        self.selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = self.selection
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        calendarView.availableDateRange = DateInterval(start: today, end: .distantFuture)
//        
//        self.selection = UICalendarSelectionSingleDate(delegate: self)
//        calendarView.selectionBehavior = self.selection
    }
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let components = dateComponents, let date = components.date else {
                self.selectedDate = nil
                updateButtonText()
                return
            }
        let today = Calendar.current.startOfDay(for: Date())
        if date <= today {
            selection.setSelected(nil, animated: true)
            self.selectedDate = nil
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }else{
            self.selectedDate = dateComponents
            scheduleButton.setTitle("Schedule Session", for: .normal)
        }
    }
}
extension ScheduleViewController{
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
//        guard let patient = patient,
//              let calendarDate = dateComponents.date else{return nil}
        let calendar = Calendar.current
        guard let date = dateComponents.date else{return nil}
        
        if let schedule = scheduleDate, calendar.isDate(schedule, inSameDayAs: date){
            return .default(color: .systemGray, size: .medium)
        }
        let hasSession = patientPreviousSession.contains{ session in
            calendar.isDate(session.date, inSameDayAs: dateComponents.date ?? Date(timeIntervalSince1970: 0))
        }
//        guard let previousSessionDate = patientPreviousSession else{return nil}
//        if calendar.isDate(calendarDate, inSameDayAs:previousSessionDate){
//            return .default(color: .systemGreen, size: .medium)
//        }
//        if calendar.isDate(calendarDate, inSameDayAs:selectedDate){
//            return .default(color: .systemGray, size: .medium)
//        }
        if hasSession{
            return .default(color: .systemGreen, size: .medium)
        }
        return nil
    }
}
