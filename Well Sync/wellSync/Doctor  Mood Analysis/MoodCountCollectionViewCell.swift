
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

    var moodLogs: [MoodLog] = [] {
        didSet { setupMoodChart() }
    }

    var values: [Double] {
        return moodLogs.map { Double($0.mood) }
    }

    var total: Double {
        return Double(moodLogs.count)
    }
    var isWeekly = true{
        didSet{
            setupMoodChart()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        style(self)
        setupMoodChart()
        moodChart.delegate = self
    }


    private func moodColor(for mood: Double) -> UIColor {
        let idx = Int(round(mood)) - 1
        let colors = MoodColors.shared.colors
        guard idx >= 0 && idx < colors.count else {
            return colors[2]
        }
        return colors[idx]
    }

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

        var moodCounts: [Int: Int] = [:]
        for log in moodLogs {
            moodCounts[log.mood, default: 0] += 1
        }

        let sortedMoodLevels = moodCounts.keys.sorted()

        var entries: [PieChartDataEntry] = []
        var colors: [UIColor] = []

        for level in sortedMoodLevels {
            let count = moodCounts[level]!

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
