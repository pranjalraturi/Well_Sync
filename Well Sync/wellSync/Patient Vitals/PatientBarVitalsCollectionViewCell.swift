////
////  VitalsBarCollectionViewCell.swift
////  wellSync
////
////  Created by Vidit Agarwal on 07/02/26.
////

import UIKit
import DGCharts
import HealthKit

protocol VitalsBarRangeNavigating1: AnyObject {
    func didTapPrevBarRange(for index: Int)
    func didTapNextBarRange(for index: Int)
}

class PatientBarVitalsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var chartRangeLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!

    private var hasAnimated = false

    enum DisplayRange { case weekly, monthly }
    enum MetricType    { case sleep, steps   }

    weak var rangeDelegate: VitalsBarRangeNavigating1?

    private var displayRange: DisplayRange = .weekly
    private var windowOffset: Int = 0
    private(set) var metric: MetricType!
    private(set) var barIndex: Int = 0

    private let hk = AccessHealthKit.healthKit

    // Visual config per metric
    private let visuals: [(icon: String, color: UIColor)] = [
        ("powersleep",    .systemIndigo),   // sleep
        ("shoeprints.fill", .systemOrange)  // steps
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius  = 16
        backgroundColor     = .secondarySystemBackground
        barChartView.backgroundColor = .clear
    }

    // MARK: - Configure (called from ViewController)

    func configure(barIndex: Int, metric: MetricType, range: DisplayRange, offset: Int) {
        self.barIndex     = barIndex
        self.metric       = metric
        self.displayRange = range
        self.windowOffset = offset

        let visual = metric == .sleep ? visuals[0] : visuals[1]
        iconImageView.image    = UIImage(systemName: visual.icon)
        iconImageView.tintColor = visual.color
        unitLabel.text         = metric == .sleep ? "hrs" : "steps"
        valueLabel.text        = "..."  // will update after fetch

        fetchDataAndShowChart()
    }

    // MARK: - Fetch Real HealthKit Data

    private func fetchDataAndShowChart() {
        let (startDate, endDate, labels) = buildDateRange()

        if metric == .sleep {
            // Fetch sleep data
            hk.getSleep(from: startDate, to: endDate) { [weak self] records in
                guard let self = self else { return }

                // Group sleep minutes by day/week
                var grouped = Array(repeating: 0.0, count: labels.count)
                let calendar = Calendar.current

                for record in records {
                    // Skip "In Bed" and "Awake" — only count actual sleep
                    guard record.stage != "In Bed", record.stage != "Awake" else { continue }

                    let index = self.bucketIndex(for: record.startTime, startDate: startDate, calendar: calendar)
                    if index >= 0 && index < grouped.count {
                        grouped[index] += record.durationMinutes / 60.0 // convert to hours
                    }
                }

                // Show total sleep for the range in valueLabel
                let total = grouped.reduce(0, +)
                self.valueLabel.text = String(format: "%.1f", total)

                self.drawBarChart(values: grouped, labels: labels)
            }

        } else {
            // Fetch steps data
            hk.getSteps(from: startDate, to: endDate) { [weak self] stepsByDay in
                guard let self = self else { return }

                var grouped = Array(repeating: 0.0, count: labels.count)
                let calendar = Calendar.current

                for (date, steps) in stepsByDay {
                    let index = self.bucketIndex(for: date, startDate: startDate, calendar: calendar)
                    if index >= 0 && index < grouped.count {
                        grouped[index] += steps
                    }
                }

                // Show total steps for the range in valueLabel
                let total = grouped.reduce(0, +)
                self.valueLabel.text = "\(Int(total))"

                self.drawBarChart(values: grouped, labels: labels)
            }
        }
    }

    // MARK: - Figure out which bar index a date belongs to

    private func bucketIndex(for date: Date, startDate: Date, calendar: Calendar) -> Int {
        switch displayRange {
        case .weekly:
            // Each bar = 1 day → find which day (0–6)
            return calendar.dateComponents([.day], from: startDate, to: date).day ?? -1

        case .monthly:
            // Each bar = 1 week → find which week (0–3)
            return calendar.dateComponents([.weekOfYear], from: startDate, to: date).weekOfYear ?? -1
        }
    }

    // MARK: - Build Date Range + Labels based on displayRange + windowOffset

    private func buildDateRange() -> (startDate: Date, endDate: Date, labels: [String]) {
        let calendar = Calendar.current
        let today    = Date()
        let formatter = DateFormatter()

        switch displayRange {

        case .weekly:
            // Start of the target week (offset by windowOffset weeks)
            let startOfThisWeek = calendar.dateInterval(of: .weekOfYear, for: today)!.start
            let startDate = calendar.date(byAdding: .weekOfYear, value: windowOffset, to: startOfThisWeek)!
            let endDate   = calendar.date(byAdding: .day, value: 7, to: startDate)!

            // Labels: Mon, Tue, Wed ...
            formatter.dateFormat = "E"
            let labels = (0..<7).map { i -> String in
                let date = calendar.date(byAdding: .day, value: i, to: startDate)!
                return formatter.string(from: date)
            }

            // Update range label (e.g. "Apr 1 – Apr 7")
            formatter.dateFormat = "MMM d"
            let endLabel = calendar.date(byAdding: .day, value: 6, to: startDate)!
            chartRangeLabel.text = "\(formatter.string(from: startDate)) – \(formatter.string(from: endLabel))"

            return (startDate, endDate, labels)

        case .monthly:
            // Start of the target month
            let startOfThisMonth = calendar.dateInterval(of: .month, for: today)!.start
            let startDate = calendar.date(byAdding: .month, value: windowOffset, to: startOfThisMonth)!
            let endDate   = calendar.date(byAdding: .month, value: 1, to: startDate)!

            // Labels: W1, W2, W3, W4
            let labels = ["W1", "W2", "W3", "W4"]

            formatter.dateFormat = "MMM yyyy"
            chartRangeLabel.text = formatter.string(from: startDate)

            return (startDate, endDate, labels)
        }
    }

    // MARK: - Draw Bar Chart

    private func drawBarChart(values: [Double], labels: [String]) {
        let maxValue = max(values.max() ?? 1, 1)
        let fgColor  = metric == .sleep ? visuals[0].color : visuals[1].color
        let bgColor  = fgColor.withAlphaComponent(0.12)

        // Foreground bars (actual data)
        let fgEntries = values.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element) }

        // Background bars (full height, just for visual)
        let bgEntries = values.indices.map { BarChartDataEntry(x: Double($0), y: maxValue) }

        let fgSet = BarChartDataSet(entries: fgEntries)
        fgSet.colors = [fgColor]
        fgSet.drawValuesEnabled = false
        fgSet.highlightEnabled  = false

        let bgSet = BarChartDataSet(entries: bgEntries)
        bgSet.colors = [bgColor]
        bgSet.drawValuesEnabled = false
        bgSet.highlightEnabled  = false

        let data = BarChartData(dataSets: [bgSet, fgSet])
        data.barWidth = 0.65

        barChartView.data = data
        barChartView.legend.enabled           = false
        barChartView.chartDescription.enabled = false
        barChartView.doubleTapToZoomEnabled   = false
        barChartView.pinchZoomEnabled         = false
        barChartView.setScaleEnabled(false)
        barChartView.leftAxis.enabled  = false
        barChartView.rightAxis.enabled = false

        let xAxis = barChartView.xAxis
        xAxis.labelPosition         = .bottom
        xAxis.drawGridLinesEnabled  = false
        xAxis.drawAxisLineEnabled   = false
        xAxis.granularity           = 1
        xAxis.valueFormatter        = IndexAxisValueFormatter(values: labels)

        barChartView.setExtraOffsets(left: 12, top: 12, right: 12, bottom: 6)

        if !hasAnimated {
            barChartView.animate(yAxisDuration: 1.0)
            hasAnimated = true
        }
    }

    // MARK: - Button Actions

    @IBAction func nextRangeTapped(_ sender: UIButton) {
        rangeDelegate?.didTapNextBarRange(for: barIndex)
    }

    @IBAction func prevRangeTapped(_ sender: UIButton) {
        rangeDelegate?.didTapPrevBarRange(for: barIndex)
    }
}
