////
////  BarChartCollectionViewCell.swift
////  wellSync
////
////  Created by Vidit Agarwal on 04/02/26.
////
//
//import UIKit
//import DGCharts
//
//class MoodChartCollectionViewCell: UICollectionViewCell, ChartViewDelegate{
//
//    @IBOutlet weak var moodChartView: LineChartView!
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        moodChart()
//    }
//    func moodChart(){
//        
//    }
////}
import UIKit
import DGCharts

final class MoodChartCollectionViewCell: UICollectionViewCell, ChartViewDelegate {

    @IBOutlet weak var moodChartView: LineChartView!

    // Keep a reference so formatters/marker aren't deallocated
    private var xAxisFormatter: MoodXAxisFormatter?
    private var markerView: MoodMarkerView?

    override func awakeFromNib() {
        super.awakeFromNib()
        moodChart()
    }

    private func moodChart() {
        moodChartView.delegate = self
        moodChartView.backgroundColor = .clear
        moodChartView.drawGridBackgroundEnabled = false
        moodChartView.drawBordersEnabled = false
        moodChartView.doubleTapToZoomEnabled = false
        moodChartView.pinchZoomEnabled = false
        moodChartView.highlightPerTapEnabled = true
        moodChartView.highlightPerDragEnabled = false
        moodChartView.setScaleEnabled(false)
        moodChartView.animate(xAxisDuration: 0.8, easingOption: .easeInOutQuart)
        moodChartView.legend.enabled = false
        moodChartView.rightAxis.enabled = false

        // Left axis: numeric 1..5
        let leftAxis = moodChartView.leftAxis
        leftAxis.axisMinimum = 0.5
        leftAxis.axisMaximum = 5.5
        leftAxis.granularity = 1.0
        leftAxis.granularityEnabled = true
        leftAxis.labelCount = 5
        leftAxis.forceLabelsEnabled = true
        leftAxis.valueFormatter = MoodYAxisFormatter() // now returns "1","2",...
        leftAxis.labelFont = .systemFont(ofSize: 13)
        leftAxis.labelTextColor = .label
        leftAxis.gridColor = UIColor.systemGray4.withAlphaComponent(0.5)
        leftAxis.gridLineDashLengths = [4, 4]
        leftAxis.axisLineColor = .clear

        // X axis: date labels
        let xAxis = moodChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .medium)
        xAxis.labelTextColor = .secondaryLabel
        xAxis.gridColor = .clear
        xAxis.axisLineColor = UIColor.systemGray4
        xAxis.granularity = 1.0
        xAxis.granularityEnabled = true
        xAxis.avoidFirstLastClippingEnabled = true
        xAxis.labelRotationAngle = -30

