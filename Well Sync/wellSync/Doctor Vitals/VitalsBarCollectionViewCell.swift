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
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!

    private var hasAnimated = false

    enum DisplayRange { case weekly, monthly }
    enum MetricType   { case sleep, steps }

    weak var rangeDelegate: VitalsBarRangeNavigating?

    private var displayRange:  DisplayRange = .weekly
    private var windowOffset:  Int = 0
    private(set) var metric:   MetricType!
    private(set) var barIndex: Int = 0
    private var patientID:     UUID?
    var patient: Patient?{
        didSet{
            patientID = patient?.patientID
        }
    }
    private let item: [(icon: String, color: UIColor)] = [
        ("powersleep",    .systemIndigo),
        ("shoeprints.fill", .systemOrange)
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 16
        backgroundColor = .secondarySystemBackground
        barChartView.backgroundColor = .clear
    }

    // ── configure now accepts patientID ──────────────────────────────
    func configure(
        barIndex:  Int,
        metric:    MetricType,
        range:     DisplayRange,
        offset:    Int
    ) {
        self.barIndex    = barIndex
        self.metric      = metric
        self.displayRange = range
        self.windowOffset = offset

        let visual = metric == .sleep ? item[0] : item[1]
        unitLabel.text       = metric == .sleep ? "hrs" : "steps"
        valueLabel.text      = "–"
        iconImageView.image  = UIImage(systemName: visual.icon)
        iconImageView.tintColor = visual.color

        fetchAndRender()
    }

    // ── fetch real data then render ───────────────────────────────────
    private func fetchAndRender() {
        let (startDate, endDate) = dateRange()

        switch metric {
        case .sleep:
            fetchSleepData(from: startDate, to: endDate)
        case .steps:
            fetchStepsData(from: startDate, to: endDate)
        case .none:
            break
        }
    }

    // ── date range based on range + offset ───────────────────────────
    private func dateRange() -> (Date, Date) {
        let calendar = Calendar.current
        let today    = Date()

        switch displayRange {
        case .weekly:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)!.start
            let targetStart = calendar.date(byAdding: .weekOfYear, value: windowOffset, to: startOfWeek)!
            let targetEnd   = calendar.date(byAdding: .day, value: 7, to: targetStart)!
            return (targetStart, targetEnd)

        case .monthly:
            let startOfMonth = calendar.dateInterval(of: .month, for: today)!.start
            let targetStart  = calendar.date(byAdding: .month, value: windowOffset, to: startOfMonth)!
            let targetEnd    = calendar.date(byAdding: .month, value: 1, to: targetStart)!
            return (targetStart, targetEnd)
        }
    }

    // ── SLEEP fetch ───────────────────────────────────────────────────
    private func fetchSleepData(from startDate: Date, to endDate: Date) {
        guard let patientID else { renderChart(values: [], labels: [], startDate: startDate); return }

        Task {
            do {
                let logs = try await AccessSupabase.shared.fetchSleepLog(patient_id: patientID)

                // Filter to selected window
                let filtered = logs.filter {
                    $0.start_time >= startDate && $0.start_time < endDate
                }

                let (values, labels) = aggregate(sleepLogs: filtered, from: startDate)
                let totalHrs = values.reduce(0, +)

                await MainActor.run {
                    valueLabel.text = String(format: "%.1f", totalHrs)
                    renderChart(values: values, labels: labels, startDate: startDate)
                }
            } catch {
                print("❌ Sleep fetch error:", error)
            }
        }
    }

    private func fetchStepsData(from startDate: Date, to endDate: Date) {
        guard let patientID else {
            renderChart(values: [], labels: [], startDate: startDate)
            return
        }

        Task {
            do {
                let calendar = Calendar.current
                let allLogs = try await AccessSupabase.shared.fetchStepsLogs(patient_id: patientID)

                // ✅ Normalize log_date to local timezone BEFORE filtering
                // Both sides must use the same timezone for comparison to work correctly
                let filtered = allLogs.filter {
                    let normalizedDate = calendar.startOfDay(for: $0.log_date)   // local TZ
                    let normalizedStart = calendar.startOfDay(for: startDate)    // local TZ
                    let normalizedEnd = calendar.startOfDay(for: endDate)        // local TZ
                    return normalizedDate >= normalizedStart && normalizedDate < normalizedEnd
                }

                // Build dictionary with normalized keys
                let stepsByDay = Dictionary(
                    uniqueKeysWithValues: filtered.map {
                        (calendar.startOfDay(for: $0.log_date), $0.step_count)
                    }
                )

                let (values, labels) = aggregate(stepsByDay: stepsByDay, from: startDate)
                let totalSteps = values.reduce(0, +)

                await MainActor.run {
                    self.valueLabel.text = "\(Int(totalSteps))"
                    self.renderChart(values: values, labels: labels, startDate: startDate)
                }
            } catch {
                print("❌ Steps fetch error:", error)
            }
        }
    }

    // ── Aggregate sleep logs → [Double] hours per bar ─────────────────
    private func aggregate(sleepLogs: [sleepVital], from startDate: Date) -> ([Double], [String]) {
        let calendar  = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        switch displayRange {
        case .weekly:
            formatter.dateFormat = "E"
            var values: [Double] = Array(repeating: 0, count: 7)
            var labels: [String] = []

            for i in 0..<7 {
                let day = calendar.date(byAdding: .day, value: i, to: startDate)!
                labels.append(formatter.string(from: day))
            }

            for log in sleepLogs {
                let dayStart = calendar.startOfDay(for: log.start_time)
                // which bar index does this belong to?
                let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: startDate), to: dayStart).day ?? 0
                if diff >= 0 && diff < 7 {
                    values[diff] += log.duration_minutes / 60.0   // convert minutes → hours
                }
            }
            return (values, labels)

        case .monthly:
            var values: [Double] = Array(repeating: 0, count: 4)
            let labels = ["W1", "W2", "W3", "W4"]

            for log in sleepLogs {
                let dayStart = calendar.startOfDay(for: log.start_time)
                let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: startDate), to: dayStart).day ?? 0
                let weekIndex = min(diff / 7, 3)
                if weekIndex >= 0 {
                    values[weekIndex] += log.duration_minutes / 60.0
                }
            }
            return (values, labels)
        }
    }
    
    private func aggregate(stepsByDay: [Date: Double], from startDate: Date) -> ([Double], [String]) {

        let calendar = Calendar.current

        switch displayRange {

        case .weekly:
            var values = Array(repeating: 0.0, count: 7)
            var labels: [String] = []

            let formatter = DateFormatter()
            formatter.dateFormat = "E"

            for i in 0..<7 {
                let day = calendar.date(byAdding: .day, value: i, to: startDate)!
                labels.append(formatter.string(from: day))
                values[i] = stepsByDay[calendar.startOfDay(for: day)] ?? 0
            }

            return (values, labels)

        case .monthly:
            var values = Array(repeating: 0.0, count: 4)
            let labels = ["W1", "W2", "W3", "W4"]

            guard let monthInterval = calendar.dateInterval(of: .month, for: startDate) else {
                return (values, labels)
            }

            for (date, steps) in stepsByDay {

                // ❗ ONLY include dates inside THIS month
                guard date >= monthInterval.start && date < monthInterval.end else { continue }

                let weekOfMonth = calendar.component(.weekOfMonth, from: date)

                let index = min(max(weekOfMonth - 1, 0), 3)
                values[index] += steps
            }

            return (values, labels)
        }
    }

    private func renderChart(values: [Double], labels: [String], startDate: Date) {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        switch displayRange {
        case .weekly:
            formatter.dateFormat = "MMM d"
            let endDate = calendar.date(byAdding: .day, value: 6, to: startDate)!
            chartRangeLabel.text = "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
        case .monthly:
            formatter.dateFormat = "MMM yyyy"
            chartRangeLabel.text = formatter.string(from: startDate)
        }

        let maxValue = max(values.max() ?? 0, 1)
        let fgColor = metric == .sleep ? item[0].color : item[1].color
        let bgColor = fgColor.withAlphaComponent(0.12)

        let fgEntries = values.enumerated().map {
            BarChartDataEntry(x: Double($0.offset), y: $0.element)
        }

        let bgEntries = values.indices.map {
            BarChartDataEntry(x: Double($0), y: maxValue)
        }

        let fgSet = BarChartDataSet(entries: fgEntries)
        fgSet.drawValuesEnabled = false
        fgSet.highlightEnabled = false
        fgSet.colors = values.map { $0 > 0 ? fgColor : .clear }

        let bgSet = BarChartDataSet(entries: bgEntries)
        bgSet.drawValuesEnabled = false
        bgSet.highlightEnabled = false
        bgSet.colors = Array(repeating: bgColor, count: bgEntries.count)

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

        barChartView.notifyDataSetChanged()

        if !hasAnimated {
            barChartView.animate(yAxisDuration: 1.0)
            hasAnimated = true
        }
    }
    
    @IBAction func nextRangeTapped(_ sender: UIButton) { rangeDelegate?.didTapNextBarRange(for: barIndex) }
    @IBAction func prevRangeTapped(_ sender: UIButton) { rangeDelegate?.didTapPrevBarRange(for: barIndex) }
}
