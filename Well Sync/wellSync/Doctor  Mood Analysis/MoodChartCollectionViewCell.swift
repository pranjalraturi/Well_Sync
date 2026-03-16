////
////  BarChartCollectionViewCell.swift
////  wellSync
////
////  Created by Vidit Agarwal on 04/02/26.
////
//
import UIKit
import DGCharts

class MoodChartCollectionViewCell: UICollectionViewCell, ChartViewDelegate{
    
    @IBOutlet weak var moodChartView: LineChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupChart()
        setData()
    }
    
    func setupChart() {
        
        moodChartView.backgroundColor = .clear
        moodChartView.chartDescription.enabled = false
        moodChartView.legend.enabled = false
        moodChartView.dragEnabled = true
        moodChartView.setScaleEnabled(false)
        
        // X Axis
        let xAxis = moodChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .lightGray
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 1
        xAxis.avoidFirstLastClippingEnabled = true
        
        // Disable left axis
        moodChartView.leftAxis.enabled = false
        
        // ✅ Right axis 1–5, with padding so 1 floats above x-axis and 5 isn't clipped
        let rightAxis = moodChartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelTextColor = .lightGray
        rightAxis.gridColor = UIColor.darkGray.withAlphaComponent(0.3)
        rightAxis.axisMinimum = 0.6   // ✅ 1 appears above x-axis with breathing room
        rightAxis.axisMaximum = 5.4   // ✅ 5 has room at top, circle won't clip
        rightAxis.granularity = 1
        rightAxis.granularityEnabled = true
        rightAxis.labelCount = 5      // ✅ shows exactly 1,2,3,4,5
        rightAxis.forceLabelsEnabled = true
        rightAxis.drawAxisLineEnabled = false
        
        moodChartView.noDataText = "NO DATA AVAILABLE"
        moodChartView.noDataTextColor = .secondaryLabel
        moodChartView.noDataFont = .systemFont(ofSize: 18, weight: .semibold)
        
        moodChartView.highlightPerTapEnabled = true
        moodChartView.xAxis.granularity = 1
        moodChartView.xAxis.valueFormatter = TimeFormatter()
        moodChartView.extraTopOffset = 20
        moodChartView.setViewPortOffsets(left: 16, top: 30, right: 50, bottom: 30)
    }
    
    //    func setData() {
    //
    //        // mood logs across a week (multiple per day)
    //        var weekMoodLogs: [[Int]] {
    //            var temp : [Int] = []
    //            for i in moodLogs{
    //                temp.append(i.mood)
    //            }
    //            return [temp]
    //        }
    //
    //        // Handle no data case
    //        let totalCount = weekMoodLogs.flatMap { $0 }.count
    //        if totalCount == 0 {
    //            moodChartView.data = nil
    //            // Ensure no-data text shows
    //            moodChartView.setNeedsDisplay()
    //            return
    //        }
    //
    //        var entries: [ChartDataEntry] = []
    //        var labels: [String] = []
    //
    //        let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    //
    //        var index: Double = 0
    //
    //        for day in 0..<weekMoodLogs.count {
    //
    //            for mood in weekMoodLogs[day] {
    //
    //                entries.append(ChartDataEntry(x: index, y: Double(mood)))
    //
    //                labels.append(days[day])   // label for x axis
    //
    //                index += 1
    //            }
    //        }
    //
    //        let dataSet = LineChartDataSet(entries: entries)
    //
    //        dataSet.mode = .cubicBezier
    //        dataSet.cubicIntensity = 0.25
    //
    //        dataSet.setColor(.systemCyan)
    //        dataSet.lineWidth = 3
    //
    //        // small circles
    //        dataSet.drawCirclesEnabled = true
    //        dataSet.circleRadius = 4
    //        dataSet.setCircleColor(.systemCyan)
    //        dataSet.circleHoleColor = .white
    //        dataSet.circleHoleRadius = 2
    //
    //        // gradient
    //        let gradientColors = [
    //            UIColor.systemCyan.withAlphaComponent(0.7).cgColor,
    //            UIColor.clear.cgColor
    //        ] as CFArray
    //
    //        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: nil)!
    //
    //        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
    //        dataSet.drawFilledEnabled = true
    //
    //        dataSet.drawHorizontalHighlightIndicatorEnabled = false
    //        dataSet.highlightColor = .white
    //
    //        let data = LineChartData(dataSet: dataSet)
    //        data.setDrawValues(false)
    //
    //        moodChartView.data = data
    //
    //        // set formatter
    //        moodChartView.xAxis.valueFormatter = WeekFormatter(labels: labels)
    //
    //        // bubble marker
    //        let marker = MoodBubbleMarker()
    //        marker.chartView = moodChartView
    //        moodChartView.marker = marker
    //    }
    func setData() {
        if moodLogs.isEmpty {
            moodChartView.data = nil
            moodChartView.setNeedsDisplay()
            return
        }
        
        let sortedLogs = moodLogs.sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        var entries: [ChartDataEntry] = []
        var dayLabels: [String] = []
        
        // ✅ FIX: Only show day label for FIRST entry of each day
        // repeated days get empty string → no duplicate labels on x-axis
        var lastDayLabel = ""
        
        for (index, log) in sortedLogs.enumerated() {
            entries.append(ChartDataEntry(x: Double(index), y: Double(log.mood)))
            
            if let date = log.date {
                let dayStr = dayFormatter.string(from: date)
                if dayStr != lastDayLabel {
                    dayLabels.append(dayStr)   // ✅ new day → show label
                    lastDayLabel = dayStr
                } else {
                    dayLabels.append("")        // ✅ same day → hide label
                }
            } else {
                dayLabels.append("")
            }
        }
        
        let dataSet = LineChartDataSet(entries: entries)
        dataSet.mode = .cubicBezier
        dataSet.cubicIntensity = 0.25
        dataSet.setColor(.systemCyan)
        dataSet.lineWidth = 3
        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 4
        dataSet.setCircleColor(.systemCyan)
        dataSet.circleHoleColor = .white
        dataSet.circleHoleRadius = 2
        
        let gradientColors = [
            UIColor.systemCyan.withAlphaComponent(0.7).cgColor,
            UIColor.clear.cgColor
        ] as CFArray
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: nil)!
        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
        dataSet.drawFilledEnabled = true
        dataSet.fillFormatter = DefaultFillFormatter { _, _ in 0.6 } // ✅ fill starts at axis min
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.highlightColor = .white
        
        let data = LineChartData(dataSet: dataSet)
        data.setDrawValues(false)
        moodChartView.data = data
        
        moodChartView.xAxis.valueFormatter = WeekFormatter(labels: dayLabels)
        moodChartView.xAxis.axisMinimum = -0.3
        moodChartView.xAxis.axisMaximum = Double(entries.count - 1) + 0.3
        
        let marker = MoodBubbleMarker()
        marker.chartView = moodChartView
        marker.sortedLogs = sortedLogs
        moodChartView.marker = marker
    }
    
}
    class WeekFormatter: AxisValueFormatter {

    var labels: [String]

    init(labels: [String]) {
        self.labels = labels
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        let index = Int(value)

        if index >= 0 && index < labels.count {
            return labels[index]
        }

        return ""
    }
}
class TimeFormatter: AxisValueFormatter {
    
