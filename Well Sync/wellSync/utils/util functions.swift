//
//  util functions.swift
//  wellSync
//
//  Created by Rishika Mittal on 24/04/26.
//

import Foundation
import UIKit
import UserNotifications

func style(_ cell: UICollectionViewCell) {
    cell.layer.shadowColor             = UIColor.black.withAlphaComponent(0.5).cgColor
    cell.layer.shadowOpacity           = 0.25
    cell.layer.shadowOffset            = CGSize(width: 0, height: 1.0)
    cell.layer.shadowRadius            = 2
    cell.layer.masksToBounds           = false
    cell.contentView.layer.cornerRadius  = 20
    cell.contentView.layer.masksToBounds = true
    cell.layer.cornerRadius            = 20
}

func styleTableCell(_ cell: UITableViewCell) {
    cell.layer.shadowColor             = UIColor.black.withAlphaComponent(0.5).cgColor
    cell.layer.shadowOpacity           = 0.25
    cell.layer.shadowOffset            = CGSize(width: 0, height: 0)
    cell.layer.shadowRadius            = 2
    cell.layer.masksToBounds           = false
    cell.contentView.layer.cornerRadius  = 20
    cell.contentView.layer.masksToBounds = true
    cell.layer.cornerRadius            = 20
}
//
//  BaseInsetGroupedTableViewController.swift
//  wellSync
//

import UIKit

class BaseInsetGroupedTableViewController: UITableViewController {
    
    var sectionShadowViews: [Int: UIView] = [:]
    
    /// Override this in subclasses to return section indices that should NOT have a shadow/card background
    var unshadowedSections: Set<Int> {
        return []
    }
    
    /// Override this to change the spacing below each section
    var sectionFooterSpacing: CGFloat {
        return 24.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure TableView for better shadows
        tableView.backgroundColor = .systemGroupedBackground
        tableView.clipsToBounds = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for section in 0..<tableView.numberOfSections {
            // Check if this section should be ignored
            if unshadowedSections.contains(section) { continue }
            
            let numberOfRows = tableView.numberOfRows(inSection: section)
            if numberOfRows == 0 { continue }
            
            let firstRowRect = tableView.rectForRow(at: IndexPath(row: 0, section: section))
            let lastRowRect = tableView.rectForRow(at: IndexPath(row: numberOfRows - 1, section: section))
            let rowsRect = firstRowRect.union(lastRowRect)
            
            // If the section isn't visible or has no rect, skip
            if rowsRect.isEmpty || rowsRect.height == 0 { continue }
            
            if sectionShadowViews[section] == nil {
                let shadowView = UIView()
                shadowView.backgroundColor = .secondarySystemGroupedBackground
                shadowView.layer.cornerRadius = 16
                shadowView.layer.shadowColor = UIColor.black.cgColor
                shadowView.layer.shadowOpacity = 0.12
                shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
                shadowView.layer.shadowRadius = 8
                shadowView.isUserInteractionEnabled = false
                
                // Insert behind all cells
                tableView.insertSubview(shadowView, at: 0)
                sectionShadowViews[section] = shadowView
            }
            
            // InsetGrouped standard margin is 20
            let horizontalMargin: CGFloat = 20
            let adjustedRect = CGRect(x: horizontalMargin, 
                                      y: rowsRect.origin.y, 
                                      width: tableView.bounds.width - (horizontalMargin * 2), 
                                      height: rowsRect.height)
            sectionShadowViews[section]?.frame = adjustedRect
        }
    }
    
    // MARK: - Section Spacing
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionFooterSpacing
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    // MARK: - Cell Rendering
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .secondarySystemGroupedBackground
        
        // Remove any individual cell shadows
        cell.layer.shadowOpacity = 0
        cell.contentView.layer.masksToBounds = true
        
        // Handle unshadowed sections (like profile headers)
        if unshadowedSections.contains(indexPath.section) {
            cell.contentView.layer.cornerRadius = 20
            return
        }
        
        let rows = tableView.numberOfRows(inSection: indexPath.section)
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == rows - 1
        
