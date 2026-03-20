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

    var moodLogs: [MoodLog] = [] {
        didSet {
            buildAverageMoodMap()
            calendar.reloadData()
        }
    }

    private var averageMoodByDay: [String: Double] = [:]

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCalendar()
    }

    private func setupCalendar() {
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scrollDirection = .horizontal
        calendar.placeholderType = .none
        calendar.firstWeekday = 1
        calendar.scope = .week

        calendar.appearance.headerMinimumDissolvedAlpha = 0
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 15, weight: .bold)
        calendar.appearance.headerTitleColor = UIColor.label
        calendar.appearance.headerDateFormat = "MMMM yyyy"

        calendar.appearance.weekdayFont = .systemFont(ofSize: 12, weight: .semibold)
        calendar.appearance.weekdayTextColor = UIColor.secondaryLabel

        calendar.appearance.titleFont = .systemFont(ofSize: 15, weight: .medium)
        calendar.appearance.titleDefaultColor = UIColor.label
        calendar.appearance.titleWeekendColor = UIColor.label

        calendar.appearance.selectionColor = UIColor.systemIndigo
        calendar.appearance.titleSelectionColor = .white

        calendar.appearance.todayColor = UIColor.systemIndigo.withAlphaComponent(0.2)
        calendar.appearance.titleTodayColor = UIColor.systemIndigo

        calendar.appearance.eventOffset = CGPoint(x: 0, y: 2)

        calendar.appearance.borderRadius = 1.0
    }

    private func buildAverageMoodMap() {
        var grouped: [String: [Int]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for log in moodLogs {
            let key = formatter.string(from: log.date)
            grouped[key, default: []].append(log.mood)
        }

        averageMoodByDay = grouped.mapValues { moods in
            Double(moods.reduce(0, +)) / Double(moods.count)
        }
    }

    private func moodColor(for average: Double) -> UIColor {
        switch average {
        case ..<1.5: return UIColor.systemRed                              // 1 — Bad
        case 1.5..<2.5: return UIColor.systemOrange                       // 2 — Poor
        case 2.5..<3.5: return UIColor.systemYellow                       // 3 — Neutral
        case 3.5..<4.5: return UIColor(red: 0.6, green: 0.9, blue: 0.4, alpha: 1) // 4 — Good (light green)
        default:         return UIColor.systemGreen                        // 5 — Great
        }
    }


    func calendar(_ calendar: FSCalendar,
                  numberOfEventsFor date: Date) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        return averageMoodByDay[key] != nil ? 1 : 0
    }


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

    func calendar(_ calendar: FSCalendar,
                  boundingRectWillChange bounds: CGRect,
                  animated: Bool) {
        calendar.frame.size.height = bounds.height
        onHeightChange?(bounds.height)
    }
}