    var timers: [String]{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        var time: [String] = []
        for i in moodLogs{
            time.append(formatter.string(from: i.date ?? Date()))
        }
        return time
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        let index = Int(value)

        if index >= 0 && index < timers.count {
            return timers[index]
        }

        return ""
    }
}

//
//class MoodBubbleMarker: MarkerView {
//
//    private let label = UILabel()
//    private let padding: CGFloat = 10
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        backgroundColor = UIColor.black.withAlphaComponent(0.85)
//        layer.cornerRadius = 10
//        layer.masksToBounds = true
//
//        label.font = .systemFont(ofSize: 12, weight: .semibold)
//        label.textColor = .white
//        label.textAlignment = .center
//
//        addSubview(label)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError()
//    }
//
//    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
//
//        // Example time labels
//        var times:[String] {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "HH:mm"
//            var time1: [String] = []
//            for i in moodLogs{
//                time1.append(formatter.string(from: i.date ?? Date()))
//            }
//            return time1
//        }
//
//        let index = Int(entry.x)
//        let time = index < times.count ? times[index] : ""
//
//        label.text = "\(time)  Mood \(String(format: "%.1f", entry.y))"
//
//        label.sizeToFit()
//
//        frame.size = CGSize(
//            width: label.frame.width + padding * 2,
//            height: label.frame.height + padding
//        )
//
//        label.center = CGPoint(x: frame.width/2, y: frame.height/2)
//    }
//
//    // FIXES CUTTING ISSUE
//    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
//
//        guard let chart = chartView else {
//            return CGPoint(x: -frame.width/2, y: -frame.height - 10)
//        }
//
//        var offset = CGPoint(x: -frame.width/2, y: -frame.height - 10)
//
//        // LEFT EDGE
//        if point.x + offset.x < 0 {
//            offset.x = -point.x + 5
//        }
//
//        // RIGHT EDGE
//        if point.x + frame.width + offset.x > chart.bounds.width {
//            offset.x = chart.bounds.width - point.x - frame.width - 5
//        }
//
//        // TOP EDGE
//        if point.y + offset.y < 0 {
//            offset.y = 10
//        }
//
//        return offset
//    }
//}
//

class MoodBubbleMarker: MarkerView {

    private let label = UILabel()
    private let padding: CGFloat = 10

    // ✅ All logs sorted same way as entries — index matches entry.x won't work
    // so we match by finding the log at the tapped entry position
    var sortedLogs: [MoodLog] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.85)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        addSubview(label)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {

        // ✅ dataIndex from highlight tells us which entry was tapped
        // This matches the position in sortedLogs exactly
        let index = highlight.dataIndex >= 0 ? highlight.dataIndex : Int(entry.x)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE, d MMM"

        var timeStr = ""
        var dayStr = ""

        if index < sortedLogs.count, let date = sortedLogs[index].date {
            timeStr = timeFormatter.string(from: date)
            dayStr = dayFormatter.string(from: date)
        }

        label.text = "\(dayStr)  \(timeStr)  Mood \(Int(entry.y))"
        label.sizeToFit()

        frame.size = CGSize(
            width: label.frame.width + padding * 2,
            height: label.frame.height + padding
        )
        label.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
    }

    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        guard let chart = chartView else {
            return CGPoint(x: -frame.width / 2, y: -frame.height - 10)
        }
        var offset = CGPoint(x: -frame.width / 2, y: -frame.height - 10)
        if point.x + offset.x < 0 { offset.x = -point.x + 5 }
        if point.x + frame.width + offset.x > chart.bounds.width {
            offset.x = chart.bounds.width - point.x - frame.width - 5
        }
        if point.y + offset.y < 0 { offset.y = 10 }
        return offset
    }
}
