//
//  insightCollectionViewCell.swift
//  sample
//
//  Created by Pranjal on 02/04/26.
//
import UIKit

class insightCollectionViewCellGr: UICollectionViewCell {

    private let totalLogsLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let completionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let progressBar: UIProgressView = {
        let p = UIProgressView(progressViewStyle: .default)
        p.trackTintColor = UIColor.systemGray5
        p.progressTintColor = UIColor.systemTeal
        p.layer.cornerRadius = 4
        p.clipsToBounds = true
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()
//
//    private let trendIconLabel: UILabel = {
//        let l = UILabel()
//        l.font = .systemFont(ofSize: 22)
//        l.translatesAutoresizingMaskIntoConstraints = false
//        return l
//    }()

    private let trendTextLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let trendSubLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .regular)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()


    private let statStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.spacing = 1
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()


    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .secondarySystemBackground
        setupUI()
    }


    private func setupUI() {

        subviews.forEach { if $0 is UILabel { $0.removeFromSuperview() } }

        let totalBox  = makeStatBox(title: "Total Logs")
        let weekBox   = makeStatBox(title: "This Week")
        let lastBox   = makeStatBox(title: "Last Week")

        [totalBox, weekBox, lastBox].forEach { statStack.addArrangedSubview($0) }

        let trendRow = UIStackView(arrangedSubviews: [trendTextLabel, UIView(), trendSubLabel])
        trendRow.axis = .horizontal
        trendRow.spacing = 6
        trendRow.alignment = .center
        trendRow.translatesAutoresizingMaskIntoConstraints = false

        let vStack = UIStackView(arrangedSubviews: [
            statStack,
            divider,
            completionLabel,
            progressBar,
            trendRow
        ])
        vStack.axis = .vertical
        vStack.spacing = 10
        vStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(vStack)

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),

            divider.heightAnchor.constraint(equalToConstant: 1),
            progressBar.heightAnchor.constraint(equalToConstant: 8),
        ])
    }

    private func makeStatBox(title: String) -> UIView {
        let numberLabel = UILabel()
        numberLabel.font = .systemFont(ofSize: 22, weight: .bold)
        numberLabel.textColor = .label
        numberLabel.textAlignment = .center
        numberLabel.tag = 100

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.text = title

        let stack = UIStackView(arrangedSubviews: [numberLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        stack.tag = 200
        return stack
    }

    func configure(with logs: [ActivityLog], frequency: Int) {

        let calendar = Calendar.current
        let today    = Date()

        let totalLogs = logs.count

        let weekday       = calendar.component(.weekday, from: today)
        let weekStart     = calendar.date(byAdding: .day,
                                          value: -(weekday - 1),
                                          to: calendar.startOfDay(for: today))!
        let thisWeekLogs  = logs.filter { $0.date >= weekStart && $0.date <= today }.count

        let lastWeekStart = calendar.date(byAdding: .day, value: -7, to: weekStart)!
        let lastWeekEnd   = calendar.date(byAdding: .second, value: -1, to: weekStart)!
        let lastWeekLogs  = logs.filter { $0.date >= lastWeekStart && $0.date <= lastWeekEnd }.count

        let todayLogs       = logs.filter { calendar.isDateInToday($0.date) }.count
        let safeFrequency   = max(frequency, 1)
        let completionRatio = Float(min(todayLogs, safeFrequency)) / Float(safeFrequency)

        let diff            = thisWeekLogs - lastWeekLogs
//        let trendIcon: String
        let trendText: String
        let trendColor: UIColor

        if lastWeekLogs == 0 && thisWeekLogs == 0 {
//            trendIcon  = ""
            trendText  = "No data yet"
            trendColor = .secondaryLabel
        } else if diff > 0 {
//            trendIcon  = ""
            trendText  = "+\(diff) logs vs last week"
            trendColor = .systemGreen
        } else if diff < 0 {
//            trendIcon  = ""
            trendText  = "\(diff) logs vs last week"
            trendColor = .systemRed
        } else {
//            trendIcon  = ""
            trendText  = "Same as last week"
            trendColor = .systemOrange
        }

        let boxes = statStack.arrangedSubviews
        updateStatBox(boxes[0], value: "\(totalLogs)")
        updateStatBox(boxes[1], value: "\(thisWeekLogs)")
        updateStatBox(boxes[2], value: "\(lastWeekLogs)")

        completionLabel.text              = "Today: \(todayLogs) of \(safeFrequency) completed"
        progressBar.setProgress(completionRatio, animated: true)
        progressBar.progressTintColor     = completionRatio >= 1.0 ? .systemGreen : .systemTeal

//        trendIconLabel.text               = trendIcon
        trendTextLabel.text               = trendText
        trendTextLabel.textColor          = trendColor
        trendSubLabel.text                = lastWeekLogs == 0 ? "" : "\(Int(completionRatio * 100))% today"
    }

    private func updateStatBox(_ view: UIView, value: String) {
        if let stack = view as? UIStackView,
           let numLabel = stack.arrangedSubviews.first(where: { $0.tag == 100 }) as? UILabel {
            numLabel.text = value
        }
    }
}
