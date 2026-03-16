import UIKit
import FSCalendar

protocol CalendarCellDelegate: AnyObject {
    func didSelect(date: Date)
}

class CalendarCell: UICollectionViewCell, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet weak var calendar: FSCalendar!
    
    weak var delegate: CalendarCellDelegate?
    var selectedDate = Date()
    var sessions: [SessionNote] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        calendar.delegate = self
        calendar.dataSource = self
        configureCalendar()
    }
        func configureCalendar() {

            calendar.scope = .month
            calendar.scrollDirection = .horizontal
            calendar.firstWeekday = 1

            calendar.appearance.selectionColor = .systemRed
            calendar.appearance.todayColor = UIColor.systemRed.withAlphaComponent(0.6)
            calendar.appearance.titleSelectionColor = .white
            
            calendar.placeholderType = .none
            calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 13, weight: .medium)
            calendar.appearance.titleFont = UIFont.systemFont(ofSize: 18)

            calendar.appearance.borderRadius = 1
            
            calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20, weight: .semibold)

            calendar.appearance.weekdayTextColor = .secondaryLabel
            calendar.appearance.headerTitleColor = .label
            calendar.appearance.eventDefaultColor = .systemRed

        }
    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {

        selectedDate = date

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone.current

        print("Selected:", formatter.string(from: date))
        print("selected:",selectedDate)
    }
    func calendar(_ calendar: FSCalendar,
                  boundingRectWillChange bounds: CGRect,
                  animated: Bool) {

        calendar.frame.size.height = bounds.height-30
    }
    func calendar(_ calendar: FSCalendar,
                  didDeselect date: Date,
                      at monthPosition: FSCalendarMonthPosition) {

        guard let selectedDate = calendar.selectedDate else { return }
        
        delegate?.didSelect(date: selectedDate)
    }
    func calendar(_ calendar: FSCalendar,
                  numberOfEventsFor date: Date) -> Int {

        let calendar = Calendar.current

        let events = sessions.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }

        return events.count
    }
}
