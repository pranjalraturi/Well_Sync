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

        let values = [5, 3, 1, 2, 3, 4, 5]

        var entries: [BarChartDataEntry] = []

        for i in 0..<values.count {
            entries.append(BarChartDataEntry(x: Double(i), y: Double(values[i])))
        }

        let dataSet = BarChartDataSet(entries: entries)

        dataSet.colors = [.systemOrange,.systemGray4,.systemGray4,.systemGray4,.systemGray4,.systemGray4,.systemOrange]
        dataSet.drawValuesEnabled = false   // hide value labels
        dataSet.highlightEnabled = false

        let data = BarChartData(dataSet: dataSet)
        data.barWidth = 0.6

        barChart.data = data

        // 🔥 Remove EVERYTHING
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

        // 🔥 remove extra padding
        barChart.minOffset = 0
        barChart.extraTopOffset = 0
        barChart.extraBottomOffset = 0
        barChart.extraLeftOffset = 0
        barChart.extraRightOffset = 0

        barChart.animate(yAxisDuration: 0.8)
    }

}
