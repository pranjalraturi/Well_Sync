//
//  BarChartCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 04/02/26.
//

import UIKit
import DGCharts

// MARK: - MoodBubbleMarker
class MoodBubbleMarker: MarkerView {
    
    private let label               = UILabel()
    private let padding: CGFloat    = 10
    var xToLog: [Double: MoodLog]   = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor             = UIColor.black.withAlphaComponent(0.85)
        layer.cornerRadius          = 10
        layer.masksToBounds         = true
        label.font                  = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor             = .white
        label.textAlignment         = .center
        addSubview(label)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        
        let timeFormatter           = DateFormatter()
        timeFormatter.dateFormat    = "HH:mm"
        
        let dayFormatter            = DateFormatter()
        dayFormatter.dateFormat     = "EEE, d MMM"
        
        var timeStr                 = ""
        var dayStr                  = ""
        var moodVal                 = Int(entry.y)
        
        // ── Lookup by entry.x — always correct regardless of dataIndex ────────
        if let log = xToLog[entry.x] {
            timeStr                 = timeFormatter.string(from: log.date)
            dayStr                  = dayFormatter.string(from: log.date)
            moodVal                 = Int(log.mood)
        }
        
        label.text                  = "\(dayStr)   \(timeStr)   Mood \(moodVal)"
        label.sizeToFit()
        
        frame.size                  = CGSize(
            width:  label.frame.width + padding * 2,
            height: label.frame.height + padding
        )
        label.center                = CGPoint(x: frame.width / 2, y: frame.height / 2)
        
        // ── Clamp offset so bubble never crosses chart boundaries ─────────────
        guard let chart = chartView else {
            self.offset = CGPoint(x: -frame.width / 2, y: -frame.height - 12)
            return
        }
        
        let chartWidth              = chart.bounds.width
        let bubbleW                 = frame.width
        let bubbleH                 = frame.height
        let gap: CGFloat            = 12
        let dotX                    = highlight.xPx
        let dotY                    = highlight.yPx
        
        var offsetX                 = -bubbleW / 2
        var offsetY                 = -bubbleH - gap
        
        let projectedLeft           = dotX + offsetX
        let projectedRight          = dotX + offsetX + bubbleW
        
        if projectedLeft < 4 {
            offsetX                 = -dotX + 4
        } else if projectedRight > chartWidth - 4 {
            offsetX                 = chartWidth - dotX - bubbleW - 4
        }
        
        if dotY + offsetY < 4 {
            offsetY                 = gap
        }
        
        self.offset                 = CGPoint(x: offsetX, y: offsetY)
    }
}

// MARK: - MoodChartCollectionViewCell
class MoodChartCollectionViewCell: UICollectionViewCell, ChartViewDelegate {
    
    @IBOutlet weak var moodChartView: LineChartView!
    
    var moodLogs: [MoodLog] = [] {
        didSet { setData() }
    }
    
    var isWeekly: Bool = true {
        didSet {
            setupChart()
            setData()
        }
    }
    
