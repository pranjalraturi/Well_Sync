//
//  VitalsBarCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 07/02/26.
//

import UIKit
import DGCharts

protocol VitalsBarRangeNavigating: AnyObject {
    func didTapPrevBarRange(for index: Int)
    func didTapNextBarRange(for index: Int)
}


class VitalsBarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var chartRangeLabel: UILabel!
    @IBOutlet weak var ValueLabel: UILabel!
    
    private var hasAnimated = false

        enum DisplayRange {
            case weekly
            case monthly
        }

        enum MetricType {
            case sleep
            case steps
        }

        weak var rangeDelegate: VitalsBarRangeNavigating?

        private var displayRange: DisplayRange = .weekly
        private var windowOffset: Int = 0

        private(set) var metric: MetricType!
        private(set) var barIndex: Int = 0

        private let item: [(icon: String, color: UIColor)] = [
            ("powersleep", .systemIndigo),
            ("shoeprints.fill", .systemOrange)
        ]

        override func awakeFromNib() {
            super.awakeFromNib()
            layer.cornerRadius = 16
            backgroundColor = .secondarySystemBackground
            barChartView.backgroundColor = .clear
        }

        func configure(
            barIndex: Int,
            metric: MetricType,
            range: DisplayRange,
            offset: Int
        ) {
            self.barIndex = barIndex
            self.metric = metric
            self.displayRange = range
            self.windowOffset = offset

            let visual = metric == .sleep ? item[0] : item[1]
            iconImageView.image = UIImage(systemName: visual.icon)
            iconImageView.tintColor = visual.color

            showBarChart()
        }

        private func showBarChart() {

            let calendar = Calendar.current
            let today = Date()

            let values: [Double]

            switch displayRange {
            case .weekly:
                values = metric == .sleep
                    ? (0..<7).map { _ in Double.random(in: 4...9) }
                    : (0..<7).map { _ in Double.random(in: 4000...12000) }

            case .monthly:
                values = metric == .sleep
                    ? (0..<4).map { _ in Double.random(in: 30...60) }
                    : (0..<4).map { _ in Double.random(in: 40000...80000) }
            }

            let maxValue = max(values.max() ?? 1, 1)

            var labels: [String] = []

            switch displayRange {
            case .weekly:
                let start = calendar.dateInterval(of: .weekOfYear, for: today)!.start
                let target = calendar.date(byAdding: .weekOfYear, value: windowOffset, to: start)!
                let formatter = DateFormatter()
                formatter.dateFormat = "E"

                for i in 0..<7 {
                    let date = calendar.date(byAdding: .day, value: i, to: target)!
                    labels.append(formatter.string(from: date))
                }

                let end = calendar.date(byAdding: .day, value: 6, to: target)!
                formatter.dateFormat = "MMM d"
                chartRangeLabel.text = "\(formatter.string(from: target)) – \(formatter.string(from: end))"

            case .monthly:
                labels = ["W1", "W2", "W3", "W4"]
                let start = calendar.dateInterval(of: .month, for: today)!.start
                let target = calendar.date(byAdding: .month, value: windowOffset, to: start)!
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM yyyy"
                chartRangeLabel.text = formatter.string(from: target)
            }

            let fgEntries = values.enumerated().map {
                BarChartDataEntry(x: Double($0.offset), y: $0.element)
            }

            let bgEntries = values.indices.map {
                BarChartDataEntry(x: Double($0), y: maxValue)
            }

            let fgColor = metric == .sleep ? item[0].color : item[1].color
            let bgColor = fgColor.withAlphaComponent(0.12)

            let fgSet = BarChartDataSet(entries: fgEntries)
            fgSet.colors = [fgColor]
            fgSet.drawValuesEnabled = false
            fgSet.highlightEnabled = false

            let bgSet = BarChartDataSet(entries: bgEntries)
            bgSet.colors = [bgColor]
            bgSet.drawValuesEnabled = false
            bgSet.highlightEnabled = false

            let data = BarChartData(dataSets: [bgSet, fgSet])
            data.barWidth = 0.65

            barChartView.data = data
            barChartView.legend.enabled = false
            barChartView.chartDescription.enabled = false
            barChartView.doubleTapToZoomEnabled = false
            barChartView.pinchZoomEnabled = false
            barChartView.setScaleEnabled(false)

            barChartView.leftAxis.enabled = false
            barChartView.rightAxis.enabled = false

            let xAxis = barChartView.xAxis
            xAxis.labelPosition = .bottom
            xAxis.drawGridLinesEnabled = false
            xAxis.drawAxisLineEnabled = false
            xAxis.granularity = 1
            xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)

            barChartView.setExtraOffsets(left: 12, top: 12, right: 12, bottom: 6)

            if !hasAnimated {
                barChartView.animate(yAxisDuration: 1.0)
                hasAnimated = true
            }
        }

        @IBAction func nextRangeTapped(_ sender: UIButton) {
            rangeDelegate?.didTapNextBarRange(for: barIndex)
        }

        @IBAction func prevRangeTapped(_ sender: UIButton) {
            rangeDelegate?.didTapPrevBarRange(for: barIndex)
        }
}
