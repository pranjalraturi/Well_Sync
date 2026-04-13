////
////
////  CalendarCell1.swift
////  wellSync
////
////  Created by Vidit Saran Agarwal on 17/03/26.
////
//
//import UIKit
//import FSCalendar
//
//class CalendarCell1: UICollectionViewCell,
//                     FSCalendarDataSource,
//                     FSCalendarDelegate,
//                     FSCalendarDelegateAppearance {
//
//    @IBOutlet weak var calendar: FSCalendar!
//    var onHeightChange: ((CGFloat) -> Void)?
//
//    var moodLogs: [MoodLog] = [] {
//        didSet {
//            buildDominantMoodMap()
//            calendar.reloadData()
//        }
//    }
//
//    private var dominantMoodByDay: [String: Int] = [:]
//
//    private let dateFormatter: DateFormatter = {
//        let f = DateFormatter()
//        f.dateFormat = "yyyy-MM-dd"
//        return f
//    }()
//
//    // MARK: - Lifecycle
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupCalendar()
//    }
//
//    // MARK: - Calendar Setup
//
//    private func setupCalendar() {
//        calendar.dataSource = self
//        calendar.delegate = self
//        calendar.scrollDirection = .horizontal
//        calendar.placeholderType = .none
//        calendar.firstWeekday = 1
//        calendar.scope = .week
//
//        calendar.appearance.headerMinimumDissolvedAlpha = 0
//        calendar.appearance.headerTitleFont  = .systemFont(ofSize: 15, weight: .bold)
//        calendar.appearance.headerTitleColor = UIColor.label
//        calendar.appearance.headerDateFormat = "MMMM yyyy"
//
//        calendar.appearance.weekdayFont      = .systemFont(ofSize: 12, weight: .semibold)
//        calendar.appearance.weekdayTextColor = UIColor.secondaryLabel
//
//        calendar.appearance.titleFont           = .systemFont(ofSize: 15, weight: .medium)
//        calendar.appearance.titleDefaultColor   = UIColor.label
//        calendar.appearance.titleWeekendColor   = UIColor.label
//
//        calendar.appearance.selectionColor      = UIColor.systemIndigo
//        calendar.appearance.titleSelectionColor = UIColor.label
//
//        calendar.appearance.todayColor          = .clear
//        calendar.appearance.titleTodayColor     = UIColor.systemIndigo
//
//        calendar.appearance.borderRadius = 1.0
//        calendar.appearance.eventOffset  = .zero
//    }
//
//    // MARK: - Data Processing
//
//    private func buildDominantMoodMap() {
//        var grouped: [String: [Int]] = [:]
//        for log in moodLogs {
//            let key = dateFormatter.string(from: log.date)
//            grouped[key, default: []].append(log.mood)
//        }
//
//        dominantMoodByDay = grouped.mapValues { moods in
//            var counts: [Int: Int] = [:]
//            for mood in moods {
//                counts[mood, default: 0] += 1
//            }
//            let maxCount = counts.values.max() ?? 1
//            return counts
//                .filter { $0.value == maxCount }
//                .keys
//                .max() ?? moods[0]
//        }
//    }
//
//    private func moodColor(for mood: Int) -> UIColor {
//        switch mood {
//        case 1:  return UIColor.systemRed
//        case 2:  return UIColor.systemOrange
//        case 3:  return UIColor.systemYellow
//        case 4:  return UIColor(red: 0.6, green: 0.9, blue: 0.4, alpha: 1)
//        default: return UIColor.systemGreen
//        }
//    }
//
////    private func titleColor(for mood: Int) -> UIColor {
////        return mood == 3 ? UIColor.label : .white
////    }
//
//    // MARK: - Scope Helpers
//
//    func setupForWeek() {
//        if calendar.scope != .week {
//            calendar.setScope(.week, animated: true)
//        }
//        calendar.scrollEnabled = true
//    }
//
//    func setupForMonth() {
//        if calendar.scope != .month {
//            calendar.setScope(.month, animated: true)
//        }
//        calendar.scrollEnabled = true
//    }
//
//    func configure(segment: Int) {
//        if segment == 0 { setupForWeek() } else { setupForMonth() }
//    }
//
//    // MARK: - Height Change Callback
//
//    func calendar(_ calendar: FSCalendar,
//                  boundingRectWillChange bounds: CGRect,
//                  animated: Bool) {
//        calendar.frame.size.height = bounds.height
//        onHeightChange?(bounds.height)
//    }
//}