        // Apply corner radius to match the shadow view behind it
        cell.contentView.layer.cornerRadius = 16
        if isFirst && isLast {
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.contentView.layer.cornerRadius = 0
        }
    }
}

extension Notification.Name {
    static let wellSyncAppointmentsChanged = Notification.Name("wellSyncAppointmentsChanged")
    static let wellSyncActivityLogsChanged = Notification.Name("wellSyncActivityLogsChanged")
    static let wellSyncMoodLogsChanged = Notification.Name("wellSyncMoodLogsChanged")
    static let wellSyncDeviceTokenUpdated = Notification.Name("wellSyncDeviceTokenUpdated")
}

final class NotificationScheduler: NSObject {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()
    private var observers: [NSObjectProtocol] = []
    private let patientSnapshotKeyPrefix = "wellsync_patient_appointment_snapshot_"
    private let patientSessionReminderHandledKey = "wellsync_patient_session_morning_handled_appointment"

    private override init() {
        super.init()
    }

    func start() {
        center.delegate = self
        requestAuthorizationIfNeeded()
        observeDataChanges()
    }

    func refreshForCurrentSession() {
        Task {
            switch SessionManager.shared.currentRole {
            case .doctor:
                guard let doctorID = SessionManager.shared.currentDoctor?.docID else { return }
                await scheduleDoctorAppointmentReminders(for: doctorID)
                clearPatientNotificationRequests()
            case .patient:
                guard let patientID = SessionManager.shared.currentPatient?.patientID else { return }
                await schedulePatientMoodReminders()
                await schedulePatientIncompleteActivityReminder(for: patientID)
                await schedulePatientSessionMorningReminder(for: patientID)
                clearDoctorNotificationRequests()
            case .none:
                clearAllWellSyncNotifications()
            }
        }
    }

    private func requestAuthorizationIfNeeded() {
        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }
            let status = settings.authorizationStatus
            if status == .authorized || status == .provisional || status == .ephemeral {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                return
            }
            guard status == .notDetermined else { return }

