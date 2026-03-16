////
////  MoodCountCollectionViewCell.swift
////  wellSync
////
////  Created by Vidit Agarwal on 04/02/26.
////
//
//import UIKit
//import DGCharts
//
//class MoodCountCollectionViewCell: UICollectionViewCell,ChartViewDelegate {
//
//    @IBOutlet weak var moodChart: PieChartView!
//    
//    var values: [Double] {
//        var temp: [Double] = []
//        for i in moodLogs{
//            temp.append(Double(i.mood))
//        }
//        return temp
//    }
//    let total: Double = Double(moodLogs.count)
//
//        override func awakeFromNib() {
//            super.awakeFromNib()
//            setupMoodChart()
//            moodChart.delegate = self
//        }
//
//        func setupMoodChart() {
//            if total == 0{
//                moodChart.data = nil
//                moodChart.noDataText = "NO DATA AVAILABLE"
//                moodChart.noDataTextColor = .secondaryLabel
//                moodChart.noDataFont = .systemFont(ofSize: 18, weight: .semibold)
//                moodChart.backgroundColor = .clear
//                moodChart.legend.enabled = false
//                moodChart.drawEntryLabelsEnabled = false
//                moodChart.chartDescription.enabled = false
//                moodChart.drawHoleEnabled = false
//                return
//            }
//            var entries: [PieChartDataEntry] = []
//            for v in values {
//                entries.append(PieChartDataEntry(value: v))
//            }
//
//            let dataSet = PieChartDataSet(entries: entries)
//
//            dataSet.colors = [
//                .systemRed,
//                .systemOrange,
//                .systemYellow,
//                .systemGreen,
//                .systemTeal
//            ]
//
//            dataSet.drawValuesEnabled = false
//            dataSet.sliceSpace = 4
//            dataSet.selectionShift = 8
//
//            moodChart.data = PieChartData(dataSet: dataSet)
//
//            // Donut look
//            moodChart.drawHoleEnabled = true
//            moodChart.holeRadiusPercent = 0.70
//            moodChart.transparentCircleRadiusPercent = 0
//            moodChart.holeColor = .secondarySystemBackground
//
//            // Half circle
//            moodChart.maxAngle = 180
//            moodChart.rotationAngle = 180
//            moodChart.rotationEnabled = false
//
//            // Clean UI
//            moodChart.legend.enabled = false
//            moodChart.drawEntryLabelsEnabled = false
//            moodChart.chartDescription.enabled = false
//            moodChart.backgroundColor = .clear
//
//            // Center text
//            setCenterText("\(Int(total))")
//            moodChart.centerTextOffset = CGPoint(x: 0, y: -25)
//
//            moodChart.extraTopOffset = 10
//            moodChart.extraBottomOffset = 6
//
//            moodChart.animate(xAxisDuration: 0.8)
//        }
//
//        func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
//            let value = Int(entry.y)
//            setCenterText("\(value)")
//        }
//
//        func chartValueNothingSelected(_ chartView: ChartViewBase) {
//            setCenterText("\(Int(total))")
//        }
//
//        private func setCenterText(_ text: String) {
//
//            let style = NSMutableParagraphStyle()
//            style.alignment = .center
//
//            let attributes: [NSAttributedString.Key: Any] = [
//                .font: UIFont.systemFont(ofSize: 42, weight: .bold),
//                .foregroundColor: UIColor.label,
//                .paragraphStyle: style
//            ]
//
//            moodChart.centerAttributedText = NSAttributedString(string: text, attributes: attributes)
//        }
//    }
//



//
//  MoodCountCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 04/02/26.
//

import UIKit
import DGCharts

class MoodCountCollectionViewCell: UICollectionViewCell, ChartViewDelegate {

    @IBOutlet weak var moodChart: PieChartView!

    // ✅ Set this from outside — same as CalendarCell1
    var moodLogs: [MoodLog] = [] {
        didSet { setupMoodChart() }
    }

    var values: [Double] {
        return moodLogs.map { Double($0.mood) }
    }

    var total: Double {
        return Double(moodLogs.count)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupMoodChart()
        moodChart.delegate = self
    }

    // MARK: - Mood Color (same scale as CalendarCell1)

    private func moodColor(for mood: Double) -> UIColor {
        switch mood {
        case ..<1.5: return .systemRed
        case 1.5..<2.5: return .systemOrange
        case 2.5..<3.5: return .systemYellow
        case 3.5..<4.5: return UIColor(red: 0.6, green: 0.9, blue: 0.4, alpha: 1) // light green
        default:         return .systemGreen
        }
    }

