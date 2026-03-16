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
        
        
        // Y Axis
        let leftAxis = moodChartView.leftAxis
        leftAxis.labelTextColor = .lightGray
        leftAxis.gridColor = UIColor.darkGray.withAlphaComponent(0.3)

        moodChartView.rightAxis.enabled = false

        // highlight line like the image
        moodChartView.highlightPerTapEnabled = true
        moodChartView.xAxis.granularity = 1
        moodChartView.xAxis.valueFormatter = TimeFormatter()
        moodChartView.extraTopOffset = 20
        moodChartView.setViewPortOffsets(left: 20, top: 30, right: 20, bottom: 20)
    }

    func setData() {

        // mood logs across a week (multiple per day)
        var weekMoodLogs: [[Double]] {
            var temp : [Double] = []
            for i in moodLogs{
                temp.append(Double(i.mood))
            }
            return [temp]
        }

        var entries: [ChartDataEntry] = []
        var labels: [String] = []

        let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]

        var index: Double = 0

        for day in 0..<weekMoodLogs.count {

            for mood in weekMoodLogs[day] {

                entries.append(ChartDataEntry(x: index, y: mood))

                labels.append(days[day])   // label for x axis

                index += 1
            }
        }

        let dataSet = LineChartDataSet(entries: entries)

        dataSet.mode = .cubicBezier
        dataSet.cubicIntensity = 0.25

        dataSet.setColor(.systemCyan)
        dataSet.lineWidth = 3

        // small circles
        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 4
        dataSet.setCircleColor(.systemCyan)
        dataSet.circleHoleColor = .white
        dataSet.circleHoleRadius = 2

        // gradient
        let gradientColors = [
            UIColor.systemCyan.withAlphaComponent(0.7).cgColor,
            UIColor.clear.cgColor
        ] as CFArray

        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: nil)!

        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
        dataSet.drawFilledEnabled = true

        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.highlightColor = .white

        let data = LineChartData(dataSet: dataSet)
        data.setDrawValues(false)

        moodChartView.data = data

        // set formatter
        moodChartView.xAxis.valueFormatter = WeekFormatter(labels: labels)

        // bubble marker
        let marker = MoodBubbleMarker()
        marker.chartView = moodChartView
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


class MoodBubbleMarker: MarkerView {

    private let label = UILabel()
    private let padding: CGFloat = 10

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

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {

        // Example time labels
        var times:[String] {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            var time1: [String] = []
            for i in moodLogs{
                time1.append(formatter.string(from: i.date ?? Date()))
            }
            return time1
        }

        let index = Int(entry.x)
        let time = index < times.count ? times[index] : ""

        label.text = "\(time)  Mood \(String(format: "%.1f", entry.y))"

        label.sizeToFit()

        frame.size = CGSize(
            width: label.frame.width + padding * 2,
            height: label.frame.height + padding
        )

        label.center = CGPoint(x: frame.width/2, y: frame.height/2)
    }

    // FIXES CUTTING ISSUE
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {

        guard let chart = chartView else {
            return CGPoint(x: -frame.width/2, y: -frame.height - 10)
        }

        var offset = CGPoint(x: -frame.width/2, y: -frame.height - 10)

        // LEFT EDGE
        if point.x + offset.x < 0 {
            offset.x = -point.x + 5
        }

        // RIGHT EDGE
        if point.x + frame.width + offset.x > chart.bounds.width {
            offset.x = chart.bounds.width - point.x - frame.width - 5
        }

        // TOP EDGE
        if point.y + offset.y < 0 {
            offset.y = 10
        }

        return offset
    }
}
