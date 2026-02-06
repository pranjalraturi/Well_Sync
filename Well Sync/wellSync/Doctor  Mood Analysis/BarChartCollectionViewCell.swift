//
//  BarChartCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 04/02/26.
//

import UIKit
import DGCharts

class BarChartCollectionViewCell: UICollectionViewCell, ChartViewDelegate{

    @IBOutlet weak var barChart: BarChartView!
    let days = ["Sun","Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let values = [28, 50, 60, 30, 42, 91, 52]
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        barchartGrouped()
    }

//    func barchart() {
//
//        var dataEntry: [BarChartDataEntry] = []
//
//        for i in 0..<days.count {
//            let value = BarChartDataEntry(x: Double(i), y: Double(values[i]))
//            dataEntry.append(value)
//        }
//
//        // MARK: DataSet
//        let dataSet = BarChartDataSet(entries: dataEntry)
//        dataSet.drawValuesEnabled = false
//        dataSet.colors = [
//            .systemRed,
//            .systemRed,
//            .systemYellow,
//            .systemOrange,
//            .systemOrange,
//            .systemGreen,
//            .systemGreen
//        ]
//        dataSet.highlightAlpha = 0.0
//
//        let data = BarChartData(dataSet: dataSet)
//        data.barWidth = 0.5
//
//        barChart.data = data
//
//        // MARK: Marker
//        let marker = BarValueMarker(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
//        marker.chartView = barChart
//        barChart.marker = marker
//
//        barChart.highlightPerTapEnabled = true
//        barChart.highlightPerDragEnabled = false
//
//        // MARK: X Axis
//        let xAxis = barChart.xAxis
//        xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
//        xAxis.granularity = 1
//        xAxis.labelPosition = .bottom
//        xAxis.drawGridLinesEnabled = false
//        xAxis.labelFont = .systemFont(ofSize: 11)
//        xAxis.centerAxisLabelsEnabled = false
//        xAxis.avoidFirstLastClippingEnabled = true
//
//        // ⭐ FIX FOR SUNDAY SHIFT
//        xAxis.axisMinimum = -0.5
//        xAxis.axisMaximum = Double(days.count) - 0.5
//
//        // MARK: Y Axis
//        barChart.leftAxis.enabled = false
//        barChart.rightAxis.drawGridLinesEnabled = false
//
//        // MARK: Style
//        barChart.legend.enabled = false
//        barChart.chartDescription.enabled = false
//        barChart.fitBars = true
//
//        barChart.extraBottomOffset = 8
//        barChart.extraTopOffset = 20
//
//        // MARK: Animation
//        barChart.animate(yAxisDuration: 0.8)
//    }

//    func barchart() {
//
//        let moodValues    = [28, 50, 60, 30, 42, 91, 52]
//        let sleepValues   = [6, 7, 5, 8, 6, 7, 9]
//        let activityValue = [2, 4, 3, 5, 6, 4, 7]
//
//        var moodEntries: [BarChartDataEntry] = []
//        var sleepEntries: [BarChartDataEntry] = []
//        var activityEntries: [BarChartDataEntry] = []
//
//        for i in 0..<days.count {
//            moodEntries.append(BarChartDataEntry(x: Double(i), y: Double(moodValues[i])))
//            sleepEntries.append(BarChartDataEntry(x: Double(i), y: Double(sleepValues[i])))
//            activityEntries.append(BarChartDataEntry(x: Double(i), y: Double(activityValue[i])))
//        }
//
//        // MARK: DataSets
//        let moodSet = BarChartDataSet(entries: moodEntries, label: "Mood")
//        moodSet.setColor(.systemGreen)
//
//        let sleepSet = BarChartDataSet(entries: sleepEntries, label: "Sleep")
//        sleepSet.setColor(.systemBlue)
//
//        let activitySet = BarChartDataSet(entries: activityEntries, label: "Activity")
//        activitySet.setColor(.systemOrange)
//
//        let data = BarChartData(dataSets: [moodSet, sleepSet, activitySet])
//
//        // ⭐ IMPORTANT FOR MULTIPLE BARS
////        let groupSpace = 0.3
////        let barSpace   = 0.05
////        let barWidth   = 0.2
//        
//        moodSet.highlightAlpha = 0.0
//
//        let groupSpace = 0.25
//        let barSpace   = 0.03
//        let barWidth   = 0.22
//
//        data.barWidth = barWidth
//        barChart.data = data
//
//        let groupCount = days.count
//        let startX = 0.0
//
//        let groupWidth = data.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
//
//        barChart.xAxis.axisMinimum = startX
//        barChart.xAxis.axisMaximum = startX + groupWidth * Double(groupCount)
//
//        data.groupBars(fromX: startX, groupSpace: groupSpace, barSpace: barSpace)
//
//        // group bars
////        barChart.xAxis.axisMinimum = startX
////        barChart.xAxis.axisMaximum =
////            startX + Double(groupCount) * (barWidth * 3 + barSpace * 2 + groupSpace)
//        barChart.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
//        barChart.fitBars = true   // ⭐ important
//
//        // MARK: X Axis
//        let xAxis = barChart.xAxis
//        xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
//        xAxis.granularity = 1
//        xAxis.labelPosition = .bottom
//        xAxis.drawGridLinesEnabled = false
//        xAxis.centerAxisLabelsEnabled = true
//
//
//        // MARK: Style
//        barChart.legend.enabled = false
//        barChart.chartDescription.enabled = false
//        barChart.leftAxis.enabled = false
//        barChart.rightAxis.drawGridLinesEnabled = false
//
//        barChart.animate(yAxisDuration: 0.8)
//    }

    
    func barchartGrouped() {

        let days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

        // multiple mood entries per day
        let logsPerDay: [[Double]] = [
            [2, 4,5,8,7,6,9,8,0,6],                // Sun
            [5, 3, 4, 2, 3],       // Mon
            [3, 2, 4],             // Tue
            [1],                   // Wed
            [4, 5],               // Thu
            [5, 5, 4, 3],         // Fri
            [3, 2]                // Sat
        ]

        let maxLogs = logsPerDay.map { $0.count }.max() ?? 0

        var dataSets: [BarChartDataSet] = []

        // create dataset for each possible log position
        for logIndex in 0..<maxLogs {

            var entries: [BarChartDataEntry] = []

            for dayIndex in 0..<days.count {

                let dayLogs = logsPerDay[dayIndex]

                let value = logIndex < dayLogs.count ? dayLogs[logIndex] : 0

                entries.append(BarChartDataEntry(x: Double(dayIndex), y: value))
            }

            let set = BarChartDataSet(entries: entries)

            set.drawValuesEnabled = false
            set.setColor(colorForMoodIndex(logIndex))

            dataSets.append(set)
        }

        let data = BarChartData(dataSets: dataSets)

        let groupSpace = 0.25
        let barSpace   = 0.05
        let barWidth   = 0.12

        data.barWidth = barWidth
        
        let groupCount = days.count
        let startX: Double = 0

        barChart.xAxis.axisMinimum = startX
        barChart.xAxis.axisMaximum = startX + Double(groupCount)

        barChart.xAxis.centerAxisLabelsEnabled = true   // ⭐ REQUIRED

        barChart.data = data

        barChart.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)

        // X axis
        let xAxis = barChart.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        xAxis.granularity = 1
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false

        barChart.leftAxis.axisMinimum = 0
        barChart.rightAxis.enabled = false

        barChart.legend.enabled = false
        barChart.chartDescription.enabled = false

        barChart.animate(yAxisDuration: 0.8)
        
        barChart.leftAxis.enabled = false

        let right = barChart.rightAxis
        right.enabled = true
        right.axisMinimum = 0
        right.drawGridLinesEnabled = true

    }
    func colorForMoodIndex(_ index: Int) -> UIColor {
        let colors: [UIColor] = [
            .systemGreen,
            .systemOrange,
            .systemYellow,
            .systemBlue,
            .systemPurple
        ]
        return colors[index % colors.count]
    }


}