    // MARK: - Chart Setup

//    func setupMoodChart() {
//        if total == 0 {
//            moodChart.data = nil
//            moodChart.noDataText = "NO DATA AVAILABLE"
//            moodChart.noDataTextColor = .secondaryLabel
//            moodChart.noDataFont = .systemFont(ofSize: 18, weight: .semibold)
//            moodChart.backgroundColor = .clear
//            moodChart.legend.enabled = false
//            moodChart.drawEntryLabelsEnabled = false
//            moodChart.chartDescription.enabled = false
//            moodChart.drawHoleEnabled = false
//            return
//        }
//
//        // ✅ Build entries AND colors together, keyed by mood value
//        var entries: [PieChartDataEntry] = []
//        var colors: [UIColor] = []
//
//        for v in values {
//            entries.append(PieChartDataEntry(value: v))
//            // ✅ Each slice gets the color that matches its mood score
//            colors.append(moodColor(for: v))
//        }
//
//        let dataSet = PieChartDataSet(entries: entries)
//
//        // ✅ Assign per-entry colors instead of a fixed palette
//        dataSet.colors = colors
//
//        dataSet.drawValuesEnabled = false
//        dataSet.sliceSpace = 4
//        dataSet.selectionShift = 8
//
//        moodChart.data = PieChartData(dataSet: dataSet)
//
//        // Donut look
//        moodChart.drawHoleEnabled = true
//        moodChart.holeRadiusPercent = 0.70
//        moodChart.transparentCircleRadiusPercent = 0
//        moodChart.holeColor = .secondarySystemBackground
//
//        // Half circle
//        moodChart.maxAngle = 180
//        moodChart.rotationAngle = 180
//        moodChart.rotationEnabled = false
//
//        // Clean UI
//        moodChart.legend.enabled = false
//        moodChart.drawEntryLabelsEnabled = false
//        moodChart.chartDescription.enabled = false
//        moodChart.backgroundColor = .clear
//
//        // Center text
//        setCenterText("\(Int(total))")
//        moodChart.centerTextOffset = CGPoint(x: 0, y: -25)
//        moodChart.extraTopOffset = 10
//        moodChart.extraBottomOffset = 6
//
//        moodChart.animate(xAxisDuration: 0.8)
//    }

    func setupMoodChart() {
        if total == 0 {
            moodChart.data = nil
            moodChart.noDataText = "NO DATA AVAILABLE"
            moodChart.noDataTextColor = .secondaryLabel
            moodChart.noDataFont = .systemFont(ofSize: 18, weight: .semibold)
            moodChart.backgroundColor = .clear
            moodChart.legend.enabled = false
            moodChart.drawEntryLabelsEnabled = false
            moodChart.chartDescription.enabled = false
            moodChart.drawHoleEnabled = false
            return
        }

        // ✅ Step 1: Group logs by mood level → count per level
        // Result example: [1:1, 2:1, 3:1, 4:1, 5:2]
        var moodCounts: [Int: Int] = [:]
        for log in moodLogs {
            moodCounts[log.mood, default: 0] += 1
        }

        // ✅ Step 2: Sort by mood level ascending (1→2→3→4→5)
        // So colors always appear left→right: red orange yellow lightgreen green
        let sortedMoodLevels = moodCounts.keys.sorted()

        var entries: [PieChartDataEntry] = []
        var colors: [UIColor] = []

        for level in sortedMoodLevels {
            let count = moodCounts[level]!

            // ✅ Step 3: value = count of logs at this level (not the mood score)
            // mood 5 logged 2x → value = 2.0 → double slice area
            entries.append(PieChartDataEntry(value: Double(count)))
            colors.append(moodColor(for: Double(level)))
        }

        let dataSet = PieChartDataSet(entries: entries)
        dataSet.colors = colors
        dataSet.drawValuesEnabled = false
        dataSet.sliceSpace = 4
        dataSet.selectionShift = 8

        moodChart.data = PieChartData(dataSet: dataSet)

        moodChart.drawHoleEnabled = true
        moodChart.holeRadiusPercent = 0.70
        moodChart.transparentCircleRadiusPercent = 0
        moodChart.holeColor = .secondarySystemBackground

        moodChart.maxAngle = 180
        moodChart.rotationAngle = 180
        moodChart.rotationEnabled = false

        moodChart.legend.enabled = false
        moodChart.drawEntryLabelsEnabled = false
        moodChart.chartDescription.enabled = false
        moodChart.backgroundColor = .clear

        setCenterText("\(Int(total))")
        moodChart.centerTextOffset = CGPoint(x: 0, y: -25)
        moodChart.extraTopOffset = 10
        moodChart.extraBottomOffset = 6

        moodChart.animate(xAxisDuration: 0.8)
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        setCenterText("\(Int(entry.y))")
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        setCenterText("\(Int(total))")
    }

    private func setCenterText(_ text: String) {
        let style = NSMutableParagraphStyle()
        style.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 42, weight: .bold),
            .foregroundColor: UIColor.label,
            .paragraphStyle: style
        ]

        moodChart.centerAttributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