            self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error {
                    print("Notification permission failed: \(error.localizedDescription)")
                    return
                }
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    self.refreshForCurrentSession()
                }
            }
        }
    }

    private func observeDataChanges() {
        guard observers.isEmpty else { return }

        let names: [Notification.Name] = [
            .wellSyncAppointmentsChanged,
            .wellSyncActivityLogsChanged,
            .wellSyncMoodLogsChanged
        ]

        for name in names {
            let token = NotificationCenter.default.addObserver(
                forName: name,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.refreshForCurrentSession()
            }
            observers.append(token)
        }
    }

    private func scheduleDoctorAppointmentReminders(for doctorID: UUID) async {
        do {
            let appointments = try await AccessSupabase.shared.fetchAllAppointmentsWithPatients(doctorID: doctorID)
                .filter { $0.status == .scheduled && $0.scheduledAt > Date() }
                .prefix(30)

            clearDoctorNotificationRequests()
            var seenSlots = Set<String>()

            for appointment in appointments {
                let slot = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: appointment.scheduledAt
                )
                let slotKey = "\(appointment.patientId.uuidString)-\(slot.year ?? 0)-\(slot.month ?? 0)-\(slot.day ?? 0)-\(slot.hour ?? 0)-\(slot.minute ?? 0)"
                guard seenSlots.insert(slotKey).inserted else { continue }

                let now = Date()
                let appointmentTime = appointment.scheduledAt
                guard appointmentTime > now else { continue }

                let intendedFireDate = appointmentTime.addingTimeInterval(-5 * 60)
                guard intendedFireDate > now else { continue }

                let content = UNMutableNotificationContent()
                content.title = "Appointment Reminder"
                content.body = "Session with \(appointment.patient.name) in 5 minutes."
                content.sound = .default

                let triggerDate = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second],
                    from: intendedFireDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                let identifier = "doctor.appointment.\(appointment.appointmentId.uuidString)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                center.add(request) { error in
                    if let error {
                        print("Doctor reminder scheduling failed: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            print("Doctor notification scheduling failed: \(error.localizedDescription)")
        }
    }

    private func schedulePatientMoodReminders() async {
        clearPatientMoodNotificationRequests()

        let reminderHours = [10, 14, 20]
        for hour in reminderHours {
            var components = DateComponents()
            components.hour = hour
            components.minute = 0

            let content = UNMutableNotificationContent()
            content.title = "Mood Log Reminder"
            content.body = "Take a moment to log your mood in Well Sync."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "patient.mood.\(hour)",
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
                if let error {
                    print("Mood reminder scheduling failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func schedulePatientIncompleteActivityReminder(for patientID: UUID) async {
        clearPatientCompletionNotificationRequests()

        do {
            let todayItems = try await buildTodayItems(for: patientID)
            let hasIncomplete = todayItems.contains { !$0.isCompletedToday }
            guard hasIncomplete else { return }

            var reminderDate = Calendar.current.date(
                bySettingHour: 20,
                minute: 0,
                second: 0,
                of: Date()
            ) ?? Date()

            if reminderDate <= Date() {
                reminderDate = Date().addingTimeInterval(30 * 60)
            }

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminderDate
            )

            let content = UNMutableNotificationContent()
            content.title = "Complete Today’s Activity"
            content.body = "You still have assigned activities pending for today."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "patient.activity.completion",
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
                if let error {
                    print("Activity completion reminder scheduling failed: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Activity completion reminder scheduling failed: \(error.localizedDescription)")
        }
    }

    private func schedulePatientSessionMorningReminder(for patientID: UUID) async {
        clearPatientSessionNotificationRequests()

        do {
            let now = Date()
            guard let appointment = try await AccessSupabase.shared.fetchAppointments(patientID: patientID)
                .filter({ $0.status == .scheduled && $0.scheduledAt > now })
                .sorted(by: { $0.scheduledAt < $1.scheduledAt })
                .first else {
                return
            }
            guard let appointmentID = appointment.appointmentId?.uuidString else { return }
            let reminderHandledID = "\(appointmentID)-\(Int(appointment.scheduledAt.timeIntervalSince1970))"

            let calendar = Calendar.current
            let morningReminderDate = calendar.date(
                bySettingHour: 8,
                minute: 0,
                second: 0,
                of: appointment.scheduledAt
            ) ?? appointment.scheduledAt

            let reminderDate: Date
            if morningReminderDate <= now {
                guard UserDefaults.standard.string(forKey: patientSessionReminderHandledKey) != reminderHandledID else {
                    return
                }
                reminderDate = now.addingTimeInterval(5)
            } else {
                reminderDate = morningReminderDate
            }

            let appointmentTime = DateFormatter()
            appointmentTime.locale = Locale.current
            appointmentTime.dateStyle = .none
            appointmentTime.timeStyle = .short

            let content = UNMutableNotificationContent()
            content.title = "Session Today"
            content.body = "You have a session scheduled today at \(appointmentTime.string(from: appointment.scheduledAt))."
            content.sound = .default

            let components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: reminderDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "patient.session.morning",
                content: content,
                trigger: trigger
            )

            UserDefaults.standard.set(reminderHandledID, forKey: patientSessionReminderHandledKey)
            center.add(request) { error in
                if let error {
                    print("Patient session morning reminder scheduling failed: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Patient session morning reminder scheduling failed: \(error.localizedDescription)")
        }
    }

    func sendImmediatePatientNudge(patientName: String, scheduledAt: Date?) {
        guard SessionManager.shared.currentRole == .patient else { return }

        let content = UNMutableNotificationContent()
        content.title = "Session Reminder"

        if let scheduledAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            let timeText = formatter.string(from: scheduledAt)
            content.body = "Session with \(patientName) is scheduled at \(timeText)."
        } else {
            content.body = "Your session is scheduled. Please check Well Sync."
        }
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "patient.manual.notify.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                print("Manual patient notify failed: \(error.localizedDescription)")
            }
        }
    }

    func sendImmediatePatientCancellation(patientName: String) {
        guard SessionManager.shared.currentRole == .patient else { return }

        sendImmediateNotification(
            title: "Session Canceled",
            body: "Your session with \(patientName) has been canceled."
        )
    }

    private struct PatientAppointmentSnapshot: Codable {
        let id: String
        let scheduledAt: Date
        let status: String
    }

    private func syncPatientAppointmentStateNotifications(for patientID: UUID) async {
        do {
            let fetched = try await AccessSupabase.shared.fetchAppointments(patientID: patientID)
            let now = Date()

            let currentScheduled = fetched.filter {
                $0.status == .scheduled && $0.scheduledAt > now
            }

            let snapshotKey = patientSnapshotKeyPrefix + patientID.uuidString
            let oldSnapshot = loadPatientSnapshot(forKey: snapshotKey)

            let oldByID: [String: PatientAppointmentSnapshot] = Dictionary(
                uniqueKeysWithValues: oldSnapshot.map { ($0.id, $0) }
            )
            let currentPairs: [(String, Appointment)] = currentScheduled.compactMap { appointment in
                guard let id = appointment.appointmentId?.uuidString else { return nil }
                return (id, appointment)
            }
            let currentByID: [String: Appointment] = Dictionary(uniqueKeysWithValues: currentPairs)

            for appointment in currentScheduled {
                guard let id = appointment.appointmentId?.uuidString else { continue }
                if oldByID[id] == nil {
                    sendImmediateNotification(
                        title: "Session Scheduled",
                        body: "Your session is scheduled. Please check Well Sync."
                    )
                }
            }

            for old in oldSnapshot {
                if currentByID[old.id] == nil && old.scheduledAt > now {
                    sendImmediateNotification(
                        title: "Session Canceled",
                        body: "Your scheduled session has been canceled."
                    )
                }
            }

            let newSnapshot = currentScheduled.compactMap { appointment -> PatientAppointmentSnapshot? in
                guard let id = appointment.appointmentId?.uuidString else { return nil }
                return PatientAppointmentSnapshot(
                    id: id,
                    scheduledAt: appointment.scheduledAt,
                    status: appointment.status.rawValue
                )
            }
            savePatientSnapshot(newSnapshot, forKey: snapshotKey)

        } catch {
            print("Patient appointment sync notification failed: \(error.localizedDescription)")
        }
    }

    private func sendImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "patient.event.\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        center.add(request) { error in
            if let error {
                print("Immediate patient event notification failed: \(error.localizedDescription)")
            }
        }
    }

    private func loadPatientSnapshot(forKey key: String) -> [PatientAppointmentSnapshot] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let value = try? JSONDecoder().decode([PatientAppointmentSnapshot].self, from: data) else {
            return []
        }
        return value
    }

    private func savePatientSnapshot(_ snapshot: [PatientAppointmentSnapshot], forKey key: String) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func clearAllWellSyncNotifications() {
        center.removePendingNotificationRequests(withIdentifiers: [
            "patient.activity.completion",
            "patient.session.morning"
        ])
        clearDoctorNotificationRequests()
        clearPatientMoodNotificationRequests()
    }

    private func clearDoctorNotificationRequests() {
        center.getPendingNotificationRequests { requests in
            let identifiers = requests
                .map(\.identifier)
                .filter { $0.hasPrefix("doctor.appointment.") }
            self.center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    private func clearPatientMoodNotificationRequests() {
        center.removePendingNotificationRequests(withIdentifiers: [
            "patient.mood.10",
            "patient.mood.14",
            "patient.mood.20"
        ])
    }

    private func clearPatientCompletionNotificationRequests() {
        center.removePendingNotificationRequests(withIdentifiers: [
            "patient.activity.completion"
        ])
    }

    private func clearPatientSessionNotificationRequests() {
        center.removePendingNotificationRequests(withIdentifiers: [
            "patient.session.morning"
        ])
    }

    private func clearPatientNotificationRequests() {
        clearPatientMoodNotificationRequests()
        clearPatientCompletionNotificationRequests()
        clearPatientSessionNotificationRequests()
    }
}

extension NotificationScheduler: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
}

