//
//  CalendarCell1.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 17/03/26.
//

import UIKit
import FSCalendar

class CalendarCell1: UICollectionViewCell,
                     FSCalendarDataSource,
                     FSCalendarDelegate,
                     FSCalendarDelegateAppearance {

    @IBOutlet weak var calendar: FSCalendar!
    var onHeightChange: ((CGFloat) -> Void)?

    // ✅ Feed mood logs from outside — VC or ViewModel sets this
    var moodLogs: [MoodLog] = [] {
        didSet {
            buildAverageMoodMap()
            calendar.reloadData()
        }
    }

    // ✅ Stores date string → average mood (1–5) for O(1) lookup
    // Key format: "yyyy-MM-dd"
    private var averageMoodByDay: [String: Double] = [:]

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCalendar()
    }

    // MARK: - Calendar Setup

    private func setupCalendar() {
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scrollDirection = .horizontal
        calendar.placeholderType = .none
        calendar.firstWeekday = 1
        calendar.scope = .week

        // ── Header ──────────────────────────────────────────
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 15, weight: .bold)
        calendar.appearance.headerTitleColor = UIColor.label
        calendar.appearance.headerDateFormat = "MMMM yyyy"

        // ── Weekday row ──────────────────────────────────────
        calendar.appearance.weekdayFont = .systemFont(ofSize: 12, weight: .semibold)
        calendar.appearance.weekdayTextColor = UIColor.secondaryLabel

        // ── Day numbers ──────────────────────────────────────
        calendar.appearance.titleFont = .systemFont(ofSize: 15, weight: .medium)
        calendar.appearance.titleDefaultColor = UIColor.label
        calendar.appearance.titleWeekendColor = UIColor.label

        // ── Selection ────────────────────────────────────────
        // Capsule-style selection circle
        calendar.appearance.selectionColor = UIColor.systemIndigo
        calendar.appearance.titleSelectionColor = .white

        // ── Today ────────────────────────────────────────────
        calendar.appearance.todayColor = UIColor.systemIndigo.withAlphaComponent(0.2)
        calendar.appearance.titleTodayColor = UIColor.systemIndigo

        // ── Event dots ───────────────────────────────────────
        // These are the mood color indicators shown below each date
        calendar.appearance.eventOffset = CGPoint(x: 0, y: 2)

        // ── Border radius ─────────────────────────────────────
        calendar.appearance.borderRadius = 1.0 // full circle selection
    }

    // MARK: - Mood Map Builder

    /// Groups logs by day, computes average mood per day
    private func buildAverageMoodMap() {
        var grouped: [String: [Int]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for log in moodLogs {
            guard let date = log.date else { continue }
            let key = formatter.string(from: date)
            grouped[key, default: []].append(log.mood)
        }

        averageMoodByDay = grouped.mapValues { moods in
            Double(moods.reduce(0, +)) / Double(moods.count)
        }
    }

    // MARK: - Mood Color Helper

    /// Maps average mood (1–5) → UIColor
    private func moodColor(for average: Double) -> UIColor {
        switch average {
        case ..<1.5: return UIColor.systemRed                              // 1 — Bad
        case 1.5..<2.5: return UIColor.systemOrange                       // 2 — Poor
        case 2.5..<3.5: return UIColor.systemYellow                       // 3 — Neutral
        case 3.5..<4.5: return UIColor(red: 0.6, green: 0.9, blue: 0.4, alpha: 1) // 4 — Good (light green)
        default:         return UIColor.systemGreen                        // 5 — Great
        }
    }

    // MARK: - FSCalendarDataSource

    /// Returns number of event dots — 1 per day that has mood logs
    func calendar(_ calendar: FSCalendar,
                  numberOfEventsFor date: Date) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        return averageMoodByDay[key] != nil ? 1 : 0
    }

    // MARK: - FSCalendarDelegateAppearance

    /// Returns the mood-based color for the event dot
    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  eventDefaultColorsFor date: Date) -> [UIColor]? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        guard let avg = averageMoodByDay[key] else { return nil }
        return [moodColor(for: avg)]
    }

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  eventSelectionColorsFor date: Date) -> [UIColor]? {
        return self.calendar(calendar,
                             appearance: appearance,
                             eventDefaultColorsFor: date)
    }

    // MARK: - Scope Switch

    func setupForWeek() {
        if calendar.scope != .week {
            calendar.setScope(.week, animated: true)
        }
        calendar.scrollEnabled = true
    }

    func setupForMonth() {
        if calendar.scope != .month {
            calendar.setScope(.month, animated: true)
        }
        calendar.scrollEnabled = true
    }

    func configure(segment: Int) {
        if segment == 0 { setupForWeek() } else { setupForMonth() }
    }

    // MARK: - Height Change

    func calendar(_ calendar: FSCalendar,
                  boundingRectWillChange bounds: CGRect,
                  animated: Bool) {
        calendar.frame.size.height = bounds.height
        onHeightChange?(bounds.height)
    }
}