        // Marker: create once and keep reference
        markerView = MoodMarkerView()
        markerView?.chartView = moodChartView
        moodChartView.marker = markerView
    }

    /// Supply mood logs (1..5) and their dates
    func configure(with moodLogs: [MoodLog]) {
        guard !moodLogs.isEmpty else {
            moodChartView.data = nil
            moodChartView.noDataText = "No mood entries yet."
            moodChartView.noDataFont = .systemFont(ofSize: 14, weight: .medium)
            moodChartView.noDataTextColor = .secondaryLabel
            return
        }

        let (entries, xLabels) = MoodChartHelper.buildChartData(from: moodLogs)

        // X-axis formatter
        xAxisFormatter = MoodXAxisFormatter(labels: xLabels)
        moodChartView.xAxis.valueFormatter = xAxisFormatter
        moodChartView.xAxis.axisMinimum = -0.5
        moodChartView.xAxis.axisMaximum = Double(entries.count) - 0.5
        moodChartView.xAxis.labelCount = min(entries.count, 7)

        // Configure dataset
        let dataSet = LineChartDataSet(entries: entries, label: "Mood")
        dataSet.mode = .cubicBezier
        dataSet.cubicIntensity = 0.2
        dataSet.lineWidth = 2.5
        dataSet.setColor(UIColor.systemIndigo)
        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 4.0
        dataSet.circleHoleRadius = 2.0
        dataSet.setCircleColor(UIColor.systemIndigo)
        dataSet.circleHoleColor = .systemBackground

        // Professional: hide all value labels (doctor reads on tap)
        dataSet.drawValuesEnabled = false

        // Subtle gradient fill
        dataSet.drawFilledEnabled = true
        let gradientColors: CFArray = [
            UIColor.systemIndigo.withAlphaComponent(0.18).cgColor,
            UIColor.systemIndigo.withAlphaComponent(0.0).cgColor
        ] as CFArray
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: [0.0, 1.0]) {
            dataSet.fill = LinearGradientFill(gradient: gradient, angle: 270)
        }

        // Highlight line appearance
        dataSet.highlightColor = UIColor.systemIndigo.withAlphaComponent(0.5)
        dataSet.highlightLineWidth = 1.5
        dataSet.drawHorizontalHighlightIndicatorEnabled = false

        // Assign data
        let chartData = LineChartData(dataSet: dataSet)
        moodChartView.data = chartData

        // Pass labels to marker so it can display the date string
        markerView?.labels = xLabels

        // Simple animation on data load
        moodChartView.animate(xAxisDuration: 0.6, easingOption: .easeOutCubic)
    }

    // Chart tap feedback
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {}
}


// MARK: - Marker: Professional numeric display
final class MoodMarkerView: MarkerView {

    // Labels provided from the cell configure()
    var labels: [String] = []

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemBackground
        v.layer.cornerRadius = 8
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.12
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let descriptorLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .regular)
        l.textColor = .tertiaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        addSubview(containerView)
        containerView.addSubview(valueLabel)
        containerView.addSubview(descriptorLabel)
        containerView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 110),
            containerView.heightAnchor.constraint(equalToConstant: 56),

            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            valueLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            descriptorLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            descriptorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            descriptorLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),

            dateLabel.topAnchor.constraint(equalTo: descriptorLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6)
        ])
    }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let level = max(1, min(5, Int(entry.y)))
        valueLabel.text = "\(level)"
        descriptorLabel.text = MoodChartHelper.label(for: level)

        // Use provided label list to show the date string; fall back to empty if out-of-range
        let idx = Int(entry.x)
        if idx >= 0, idx < labels.count {
            dateLabel.text = labels[idx]
        } else {
            dateLabel.text = ""
        }

        layoutIfNeeded()
        self.frame.size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        offset = CGPoint(x: -self.frame.width / 2, y: -self.frame.height - 10)
    }
}


// MARK: - Helpers & Formatters (small changes)
enum MoodChartHelper {
    static func label(for level: Int) -> String {
        switch level {
        case 1: return "Very Sad"
        case 2: return "Sad"
        case 3: return "Neutral"
        case 4: return "Happy"
        case 5: return "Very Happy"
        default: return "Unknown"
        }
    }

    static func buildChartData(from logs: [MoodLog]) -> (entries: [ChartDataEntry], xLabels: [String]) {
        let sorted = logs.sorted { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // short date for x-axis ticks
        var entries: [ChartDataEntry] = []
        var xLabels: [String] = []
        for (i, log) in sorted.enumerated() {
            let clamped = max(1, min(5, log.mood))
            entries.append(ChartDataEntry(x: Double(i), y: Double(clamped)))
            xLabels.append(log.date.map { formatter.string(from: $0) } ?? "—")
        }
        return (entries, xLabels)
    }
}

final class MoodXAxisFormatter: NSObject, AxisValueFormatter {
    private let labels: [String]
    init(labels: [String]) { self.labels = labels }
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let i = Int(value)
        guard i >= 0, i < labels.count else { return "" }
        return labels[i]
    }
}
final class MoodYAxisFormatter: NSObject, AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // Show integer tick labels: 1,2,3,4,5
        return String(Int(round(value)))
    }
}
