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
    
    let values: [Double] = [2, 2, 4, 3, 3]
    let total: Double = 14
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        dataSet.sliceSpace = 2
        dataSet.selectionShift = 10
        
        moodChart.data = PieChartData(dataSet: dataSet)

        // MARK: Donut look
        moodChart.holeRadiusPercent = 0.70
        moodChart.transparentCircleRadiusPercent = 0

        // MARK: Half circle
        moodChart.maxAngle = 180
        moodChart.rotationAngle = 180
        moodChart.rotationEnabled = false

        // MARK: Hide extras
        moodChart.legend.enabled = false
        moodChart.drawEntryLabelsEnabled = true
        
        // MARK: Fix Center Text (IMPORTANT)
        setCenterText("\(Int(total))")
        
        // 👉 Move text upward for half donut
        moodChart.centerTextOffset = CGPoint(x: 0, y: -25)

        // 👉 Perfect visual centering
        moodChart.extraTopOffset = 10
        moodChart.extraBottomOffset = 6

        moodChart.animate(xAxisDuration: 0.8)
    }
    
    // MARK: - Slice Selected
    func chartValueSelected(_ chartView: ChartViewBase,entry: ChartDataEntry,highlight: Highlight) {
        
        let value = Int(entry.y)
        
        setCenterText("\(value)")
    }

    // MARK: - Deselected
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        setCenterText("\(Int(total))")
    }

    private func setCenterText(_ text: String) {
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [ .font: UIFont.systemFont(ofSize: 42, weight: .bold), .foregroundColor: UIColor.label, .paragraphStyle: style ]

        moodChart.centerAttributedText = NSAttributedString(string: text,attributes: attributes)
    }

}
