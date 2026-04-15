//
//  GraphCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 06/02/26.
//

import UIKit
import DGCharts
class GraphCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var barChart: BarChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        barchart()
    }
    func barchart() {

//        let values = [5, 3, 1, 2, 3, 4, 5]

        var entries: [BarChartDataEntry] = []

//        for i in 0..<values.count {
//            entries.append(BarChartDataEntry(x: Double(i), y: Double(values[i])))
//        }

        let dataSet = BarChartDataSet(entries: entries)

//        dataSet.colors = [.systemOrange]
        dataSet.drawValuesEnabled = false   // hide value labels
        dataSet.highlightEnabled = false

        let data = BarChartData(dataSet: dataSet)
        data.barWidth = 0.6

        barChart.data = data

        barChart.legend.enabled = false
        barChart.chartDescription.enabled = false

        barChart.xAxis.enabled = false
        barChart.leftAxis.enabled = false
        barChart.rightAxis.enabled = false

        barChart.drawGridBackgroundEnabled = false
        barChart.drawBarShadowEnabled = false

        barChart.setScaleEnabled(false)
        barChart.doubleTapToZoomEnabled = false
        barChart.pinchZoomEnabled = false
        barChart.highlightPerTapEnabled = false

        barChart.minOffset = 0
        barChart.extraTopOffset = 0
        barChart.extraBottomOffset = 0
        barChart.extraLeftOffset = 0
        barChart.extraRightOffset = 0

        barChart.animate(yAxisDuration: 0.8)
    }

    func configure(with logs: [ActivityLog]) {
        barChart.clear()

        let calendar = Calendar.current
        let now = Date()

        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return }

        // Step 1 — Sum durations per day (Sun=0 ... Sat=6)
        var dailyValues = Array(repeating: 0.0, count: 7)
        for log in logs {
            if log.date >= weekInterval.start && log.date < weekInterval.end {
                let index = calendar.component(.weekday, from: log.date) - 1
                dailyValues[index] += Double(log.duration ?? 0)
            }
        }

        // Step 2 — Determine placeholder height for zero days
        // Use 6% of the max value, with a sensible fallback of 1.0 * 0.06 : 1.0
        let maxValue = dailyValues.max() ?? 0
        let placeholder = maxValue > 0 ? maxValue : 1.0 

        // Step 3 — Build entries + per-bar color array
        var entries: [BarChartDataEntry] = []
        var colors: [UIColor] = []

        for i in 0..<7 {
            if dailyValues[i] > 0 {
                entries.append(BarChartDataEntry(x: Double(i), y: dailyValues[i]))
                colors.append(.systemOrange)           // ✅ real data → orange
            } else {
                entries.append(BarChartDataEntry(x: Double(i), y: placeholder))
                colors.append(.systemGray5)            // ✅ no data → light gray nub
            }
        }

        // Step 4 — Build dataset with per-bar colors
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = colors                        // ← DGCharts maps colors[i] to entries[i]
        dataSet.drawValuesEnabled = false
        dataSet.highlightEnabled = false

        let data = BarChartData(dataSet: dataSet)
        data.barWidth = 0.6

        // Step 5 — Fix the Y-axis so placeholder bars don't inflate the scale
        barChart.leftAxis.axisMinimum = 0
        if maxValue > 0 {
            barChart.leftAxis.axisMaximum = maxValue * 1.1  // 10% headroom above tallest bar
        }

        barChart.data = data
        barChart.notifyDataSetChanged()
        barChart.animate(yAxisDuration: 0.5)
    }
}
