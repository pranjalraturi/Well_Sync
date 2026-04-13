//
//  ScheduleViewController.swift
//  wellSync
//

import UIKit
import FSCalendar

class ScheduleViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    var patient: Patient?
    var allAppointments: [Appointment] = []
    
    let calendar = FSCalendar() // ✅ replaced
    let timePicker = UIDatePicker()
    let scheduleButton = UIButton()
    
    var onScheduleConfirmed: ((Date) -> Void)?
    var onScheduleCancelled: (() -> Void)?
    var onScheduleChange: ((Date) -> Void)?
    
    var selectedDate: Date? // ✅ replaced
    var scheduleDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        calendarLogic()
        loadAllAppointments()
    }
    
    // MARK: - Load Data
    
    func loadAllAppointments(){
        guard let patient = patient else { return }
        
        Task{
            do{
                let fetched = try await AccessSupabase.shared
                    .fetchAppointments(patientID: patient.patientID)
                
                await MainActor.run {
                    self.allAppointments = fetched
                    self.calendar.reloadData() // ✅ FSCalendar reload
                    self.updateButtonText()
                }
                
            } catch {
                print("Error loading appointments: \(error)")
            }
        }
    }
    
    // MARK: - Button UI Logic
    
    func updateButtonText(){
        var config = UIButton.Configuration.tinted()
        config.cornerStyle = .capsule
        
        guard let selected = selectedDate else {
            scheduleButton.setTitle("Select a Date", for: .normal)
            scheduleButton.isEnabled = false
            config.baseBackgroundColor = .systemGray4
            scheduleButton.configuration = config
            return
        }
        
        scheduleButton.isEnabled = true
        let calendarSys = Calendar.current
        
        if let currentScheduled = patient?.nextSessionDate {
            
            if calendarSys.isDateInToday(currentScheduled) {
                scheduleButton.setTitle("Schedule", for: .normal)
                config.baseBackgroundColor = .systemGreen
                
            } else if calendarSys.isDate(currentScheduled, inSameDayAs: selected) {
                scheduleButton.setTitle("Cancel Session", for: .normal)
                config.baseBackgroundColor = .systemRed
                
            } else {
                scheduleButton.setTitle("Reschedule", for: .normal)
                config.baseBackgroundColor = .systemBlue
            }
            
        } else {
            scheduleButton.setTitle("Schedule", for: .normal)
            config.baseBackgroundColor = .systemGreen
        }
        
        scheduleButton.configuration = config
    }
    
    // MARK: - UI Setup
    
    func setupUI(){
        calendar.translatesAutoresizingMaskIntoConstraints = false
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .compact
        
        updateButtonText()
        
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        
        view.addSubview(calendar)
        view.addSubview(timePicker)
        view.addSubview(scheduleButton)
        
        NSLayoutConstraint.activate([
            
            calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            calendar.heightAnchor.constraint(equalToConstant: 320),
            
            timePicker.topAnchor.constraint(equalTo: calendar.bottomAnchor, constant: 2),
            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scheduleButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 4),
            scheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            scheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            scheduleButton.heightAnchor.constraint(equalToConstant: 40),
            
            scheduleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Calendar Setup
    
    func calendarLogic(){
        calendar.delegate = self
        calendar.dataSource = self
        
        calendar.scope = .month
        calendar.scrollDirection = .horizontal
        
        calendar.placeholderType = .none
        
        calendar.appearance.headerDateFormat = "MMMM yyyy"
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 16, weight: .semibold)
        calendar.appearance.headerTitleColor = .systemIndigo
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        
        calendar.appearance.weekdayFont = .systemFont(ofSize: 12, weight: .medium)
        calendar.appearance.titleFont = .systemFont(ofSize: 14)
        calendar.appearance.weekdayTextColor = .systemIndigo
        
        calendar.appearance.titleFont = .systemFont(ofSize: 15, weight: .regular)
           calendar.appearance.titleDefaultColor = .label
        
        calendar.appearance.todayColor = .clear
        calendar.appearance.titleTodayColor = .label
        
        calendar.appearance.selectionColor = .systemBlue
        
        calendar.appearance.eventDefaultColor = .clear
        calendar.appearance.borderRadius = 1.0 // 🔥 full circle
        calendar.appearance.headerMinimumDissolvedAlpha = 0
    }
    
    // MARK: - Button Action
    
    @objc func scheduleButtonTapped(){
        let currentTitle = scheduleButton.title(for: .normal)
        
        if currentTitle == "Cancel Session" {
            handleCancellation()
        } else {
            handleScheduling()
        }
    }
    
    private func handleCancellation() {
        guard selectedDate != nil else { return }
        onScheduleCancelled?()
        dismiss(animated: true)
    }
    
    private func handleScheduling() {
        guard let day = selectedDate else { return }
        
        let calendarSys = Calendar.current
        let timeComponents = calendarSys.dateComponents([.hour, .minute], from: timePicker.date)
        
        var finalComponents = calendarSys.dateComponents([.year, .month, .day], from: day)
        finalComponents.hour = timeComponents.hour
        finalComponents.minute = timeComponents.minute
        
        if let finalDate = calendarSys.date(from: finalComponents) {
            
            let currentTitle = scheduleButton.title(for: .normal)
            
            if currentTitle == "Reschedule" {
                onScheduleChange?(finalDate)
            } else {
                onScheduleConfirmed?(finalDate)
            }
            
            dismiss(animated: true)
        }
    }
}

// MARK: - FSCalendar Delegate

extension ScheduleViewController {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if date < today {
            calendar.deselect(date)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            selectedDate = nil
        } else {
            selectedDate = date
        }
        
        updateButtonText()
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let cal = Calendar.current
        
        let hasAppointment = allAppointments.contains {
            cal.isDate($0.scheduledAt, inSameDayAs: date)
        }
        
        let isNextSession = patient?.nextSessionDate.map {
            cal.isDate($0, inSameDayAs: date)
        } ?? false
        
        return (hasAppointment || isNextSession) ? 1 : 0
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        
        let appts = allAppointments.filter {
            cal.isDate($0.scheduledAt, inSameDayAs: date)
        }
        
        let isNextSession = patient?.nextSessionDate != nil &&
            cal.isDate(patient!.nextSessionDate!, inSameDayAs: date)
        
        // 🔴 Missed → red
        if appts.contains(where: { $0.status == .missed }) {
            return UIColor.systemRed.withAlphaComponent(0.25)
        }
        
        // 🟢 Completed → green
        if appts.contains(where: { $0.status == .completed }) {
            return UIColor.systemGreen.withAlphaComponent(0.25)
        }
        
        // 🔵 FIX: Scheduled appointment exists for this date → always blue
        // This catches today's session AND future sessions from allAppointments
        if appts.contains(where: { $0.status == .scheduled }) {
            return UIColor.systemBlue.withAlphaComponent(0.25)
        }
        
        // 🔵 nextSessionDate is set and is in the future → blue
        if let nextSession = patient?.nextSessionDate,
           isNextSession,
           nextSession > today {
            return UIColor.systemBlue.withAlphaComponent(0.25)
        }
        
        // ⚫ nextSessionDate is today or past → gray (stale/expired marker)
        if isNextSession {
            return UIColor.systemGray.withAlphaComponent(0.25)
        }
        
        return nil
    }
}
