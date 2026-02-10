//
//  VitalsCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 07/02/26.
//

import UIKit
import DGCharts

protocol VitalsRangeNavigating: AnyObject {
    func didTapPrevRange()
    func didTapNextRange()
}

class VitalsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var nextrangeButton: UIButton!
    @IBOutlet weak var prevRangeButton: UIButton!

    weak var rangeDelegate: VitalsRangeNavigating?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 16
        // chart will be configured by controller via configure(rangeText:xLabels:points:)
    }

    func configure(rangeText: String, xLabels: [String], points: [Double]) {
        rangeLabel.text = rangeText
        // Build line chart from provided points and labels
        var entries: [ChartDataEntry] = []
        for (index, rate) in points.enumerated() {
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
        let xAxis = lineChart.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: xLabels)
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 1
        xAxis.labelTextColor = .secondaryLabel
        xAxis.labelFont = .systemFont(ofSize: 13, weight: .medium)
        xAxis.drawAxisLineEnabled = false
        let leftAxis = lineChart.leftAxis
        leftAxis.enabled = false
        let rightAxis = lineChart.rightAxis
        rightAxis.enabled = false
        lineChart.legend.enabled = false
        lineChart.chartDescription.enabled = false
        lineChart.backgroundColor = .clear
    }

    @IBAction func nextRangeTapped(_ sender: UIButton) {
        rangeDelegate?.didTapNextRange()
    }
    
    @IBAction func prevRangeTapped(_ sender: UIButton) {
        rangeDelegate?.didTapPrevRange()
    }

}

