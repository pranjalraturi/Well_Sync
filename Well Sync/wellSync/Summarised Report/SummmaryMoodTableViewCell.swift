//
//  SummmaryMoodTableViewCell.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 07/02/26.
//

import UIKit
import DGCharts

class SummmaryMoodTableViewCell: UITableViewCell{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sMoodCell", for: indexPath)
        return cell
    }
    
    var items: [String] = []

    @IBOutlet var lineChart:LineChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        showLineChart()
    }
    func showLineChart(){
        // Generate random mood logs for 7 days where each day can have multiple entries (1-5)
        // For demo: each day has 1-5 entries
        var perDayValues: [[Double]] = (0..<7).map { _ in
            let count = Int.random(in: 1...5)
            return (0..<count).map { _ in Double(Int.random(in: 1...5)) }
        }
        
        // Flatten into entries with slight x-offsets within each day so multiple points are visible
        // Day i is centered at x=i; spread points in range [i-0.25, i+0.25]
        var detailedEntries: [ChartDataEntry] = []
        for (dayIndex, values) in perDayValues.enumerated() {
            let n = max(values.count, 1)
            for (idx, value) in values.enumerated() {
                let t = n == 1 ? 0.0 : Double(idx) / Double(n - 1) // 0..1
                let x = Double(dayIndex) - 0.25 + 0.5 * t
                detailedEntries.append(ChartDataEntry(x: x, y: value))
            }
        }
        // Sort by x to connect points chronologically within the week
        detailedEntries.sort { $0.x < $1.x }
        
        // Compute per-day averages for an overlay line
        let avgEntries: [ChartDataEntry] = perDayValues.enumerated().map { (dayIndex, values) in
            let avg = values.reduce(0, +) / Double(values.count)
            return ChartDataEntry(x: Double(dayIndex), y: avg)
        }
        
        // Detailed dataset (multiple points per day)
        let detailedSet = LineChartDataSet(entries: detailedEntries, label: "Mood logs")
        detailedSet.mode = .linear
        detailedSet.lineWidth = 1.5
        detailedSet.setColor(.systemBlue)
        detailedSet.setCircleColor(.systemBlue)
        detailedSet.circleRadius = 2.5
        detailedSet.drawCirclesEnabled = true
        detailedSet.drawValuesEnabled = false
        detailedSet.highlightEnabled = false
        detailedSet.drawFilledEnabled = false
        
        // Average per-day dataset
        let avgSet = LineChartDataSet(entries: avgEntries, label: "Daily average")
        avgSet.mode = .cubicBezier
        avgSet.lineWidth = 2.0
        avgSet.setColor(.systemGreen)
        avgSet.setCircleColor(.systemGreen)
        avgSet.circleRadius = 3
        avgSet.drawCirclesEnabled = true
        avgSet.drawValuesEnabled = false
        avgSet.highlightEnabled = false
        avgSet.drawFilledEnabled = false
        
        // Apply data to chart (both datasets)
        let data = LineChartData(dataSets: [detailedSet, avgSet])
        lineChart.data = data
        
        // Configure x-axis as days of week
        let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let xAxis = lineChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.granularity = 1
        xAxis.axisMinimum = -0.5
        xAxis.axisMaximum = 6.5
        xAxis.drawGridLinesEnabled = false
        xAxis.valueFormatter = IndexAxisValueFormatter(values: dayLabels)
        
        // Configure y-axis for mood range 1..5
        let leftAxis = lineChart.leftAxis
        leftAxis.axisMinimum = 0.0
        leftAxis.axisMaximum = 6.0
        leftAxis.granularity = 1
        leftAxis.drawGridLinesEnabled = true
        lineChart.rightAxis.enabled = false
        
        // General chart styling
        lineChart.legend.enabled = true
        lineChart.chartDescription.enabled = false
        lineChart.setScaleEnabled(false)
        lineChart.pinchZoomEnabled = false
        lineChart.doubleTapToZoomEnabled = false
        
        // Animate for a nicer appearance
        lineChart.animate(xAxisDuration: 0.4, yAxisDuration: 0.6, easingOption: .easeOutQuart)
    }
}
