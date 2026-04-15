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
        let calendar = Calendar.current
        let now = Date()
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return }
        
        var dailyCounts = Array(repeating: 0, count: 7)
        
        for log in logs {
            if log.date >= weekInterval.start && log.date <= weekInterval.end {
                let weekday = calendar.component(.weekday, from: log.date)
                let index = (weekday + 5) % 6   // convert to Mon=0...Sun=6
                dailyCounts[index] += 1
            }
        }
        
        var entries: [BarChartDataEntry] = []
        
        for i in 0..<7 {
            entries.append(BarChartDataEntry(x: Double(i), y: Double(dailyCounts[i])))
        }
        
        let dataSet = BarChartDataSet(entries: entries)
        
        dataSet.colors = [.systemOrange]
        
        dataSet.drawValuesEnabled = false
        dataSet.highlightEnabled = false
        
        let data = BarChartData(dataSet: dataSet)
        data.barWidth = 0.6
        
        barChart.data = data
        barChart.notifyDataSetChanged()
    }
}
