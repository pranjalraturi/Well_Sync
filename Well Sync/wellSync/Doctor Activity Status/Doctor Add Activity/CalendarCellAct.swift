
import UIKit
import FSCalendar

class CalendarCellAct: UICollectionViewCell,
                     FSCalendarDataSource,
                     FSCalendarDelegate,
                     FSCalendarDelegateAppearance {

    @IBOutlet weak var calendar: FSCalendar!
    var onHeightChange: ((CGFloat) -> Void)?
    var onDateSelected: ((Date) -> Void)?
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

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

        calendar.appearance.headerMinimumDissolvedAlpha = 0
        calendar.appearance.headerTitleFont  = .systemFont(ofSize: 15, weight: .bold)
        calendar.appearance.headerTitleColor = UIColor.label
        calendar.appearance.headerDateFormat = "MMMM yyyy"

        calendar.appearance.weekdayFont      = .systemFont(ofSize: 12, weight: .semibold)
        calendar.appearance.weekdayTextColor = UIColor.secondaryLabel

        calendar.appearance.titleFont           = .systemFont(ofSize: 15, weight: .medium)
        calendar.appearance.titleDefaultColor   = UIColor.label
        calendar.appearance.titleWeekendColor   = UIColor.label

        calendar.appearance.selectionColor      = UIColor.systemIndigo
        calendar.appearance.titleSelectionColor = UIColor.label

        calendar.appearance.todayColor          = .clear
        calendar.appearance.titleTodayColor     = UIColor.systemIndigo

        calendar.appearance.borderRadius = 1.0
        calendar.appearance.eventOffset  = .zero
    }

    // MARK: - REMOVE ALL MOOD APPEARANCE LOGIC

    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        onDateSelected?(date)
    }
    
    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  fillDefaultColorFor date: Date) -> UIColor? {
        return nil
    }

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  titleDefaultColorFor date: Date) -> UIColor? {
        return nil
    }

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  fillTodayColorFor date: Date) -> UIColor? {
        return UIColor.systemIndigo.withAlphaComponent(0.15)
    }

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  fillSelectionColorFor date: Date) -> UIColor? {
        return UIColor.systemIndigo.withAlphaComponent(0.7)
    }

    // MARK: - Scope Helpers (UNCHANGED)

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

        // 🔥 FORCE reset (key fix)
//        calendar.setScope(.week, animated: true)

        if segment == 0 {
            calendar.setScope(.week, animated: true)
        } else {
            calendar.setScope(.month, animated: true)
        }
    }

    // MARK: - Height Change Callback (UNCHANGED)
    func calendar(_ calendar: FSCalendar,
                  boundingRectWillChange bounds: CGRect,
                  animated: Bool) {
        calendar.frame.size.height = bounds.height
        onHeightChange?(bounds.height)
    }
  
}
