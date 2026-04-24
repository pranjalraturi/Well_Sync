//
//  MoodCountCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Saran Agarwal on 30/03/26.

import UIKit

class MoodCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var MoodCount: UILabel!
    @IBOutlet weak var logNowBadge: UILabel!
    @IBOutlet weak var timerStack: UIStackView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet var moodDots: [UIView]!

    var totalMood: [MoodLog] = []
    var todayMood: [MoodLog] = []

    private let cooldown: TimeInterval = 3.5 * 3600
    private let maxDailyLogs = 6

    override func awakeFromNib() {
        super.awakeFromNib()
        logNowBadge?.layer.cornerRadius = 6
        logNowBadge?.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        logNowBadge?.layer.removeAllAnimations()
        moodDots?.forEach {
            $0.layer.removeAllAnimations()
            $0.layer.sublayers?.filter { $0.name == "pulseLayer" }.forEach { $0.removeFromSuperlayer() }
        }
    }

    func configure(mood: [MoodLog]) {
        totalMood = mood
        let today = Date()
        todayMood = totalMood.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }

        MoodCount.text = "\(min(todayMood.count, maxDailyLogs))"

        if todayMood.count >= maxDailyLogs {
            showAllDoneState()
        } else {
            updateNextLogTime()
        }

        updateStepperUI()
    }

    private func updateNextLogTime() {
        guard let lastLog = totalMood.sorted(by: { $0.date > $1.date }).first else {
            showReadyState()
            return
        }

        let nextLogTime = lastLog.date.addingTimeInterval(cooldown)
        let remaining = nextLogTime.timeIntervalSinceNow

        if remaining <= 0 {
            showReadyState()
        } else {
            logNowBadge?.isHidden = true
            timerStack?.isHidden = false

            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"

            timerLabel?.text = "\(formatter.string(from: nextLogTime))"
        }
    }

    private func showReadyState() {
        logNowBadge?.isHidden = false
        timerStack?.isHidden = true

        logNowBadge?.text = "LOG NOW"
        logNowBadge?.textColor = .systemBlue
        logNowBadge?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
    }

    private func showAllDoneState() {
        logNowBadge?.isHidden = false
        timerStack?.isHidden = true

        logNowBadge?.text = "ALL DONE"
        logNowBadge?.textColor = .systemGreen
        logNowBadge?.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
    }
    
    private func color(for moodValue: Int) -> UIColor {
        switch moodValue {
        case 1: return .systemRed
        case 2: return .systemOrange
        case 3: return .systemYellow
        case 4: return .systemGreen
        case 5: return UIColor(red: 0.18, green: 0.80, blue: 0.18, alpha: 1) // vivid green
        default: return .systemGray
        }
    }
    
    private func updateStepperUI() {
        guard let dots = moodDots, !dots.isEmpty else { return }

        // Sort today's mood logs chronologically so dot[0] = earliest log
        let sortedTodayMoods = todayMood.sorted(by: { $0.date < $1.date })

        let loggedCount = sortedTodayMoods.count
        let isReady     = canLogNow

        for (index, dot) in dots.enumerated() {
            dot.layer.cornerRadius = dot.frame.height / 2
            dot.transform          = .identity
            dot.layer.sublayers?
                .filter { $0.name == "pulseLayer" }
                .forEach { $0.removeFromSuperlayer() }

            if index < loggedCount {
                // ✅ Use the actual mood's color instead of static .systemGreen
                let moodValue       = sortedTodayMoods[index].mood   // ← your MoodLog's mood Int field
                dot.backgroundColor = color(for: moodValue)
                dot.layer.borderColor = UIColor.white.cgColor
                dot.layer.borderWidth = 2

            } else if index == loggedCount && isReady && loggedCount < maxDailyLogs {
                dot.backgroundColor   = .white
                dot.layer.borderColor = UIColor.systemBlue.cgColor
                dot.layer.borderWidth = 3
                addPulseAnimation(to: dot)

            } else {
                dot.transform         = CGAffineTransform(scaleX: 0.75, y: 0.75)
                dot.backgroundColor   = .systemGray5
                dot.layer.borderColor = UIColor.white.cgColor
                dot.layer.borderWidth = 2
            }
        }
    }

    private func addPulseAnimation(to view: UIView) {
        guard view.layer.animation(forKey: "pulse") == nil else { return }

        let pulseLayer = CALayer()
        pulseLayer.name = "pulseLayer"
        pulseLayer.frame = view.bounds
        pulseLayer.cornerRadius = view.bounds.height / 2
        pulseLayer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
        pulseLayer.borderWidth = 2
        view.layer.addSublayer(pulseLayer)

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.toValue = 1.6

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0

        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, opacityAnimation]
        group.duration = 1.5
        group.repeatCount = .infinity

        pulseLayer.add(group, forKey: "pulse")
    }

    var canLogNow: Bool {
        if todayMood.count >= maxDailyLogs { return false }
        guard let lastLog = totalMood.sorted(by: { $0.date > $1.date }).first else { return true }
        return lastLog.date.addingTimeInterval(cooldown).timeIntervalSinceNow <= 0
    }
}
