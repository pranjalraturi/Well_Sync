//
//  VitalsBarCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 07/02/26.
//

import UIKit
import DGCharts

class VitalsBarCollectionViewCell: UICollectionViewCell {

    enum MetricType {
        case sleep   // hours per day
        case steps   // steps per day
    }

    private var metric: MetricType = .sleep
    private var weeklyValues: [Double]? // optional injected data (7 values)
    var item:[(icon:String,ColorFill:UIColor)] = [
        ("powersleep",.systemIndigo),
        ("shoeprints.fill",.systemOrange)
    ]
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var iconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 16
        backgroundColor = UIColor.secondarySystemBackground
        barChartView.backgroundColor = .clear
        
    }
    func configure(index:Int){
        if index == 1{
            iconImageView.image = UIImage(systemName: item[0].icon)
            iconImageView.tintColor = item[0].ColorFill
            showBarChart(index: index)
        }
        else if index == 2{
            iconImageView.image = UIImage(systemName: item[1].icon)
            iconImageView.tintColor = item[1].ColorFill
            showBarChart(index: index)
        }
    }
    func showBarChart(index:Int) {

        // MARK: - Data
        let values: [Double]
        if let provided = weeklyValues, provided.count == 7 {
            values = provided
        }
        else {
            switch metric {
            case .sleep:
                values = [2.5, 6.0, 3.0, 4.0, 6.5, 8.2, 7.8]
            case .steps:
                values = [4500, 8200, 6500, 12000, 9800, 3000, 7600]
            }
        }

        let maxValue = max(values.max() ?? 1, 1)

        // MARK: - Labels (Mon Tue Wed style)
        let formatter = DateFormatter()
        formatter.dateFormat = "E"

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        let labels = (0..<7).reversed().compactMap {
            formatter.string(from: cal.date(byAdding: .day, value: -$0, to: today)!)
        }

        // MARK: - Entries
        var fgEntries: [BarChartDataEntry] = []
        var bgEntries: [BarChartDataEntry] = []

        for i in 0..<values.count {
            fgEntries.append(.init(x: Double(i), y: values[i]))
            bgEntries.append(.init(x: Double(i), y: maxValue))
        }

        // MARK: - Colors
        let fgColor = item[index-1].ColorFill
        let bgColor = item[index-1].ColorFill.withAlphaComponent(0.12)

        // MARK: - Background bars (ghost)
        let fgSet = BarChartDataSet(entries: fgEntries, label: "")
        fgSet.colors = [fgColor]
        fgSet.drawValuesEnabled = false
        fgSet.highlightEnabled = false
        let bgSet = BarChartDataSet(entries: bgEntries, label: "")
        bgSet.colors = [bgColor]
        bgSet.drawValuesEnabled = false
        bgSet.highlightEnabled = false
        
        let data = BarChartData(dataSets: [bgSet, fgSet])

        data.barWidth = 0.65

        barChartView.data = data

        // MARK: - Chart styling
        barChartView.legend.enabled = false
        barChartView.chartDescription.enabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.setScaleEnabled(false)

        barChartView.drawGridBackgroundEnabled = false
        barChartView.drawBordersEnabled = false

        // remove ALL axes lines
        barChartView.leftAxis.enabled = false
        barChartView.rightAxis.enabled = false

        // MARK: - X Axis
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.labelTextColor = .secondaryLabel
        xAxis.granularity = 1
        xAxis.centerAxisLabelsEnabled = false
        xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)

        // spacing like screenshot
        barChartView.setExtraOffsets(left: 12, top: 12, right: 12, bottom: 6)

        // MARK: - Y range
        barChartView.rightAxis.axisMinimum = 0
        barChartView.animate(yAxisDuration: 1.0)
    }

}