    private var detailedEntries: [ChartDataEntry]   = []
    private let marker                              = MoodBubbleMarker()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupChart()
        setData()
    }
    
    // MARK: - Setup
    func setupChart() {
        
        moodChartView.delegate              = self
        marker.chartView                    = moodChartView
        moodChartView.marker                = marker
        
        // ── X-Axis ──────────────────────────────────────────────────────────
        // Labels are set dynamically in setData() from real dates
        let xAxis                           = moodChartView.xAxis
        xAxis.labelPosition                 = .bottom
        xAxis.granularity                   = 1
        xAxis.drawGridLinesEnabled          = false
        
        // ── Left Y-Axis ──────────────────────────────────────────────────────
        let leftAxis                        = moodChartView.leftAxis
        leftAxis.axisMinimum                = 0.0
        leftAxis.axisMaximum                = 6.0
        leftAxis.granularity                = 1
        leftAxis.drawGridLinesEnabled       = true
        
        moodChartView.rightAxis.enabled     = false
        moodChartView.legend.enabled                = true
        moodChartView.chartDescription.enabled      = false
        moodChartView.setScaleEnabled(false)
        moodChartView.pinchZoomEnabled              = false
        moodChartView.doubleTapToZoomEnabled        = false
        moodChartView.highlightPerTapEnabled        = true
    }
    
    // MARK: - Data
    // MARK: - Data
    func setData() {
        
        let totalDays   = isWeekly ? 7 : 30
        let calendar    = Calendar.current
        let today       = calendar.startOfDay(for: Date())
        
        // ── Step 1: Build window dates ────────────────────────────────────────
        let dayDates: [Date] = (0..<totalDays).compactMap { offset in
            calendar.date(byAdding: .day, value: -(totalDays - 1 - offset), to: today)
        }
        
        // ── Step 2: Generate labels from actual dayDates ───────────────────────
        // Weekly → "Mon", "Tue" etc.  Monthly → "Mar 1", "Mar 2" etc.
        let dateFormatter           = DateFormatter()
        dateFormatter.dateFormat    = isWeekly ? "EEE" : "d"
        let dayLabels               = dayDates.map { dateFormatter.string(from: $0) }
        
        // ── Step 3: Update X-Axis with correct labels ─────────────────────────
        let xAxis                   = moodChartView.xAxis
        xAxis.valueFormatter        = IndexAxisValueFormatter(values: dayLabels)
        xAxis.axisMinimum           = -0.5
        xAxis.axisMaximum           = Double(totalDays) - 0.5
        
        // ── Step 4: Filter moodLogs within window ─────────────────────────────
        guard let windowStart   = dayDates.first,
              let windowEnd     = calendar.date(byAdding: .day, value: 1, to: today)
        else { return }
        
        let filtered = moodLogs.filter {
            $0.date >= windowStart && $0.date < windowEnd
        }
        
        guard !filtered.isEmpty else {
            moodChartView.data = nil
            moodChartView.notifyDataSetChanged()
            return
        }
        
        // ── Step 5: Group logs by day index ───────────────────────────────────
        var perDayValues: [Int: [(Double, MoodLog)]] = [:]
        for log in filtered {
            let logDayStart = calendar.startOfDay(for: log.date)
            if let idx = dayDates.firstIndex(of: logDayStart) {
                perDayValues[idx, default: []].append((Double(log.mood), log))
            }
        }
        
        // ── Step 6: Build ChartDataEntry + x → MoodLog dictionary ────────────
        var entries: [(ChartDataEntry, MoodLog)] = []
        
        for (dayIndex, pairs) in perDayValues {
            let n = pairs.count
            for (idx, (value, log)) in pairs.enumerated() {
                let t: Double   = n == 1 ? 0.5 : Double(idx) / Double(n - 1)
                let x           = Double(dayIndex) - 0.1 + 0.2 * t
                let entry       = ChartDataEntry(x: x, y: value)
                entries.append((entry, log))
            }
        }
        
        entries.sort { $0.0.x < $1.0.x }
        
        detailedEntries         = entries.map { $0.0 }
        
        var xToLog: [Double: MoodLog] = [:]
        for (entry, log) in entries {
            xToLog[entry.x]     = log
        }
        marker.xToLog           = xToLog
        
        // ── Step 7: Build LineChartDataSet ────────────────────────────────────
        let dataSet                         = LineChartDataSet(entries: detailedEntries, label: "Mood logs")
        dataSet.mode                        = .linear
        dataSet.lineWidth                   = 1.5
        dataSet.setColor(.systemBlue)
        dataSet.setCircleColor(.systemBlue)
        dataSet.circleRadius                = 4.0
        dataSet.circleHoleRadius            = 2.0
        dataSet.circleHoleColor             = .systemBackground
        dataSet.drawCirclesEnabled          = true
        dataSet.drawValuesEnabled           = false
        dataSet.highlightEnabled            = true
        dataSet.highlightColor              = .systemOrange
        dataSet.highlightLineWidth          = 1.5
        dataSet.drawFilledEnabled           = false
        
        // ── Step 8: Attach & animate ──────────────────────────────────────────
        let data                            = LineChartData(dataSet: dataSet)
        moodChartView.data                  = data
        moodChartView.notifyDataSetChanged()
        moodChartView.animate(xAxisDuration: 0.4, yAxisDuration: 0.6, easingOption: .easeOutQuart)
    }
    
    // MARK: - ChartViewDelegate
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        moodChartView.highlightValues(nil)
    }
}