final class PushNotificationService {
    static let shared = PushNotificationService()
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeviceTokenUpdated),
            name: .wellSyncDeviceTokenUpdated,
            object: nil
        )
    }

    private let tokenStorageKey = "wellsync_apns_device_token"
    private let remotePushURL = URL(
        string: "https://qzcfmkjvenxbrndlgowp.supabase.co/functions/v1/send-patient-push"
    )!
    private let anonKey = sKey

    struct DeliveryResult {
        let success: Bool
        let message: String?
    }

    func registerAPNsDeviceToken(_ tokenData: Data) {
        let token = tokenData.map { String(format: "%02x", $0) }.joined()
        UserDefaults.standard.set(token, forKey: tokenStorageKey)
        NotificationCenter.default.post(name: .wellSyncDeviceTokenUpdated, object: nil)
    }

    @objc private func handleDeviceTokenUpdated() {
        syncCurrentUserDeviceTokenIfPossible()
    }

    func syncCurrentUserDeviceTokenIfPossible() {
        guard let token = UserDefaults.standard.string(forKey: tokenStorageKey), !token.isEmpty else { return }

        let role = SessionManager.shared.currentRole
        let patientID = SessionManager.shared.currentPatient?.patientID
        let doctorID = SessionManager.shared.currentDoctor?.docID

        Task {
            do {
                try await AccessSupabase.shared.upsertDevicePushToken(
                    token: token,
                    role: role.rawValue,
                    patientID: patientID,
                    doctorID: doctorID
                )
            } catch {
                print("Device token sync failed: \(error.localizedDescription)")
            }
        }
    }

    func sendPatientRemotePush(
        patientID: UUID,
        title: String,
        body: String,
        kind: String
    ) async -> DeliveryResult {
        do {
            var request = URLRequest(url: remotePushURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
            request.setValue(anonKey, forHTTPHeaderField: "apikey")

            let payload: [String: String] = [
                "patientId": patientID.uuidString,
                "title": title,
                "body": body,
                "kind": kind
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)

            let (data, response) = try await URLSession.shared.data(for: request)
            let bodyText = String(data: data, encoding: .utf8) ?? "(no body)"
            guard let http = response as? HTTPURLResponse else {
                print("Remote push invalid response")
                return DeliveryResult(success: false, message: "Push service returned an invalid response.")
            }
            guard (200...299).contains(http.statusCode) else {
                print("Remote push failed \(http.statusCode): \(bodyText)")
                return DeliveryResult(
                    success: false,
                    message: userFacingPushFailureMessage(statusCode: http.statusCode, bodyText: bodyText)
                )
            }
            let delivery = parsePushDeliveryResponse(bodyText: bodyText)
            if !delivery.success {
                print("Remote push not delivered: \(bodyText)")
            }
            return delivery
        } catch {
            print("Remote push error: \(error.localizedDescription)")
            return DeliveryResult(success: false, message: error.localizedDescription)
        }
    }

    private func parsePushDeliveryResponse(bodyText: String) -> DeliveryResult {
        guard let data = bodyText.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return DeliveryResult(success: true, message: nil)
        }

        let sent = json["sent"] as? Int
        let total = json["total"] as? Int
        let reason = json["reason"] as? String

        if sent == 0 {
            if reason == "No active patient tokens" {
                return DeliveryResult(
                    success: false,
                    message: "No patient device token found. Ask the patient to open Well Sync and allow notifications."
                )
            }

            if let total, total > 0 {
                return DeliveryResult(
                    success: false,
                    message: "APNs rejected the saved patient device token. Ask the patient to reopen the app, then try again."
                )
            }
        }

        return DeliveryResult(success: true, message: nil)
    }

    private func userFacingPushFailureMessage(statusCode: Int, bodyText: String) -> String {
        guard let data = bodyText.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let error = json["error"] as? String else {
            return "Push service failed with status \(statusCode)."
        }

        if error.contains("Missing env") {
            return "Push service is not fully configured in Supabase."
        }

        if statusCode == 401 || statusCode == 403 {
            return "Push service rejected the request. Check the Supabase function auth settings."
        }

        return error
    }
}
