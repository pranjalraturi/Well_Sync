//
//  MoodCountCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 04/02/26.
//

import UIKit
import DGCharts

class MoodCountCollectionViewCell: UICollectionViewCell,ChartViewDelegate {

    @IBOutlet weak var moodChart: PieChartView!
    
    let values: [Double] = [1, 2, 4, 3, 5]
        let total: Double = 15

        override func awakeFromNib() {
            super.awakeFromNib()
            setupMoodChart()
            moodChart.delegate = self
        }

        func setupMoodChart() {

            var entries: [PieChartDataEntry] = []
            for v in values {
                entries.append(PieChartDataEntry(value: v))
            }

            let dataSet = PieChartDataSet(entries: entries)

            dataSet.colors = [
                .systemRed,
                .systemOrange,
                .systemYellow,
                .systemGreen,
                .systemTeal
            ]

            dataSet.drawValuesEnabled = false
            dataSet.sliceSpace = 4
            dataSet.selectionShift = 8

            moodChart.data = PieChartData(dataSet: dataSet)

            // Donut look
            moodChart.drawHoleEnabled = true
            moodChart.holeRadiusPercent = 0.70
            moodChart.transparentCircleRadiusPercent = 0
            moodChart.holeColor = .secondarySystemBackground   // ⭐ important for dark/light mode

            // Half circle
            moodChart.maxAngle = 180
            moodChart.rotationAngle = 180
            moodChart.rotationEnabled = false

            // Clean UI
            moodChart.legend.enabled = false
            moodChart.drawEntryLabelsEnabled = false
            moodChart.chartDescription.enabled = false
            moodChart.backgroundColor = .clear

            // Center text
            setCenterText("\(Int(total))")
            moodChart.centerTextOffset = CGPoint(x: 0, y: -25)

            moodChart.extraTopOffset = 10
            moodChart.extraBottomOffset = 6

            moodChart.animate(xAxisDuration: 0.8)
        }

        func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
            let value = Int(entry.y)
            setCenterText("\(value)")
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
