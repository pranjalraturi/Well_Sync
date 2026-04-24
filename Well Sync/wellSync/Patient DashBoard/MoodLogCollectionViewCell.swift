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
    @IBOutlet var stepperDots: [UIView]!
    @IBOutlet weak var trackLine: UIView!
    @IBOutlet weak var timerLabel: UILabel!

    // Mood logging state
    var totalMood: [MoodLog] = []
    var todayMood: [MoodLog] = []
    private let cooldown: TimeInterval = 3.5 * 3600
    private let maxDailyLogs = 6

    // Mood-level color mapping: 0=red, 1=orange, 2=yellow, 3=lightGreen, 4=darkGreen
    private let moodColors: [UIColor] = [
        UIColor(red: 220/255, green: 53/255,  blue: 69/255,  alpha: 1),  // 0 — Red
        UIColor(red: 255/255, green: 152/255, blue: 0/255,   alpha: 1),  // 1 — Orange
        UIColor(red: 255/255, green: 213/255, blue: 79/255,  alpha: 1),  // 2 — Yellow
        UIColor(red: 139/255, green: 195/255, blue: 74/255,  alpha: 1),  // 3 — Light Green
        UIColor(red: 56/255,  green: 142/255, blue: 60/255,  alpha: 1),  // 4 — Dark Green
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        trackLine?.layer.cornerRadius = 1.5
        trackLine?.clipsToBounds = true
        
        timerLabel?.layer.masksToBounds = true
        timerLabel?.backgroundColor = UIColor(red: 113/255, green: 201/255, blue: 206/255, alpha: 0.20)
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
        for view in moodViews {
            view.transform = .identity
        }
        stepperDots?.forEach {
            $0.layer.removeAllAnimations()
            $0.layer.sublayers?.filter { $0.name == "pulseLayer" }.forEach { $0.removeFromSuperlayer() }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        stepperDots?.forEach { $0.layer.cornerRadius = $0.bounds.height / 2 }
    }

    // MARK: – Configure with mood data

    func configureMood(_ moods: [MoodLog]) {
        totalMood = moods
        let today = Date()
        todayMood = totalMood
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .sorted { $0.date < $1.date }  // earliest first so dot order matches log order
        updateStepperUI()
    }

    private func updateStepperUI() {
        guard let dots = stepperDots, !dots.isEmpty else { return }

        let loggedCount = todayMood.count
        let isReady = canLogNow

        for (index, dot) in dots.enumerated() {
            dot.layer.cornerRadius = dot.bounds.height / 2
            dot.clipsToBounds = false
            dot.transform = .identity
            dot.layer.sublayers?.filter { $0.name == "pulseLayer" }.forEach { $0.removeFromSuperlayer() }
            dot.layer.shadowOpacity = 0

            if index < loggedCount {
                // Filled dot — color matches the mood level that was logged
                let moodLevel = todayMood[index].mood
                let color = moodColorFor(level: moodLevel)
                dot.backgroundColor = color
                dot.layer.borderColor = UIColor.white.cgColor
                dot.layer.borderWidth = 2
                dot.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            } else if index == loggedCount && isReady && loggedCount < maxDailyLogs {
                // Active dot — white fill, teal border, scaled up, glow
                let teal = UIColor(red: 113/255, green: 201/255, blue: 206/255, alpha: 1)
                dot.backgroundColor = .white
                dot.layer.borderColor = teal.cgColor
                dot.layer.borderWidth = 3
                dot.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)

                dot.layer.shadowColor = teal.cgColor
                dot.layer.shadowOpacity = 0.5
                dot.layer.shadowOffset = .zero
                dot.layer.shadowRadius = 6

                addPulseAnimation(to: dot, color: teal)
            } else {
                // Inactive dot — small, gray
                dot.backgroundColor = UIColor.systemGray4
                dot.layer.borderColor = UIColor.systemGray3.cgColor
                dot.layer.borderWidth = 1
                dot.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            }
        }

        // Timer Label update
        if isReady {
            timerLabel?.text = "Ready to log!"
            timerLabel?.textColor = UIColor(red: 113/255, green: 201/255, blue: 206/255, alpha: 1) // #71C9CE
        } else {
            if loggedCount >= maxDailyLogs {
                timerLabel?.text = "All Done!"
                timerLabel?.textColor = .systemGray
            } else if let lastLog = totalMood.sorted(by: { $0.date > $1.date }).first {
                let nextTime = lastLog.date.addingTimeInterval(cooldown)
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                timerLabel?.text = "Next log: \(formatter.string(from: nextTime))"
                timerLabel?.textColor = UIColor(red: 113/255, green: 201/255, blue: 206/255, alpha: 1)
            }
        }
    }

    /// Returns the appropriate color for a given mood level (0–4).
    private func moodColorFor(level: Int) -> UIColor {
        guard level >= 0 && level < moodColors.count else {
            return moodColors.last ?? .systemGreen
        }
        return moodColors[level-1]
    }

    private func addPulseAnimation(to view: UIView, color: UIColor) {
        guard view.layer.animation(forKey: "pulse") == nil else { return }

        let pulseLayer = CALayer()
        pulseLayer.name = "pulseLayer"
        pulseLayer.frame = view.bounds
        pulseLayer.cornerRadius = view.bounds.height / 2
        pulseLayer.borderColor = color.withAlphaComponent(0.4).cgColor
        pulseLayer.borderWidth = 2
        view.layer.addSublayer(pulseLayer)

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.toValue = 2.0

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0

        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, opacityAnimation]
        group.duration = 1.8
        group.repeatCount = .infinity

        pulseLayer.add(group, forKey: "pulse")
    }

    var canLogNow: Bool {
        if todayMood.count >= maxDailyLogs { return false }
        guard let lastLog = totalMood.sorted(by: { $0.date > $1.date }).first else { return true }
        return lastLog.date.addingTimeInterval(cooldown).timeIntervalSinceNow <= 0
    }
}
