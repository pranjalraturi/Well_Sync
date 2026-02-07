//
//  VitalsCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 07/02/26.
//

import UIKit
import DGCharts
class VitalsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lineChart: LineChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 16
        showLineChart()
    }
    func showLineChart(){
        // Example heart rate data for a week (replace with HealthKit data fetching as needed)
        let heartRates: [Double] = [65, 80, 72, 68, 85, 78, 70] // Example values
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        
        var entries: [ChartDataEntry] = []
        for (index, rate) in heartRates.enumerated() {
            entries.append(ChartDataEntry(x: Double(index), y: rate))
        }
        
        let dataSet = LineChartDataSet(entries: entries, label: "")
        dataSet.mode = LineChartDataSet.Mode.horizontalBezier
        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 4
        dataSet.setCircleColor(UIColor.systemBlue)
        dataSet.circleHoleColor = UIColor.white
        dataSet.lineWidth = 2
        dataSet.setColor(UIColor.systemBlue)
        dataSet.drawFilledEnabled = true
        
        let gradientColors: [CGColor] = [UIColor.systemRed.withAlphaComponent(0.25).cgColor, UIColor.clear.cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: [0.0, 1.0])!
        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90.0)
        dataSet.drawHorizontalHighlightIndicatorEnabled = true
        dataSet.drawVerticalHighlightIndicatorEnabled = false
        dataSet.drawValuesEnabled = false

        
        let data = LineChartData(dataSet: dataSet)
        lineChart.data = data

        // X Axis settings
        let xAxis = lineChart.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 1
        xAxis.labelTextColor = .secondaryLabel
        xAxis.labelFont = .systemFont(ofSize: 13, weight: .medium)
        xAxis.drawAxisLineEnabled = false
        
        // Y Axis settings
        let leftAxis = lineChart.leftAxis
        leftAxis.enabled = false
        let rightAxis = lineChart.rightAxis
        rightAxis.enabled = false
        
        // Chart settings
        lineChart.legend.enabled = false
        lineChart.chartDescription.enabled = false
        lineChart.backgroundColor = .clear
    }
}

