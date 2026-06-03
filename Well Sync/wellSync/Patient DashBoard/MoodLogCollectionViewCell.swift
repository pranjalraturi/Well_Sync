//
//  MoodLogCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 30/01/26.
//

import UIKit

class PaddedLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
}

class MoodLogCollectionViewCell: UICollectionViewCell {
    @IBOutlet var moodViews: [UIImageView]!
    @IBOutlet var stepperDots: [UIView]!    // kept for storyboard; hidden at runtime
    @IBOutlet weak var trackLine: UIView!   // kept for storyboard; hidden at runtime
    @IBOutlet weak var timerLabel: UILabel!

    // Mood logging state
    var totalMood: [MoodLog] = []
    var todayMood: [MoodLog] = []
    private let cooldown: TimeInterval = 3.5 * 3600
    private let maxDailyLogs = 6

    // Single dynamic bar
    private var sectionCard: UIView?      // gray background card behind bar
    private var barContainer: UIView?
    private var segmentViews: [UIView] = []
    private var didSetupTimeline = false

    // Dynamic mood colors from asset images (red, orange, yellow, lightGreen, green)
    private var moodColorsList: [UIColor] {
        return MoodColors.shared.colors
    }

    private let teal = UIColor(red: 113/255, green: 201/255, blue: 206/255, alpha: 1)

    // MARK: – Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        style(self)

        timerLabel?.layer.masksToBounds = true
        timerLabel?.backgroundColor = teal.withAlphaComponent(0.20)
    }

    func configureTap(target: Any, action: Selector) {
        for view in moodViews {
            view.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: target, action: action)
            view.addGestureRecognizer(tap)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        for view in moodViews { view.transform = .identity }
        barContainer?.layer.removeAllAnimations()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupTimelineBar()
        layoutSegments()
    }

    // MARK: – Single Dynamic Bar Setup

    private func setupTimelineBar() {
        guard !didSetupTimeline else { return }

        // Hide the old storyboard stepper elements
        trackLine?.isHidden = true
        stepperDots?.forEach { $0.isHidden = true }
        stepperDots?.first?.superview?.isHidden = true

        // Find the card view reliably (first subview of contentView)
        guard let cardView = contentView.subviews.first else { return }

        // ── Gray section card (background behind the bar) ──
        let card = UIView()
        card.backgroundColor = UIColor.systemGray6
        card.layer.cornerRadius = 12
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(card)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            card.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            card.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -6),
            card.heightAnchor.constraint(equalToConstant: 36)
        ])
        sectionCard = card
        
        // ── Title Label ──
        let titleLabel = UILabel()
        titleLabel.text = "Today's Logs"
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        // ── Vertical Separator ──
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray4
        separator.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(separator)

        // ── Bar container (sits inside the gray card) ──
        let container = UIView()
        container.layer.cornerRadius = 7
        container.clipsToBounds = true
        container.backgroundColor = UIColor.systemGray5
        container.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(container)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            separator.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            separator.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            separator.widthAnchor.constraint(equalToConstant: 1),
            separator.heightAnchor.constraint(equalToConstant: 16),
            
            container.leadingAnchor.constraint(equalTo: separator.trailingAnchor, constant: 10),
            container.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            container.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            container.heightAnchor.constraint(equalToConstant: 12)
        ])

        barContainer = container
        didSetupTimeline = true

        // Force constraint resolution so container gets bounds immediately
        contentView.layoutIfNeeded()
    }

    // MARK: – Configure with mood data

    func configureMood(_ moods: [MoodLog]) {
        // Retry setup if it failed during awakeFromNib
        if !didSetupTimeline { setupTimelineBar() }

        totalMood = moods
        let today = Date()
        todayMood = totalMood
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .sorted { $0.date < $1.date }
        updateTimelineUI()
    }

    private func updateTimelineUI() {
        guard let container = barContainer else { return }

        // Clear previous segments
        segmentViews.forEach { $0.removeFromSuperview() }
        segmentViews.removeAll()

        let loggedCount = todayMood.count

        if loggedCount == 0 {
            container.backgroundColor = UIColor.systemGray5
        } else {
            // Gaps between segments reveal the section card bg as thin separators
            container.backgroundColor = .clear

            for mood in todayMood {
                let segment = UIView()
                segment.backgroundColor = tealShadeFor(level: mood.mood)
                container.addSubview(segment)
                segmentViews.append(segment)
            }
        }

        // Timer label update
        let isReady = canLogNow
        if isReady {
            timerLabel?.text = "Ready to log!"
            timerLabel?.textColor = teal
        } else {
            if loggedCount >= maxDailyLogs {
                timerLabel?.text = "All Done!"
                timerLabel?.textColor = .systemGray
            } else if let lastLog = totalMood.sorted(by: { $0.date > $1.date }).first {
                let nextTime = lastLog.date.addingTimeInterval(cooldown)
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                timerLabel?.text = "Next log: \(formatter.string(from: nextTime))"
                timerLabel?.textColor = teal
            }
        }

        // Force layout so segments get positioned immediately
        contentView.layoutIfNeeded()
        layoutSegments()
    }

    /// Positions segment subviews equally inside the bar container.
    private func layoutSegments() {
        guard let container = barContainer, !container.bounds.isEmpty else { return }
        let count = segmentViews.count
        guard count > 0 else { return }

        let gap: CGFloat = count > 1 ? 1.5 : 0
        let totalGaps = CGFloat(count - 1) * gap
        let segmentWidth = (container.bounds.width - totalGaps) / CGFloat(count)

        for (i, segment) in segmentViews.enumerated() {
            segment.frame = CGRect(
                x: CGFloat(i) * (segmentWidth + gap),
                y: 0,
                width: segmentWidth,
                height: container.bounds.height
            )
        }
    }

    // MARK: – Helpers

    private func tealShadeFor(level: Int) -> UIColor {
        let colors = MoodColors.shared.colors
        guard level >= 1 && level <= colors.count else {
            return colors[2]
        }
        return colors[level - 1]
    }

    var canLogNow: Bool {
        if todayMood.count >= maxDailyLogs { return false }
        guard let lastLog = totalMood.sorted(by: { $0.date > $1.date }).first else { return true }
        return lastLog.date.addingTimeInterval(cooldown).timeIntervalSinceNow <= 0
    }
}