//
//  CalendarCell1.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 17/03/26.
//

import UIKit
import FSCalendar

// MARK: - CalendarCell1Delegate

protocol CalendarCell1Delegate: AnyObject {

    func calendarCell(_ cell: CalendarCell1,
                      didChangeVisibleRange range: ClosedRange<Date>,
                      isWeekly: Bool)

    func calendarCell(_ cell: CalendarCell1,
                      didChangeHeight height: CGFloat)
}

// MARK: - CalendarCell1

class CalendarCell1: UICollectionViewCell,
                     FSCalendarDataSource,
                     FSCalendarDelegate,
                     FSCalendarDelegateAppearance {

    @IBOutlet weak var calendar: FSCalendar!

    var onHeightChange: ((CGFloat) -> Void)?
    weak var delegate: CalendarCell1Delegate?

    // MARK: - Chevron Buttons
    // We create these in code so no XIB changes are needed.
    // They sit in the calendar's header row (left edge = prev, right edge = next).

    private lazy var prevButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .medium)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor.secondaryLabel
        btn.addTarget(self, action: #selector(goToPrev), for: .touchUpInside)
        return btn
    }()

    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .medium)
        btn.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor.secondaryLabel
        btn.addTarget(self, action: #selector(goToNext), for: .touchUpInside)
        return btn
    }()

    // MARK: - Data

    var moodLogs: [MoodLog] = [] {
        didSet {
            buildDominantMoodMap()
            calendar.reloadData()
        }
    }

    private var dominantMoodByDay: [String: Int] = [:]

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCalendar()
        setupChevronButtons()  // Step 1: attach buttons to the cell's contentView
    }

    // MARK: - Layout
    // Step 2: every time UIKit re-lays out the cell (rotation, scope change, etc.)
    // we reposition the buttons so they always hug the header row.

    override func layoutSubviews() {
        super.layoutSubviews()
        positionChevronButtons()
    }

    // MARK: - Calendar Setup

    private func setupCalendar() {
        calendar.dataSource      = self
        calendar.delegate        = self
        calendar.scrollDirection = .horizontal
        calendar.placeholderType = .none
        calendar.firstWeekday    = 1
        calendar.scope           = .week

        calendar.appearance.headerMinimumDissolvedAlpha = 0
        calendar.appearance.headerTitleFont  = .systemFont(ofSize: 15, weight: .bold)
        calendar.appearance.headerTitleColor = UIColor.label
        calendar.appearance.headerDateFormat = "MMMM yyyy"

        calendar.appearance.weekdayFont      = .systemFont(ofSize: 12, weight: .semibold)
        calendar.appearance.weekdayTextColor = UIColor.secondaryLabel

        calendar.appearance.titleFont           = .systemFont(ofSize: 15, weight: .medium)
        calendar.appearance.titleDefaultColor   = UIColor.label
        calendar.appearance.titleWeekendColor   = UIColor.label

        calendar.appearance.selectionColor      = .clear
        calendar.appearance.titleSelectionColor = UIColor.systemIndigo

        calendar.appearance.todayColor          = .clear
        calendar.appearance.titleTodayColor     = UIColor.systemIndigo

        calendar.appearance.borderRadius = 1.0
        calendar.appearance.eventOffset  = .zero

        calendar.select(nil)
        calendar.setCurrentPage(Date(), animated: false)
    }

    // MARK: - Chevron Setup

    /// Step 1a — Add both buttons to contentView once (called from awakeFromNib).
    private func setupChevronButtons() {
        contentView.addSubview(prevButton)
        contentView.addSubview(nextButton)
        // Bring them in front of the calendar layer
        contentView.bringSubviewToFront(prevButton)
        contentView.bringSubviewToFront(nextButton)
    }

    /// Step 2a — Frame-based positioning so the buttons sit exactly in the
    /// FSCalendar header row (approx top 36 pt of the calendar frame).
    /// This runs every layoutSubviews call, which handles scope animations too.
    private func positionChevronButtons() {
        guard let cal = calendar else { return }

        // FSCalendar's header row is the top ~36 pt of its frame.
        let headerHeight: CGFloat = 36
        let btnSize: CGFloat      = 36
        let calFrame              = cal.frame

        // Vertically centre the button in the header row.
        let btnY = calFrame.minY + (headerHeight - btnSize) / 2

        // Left chevron: flush to the left edge of the calendar with a small inset
        prevButton.frame = CGRect(
            x: calFrame.minX + 8,
            y: btnY,
            width: btnSize,
            height: btnSize
        )

        // Right chevron: flush to the right edge of the calendar with a small inset
        nextButton.frame = CGRect(
            x: calFrame.maxX - btnSize - 8,
            y: btnY,
            width: btnSize,
            height: btnSize
        )
    }

    // MARK: - Chevron Actions

    /// Step 3: Navigate to the PREVIOUS week or month.
    /// We compute the target date from `calendar.currentPage` so FSCalendar's
    /// own page-tracking stays in sync, then call `setCurrentPage(_:animated:)`.
    @objc private func goToPrev() {
        let cal      = Calendar.current
        let current  = calendar.currentPage

        let target: Date
        if calendar.scope == .week {
            // Go back exactly 7 days
            target = cal.date(byAdding: .day, value: -7, to: current) ?? current
        } else {
            // Go back 1 calendar month
            target = cal.date(byAdding: .month, value: -1, to: current) ?? current
        }

        calendar.setCurrentPage(target, animated: true)
    }

    /// Step 4: Navigate to the NEXT week or month (mirror of goToPrev).
    @objc private func goToNext() {
        let cal      = Calendar.current
        let current  = calendar.currentPage

        let target: Date
        if calendar.scope == .week {
            target = cal.date(byAdding: .day, value: 7, to: current) ?? current
        } else {
            target = cal.date(byAdding: .month, value: 1, to: current) ?? current
        }

        calendar.setCurrentPage(target, animated: true)
    }

    // MARK: - Data Processing

    private func buildDominantMoodMap() {
        var grouped: [String: [Int]] = [:]
        for log in moodLogs {
            let key = dateFormatter.string(from: log.date)
            grouped[key, default: []].append(log.mood)
        }
        dominantMoodByDay = grouped.mapValues { moods in
            var counts: [Int: Int] = [:]
            for mood in moods { counts[mood, default: 0] += 1 }
            let maxCount = counts.values.max() ?? 1
            return counts.filter { $0.value == maxCount }.keys.max() ?? moods[0]
        }
    }

    // MARK: - Visible Range

    func currentVisibleRange() -> (range: ClosedRange<Date>, startDate: Date, dayCount: Int) {
        let cal  = Calendar.current
        let page = calendar.currentPage

        if calendar.scope == .week {
            let startOfWeek = cal.dateInterval(of: .weekOfYear, for: page)?.start ?? page
            let endDate     = cal.date(byAdding: .day, value: 6, to: startOfWeek)!
            let endOfDay    = cal.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
            return (startOfWeek...endOfDay, startOfWeek, 7)
        } else {
            let nextMonth = cal.date(byAdding: .month, value: 1, to: page)!
            let lastDay   = cal.date(byAdding: .day, value: -1, to: nextMonth)!
            let endOfDay  = cal.date(bySettingHour: 23, minute: 59, second: 59, of: lastDay)!
            let dayCount  = cal.range(of: .day, in: .month, for: page)?.count ?? 30
            return (page...endOfDay, page, dayCount)
        }
    }

    // MARK: - FSCalendar Delegate

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let (range, _, _) = currentVisibleRange()
        delegate?.calendarCell(self,
                               didChangeVisibleRange: range,
                               isWeekly: calendar.scope == .week)
    }

    func calendar(_ calendar: FSCalendar,
                  boundingRectWillChange bounds: CGRect,
                  animated: Bool) {
        calendar.frame.size.height = bounds.height
        delegate?.calendarCell(self, didChangeHeight: bounds.height)
        onHeightChange?(bounds.height)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let (range, _, _) = self.currentVisibleRange()
            self.delegate?.calendarCell(self,
                                        didChangeVisibleRange: range,
                                        isWeekly: calendar.scope == .week)
        }
    }

    // MARK: - Scope Helpers

    private func setupForWeek() {
        if calendar.scope != .week { calendar.setScope(.week, animated: false) }
        calendar.scrollEnabled = true
    }

    private func setupForMonth() {
        if calendar.scope != .month { calendar.setScope(.month, animated: false) }
        calendar.scrollEnabled = true
    }

    func configure(segment: Int) {
        let isWeekly = (segment == 0)
        if isWeekly { setupForWeek() } else { setupForMonth() }

        DispatchQueue.main.async {
            let (range, _, _) = self.currentVisibleRange()
            self.delegate?.calendarCell(self,
                                        didChangeVisibleRange: range,
                                        isWeekly: isWeekly)
        }
    }
}
