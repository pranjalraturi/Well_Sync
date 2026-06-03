//
//  MoodDistributionCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 23/03/26.
//

import UIKit

class MoodDistributionCollectionViewCell: UICollectionViewCell {

    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var veryHappy: UIProgressView!
    @IBOutlet var veryHappyLabel: UILabel!
    @IBOutlet var happy: UIProgressView!
    @IBOutlet var happyLabel: UILabel!
    @IBOutlet var neutral: UIProgressView!
    @IBOutlet var neutralLabel: UILabel!
    @IBOutlet var bad: UIProgressView!
    @IBOutlet var badLabel: UILabel!
    @IBOutlet var veryBad: UIProgressView!
    @IBOutlet var veryBadLabel: UILabel!
    @IBOutlet weak var distributinoType: UILabel!
    
    var isWeekly: Bool = true
    var moodLogs: [MoodLog] = []

    // Dynamic mood colors matching the patient-side MoodLogCollectionViewCell
    private var moodColorsList: [UIColor] {
        return MoodColors.shared.colors
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        style(self)

        // Apply dynamic mood colors to progress bars (matching patient mood log)
        let bars: [(UIProgressView, Int)] = [
            (veryHappy, 4),  // Very Happy = index 4
            (happy, 3),      // Happy      = index 3
            (neutral, 2),    // Neutral    = index 2
            (bad, 1),        // Bad/Sad    = index 1
            (veryBad, 0)     // Very Bad   = index 0
        ]
        let colors = MoodColors.shared.colors
        for (bar, idx) in bars {
            guard idx < colors.count else { continue }
            bar.progressTintColor = colors[idx]
            bar.trackTintColor = colors[idx].withAlphaComponent(0.15)
        }
    }
    func configure(moodLogs: [MoodLog]) {
        self.moodLogs = moodLogs
        
        let total = moodLogs.count
        
        // Set total label
        totalLabel.text = "\(total) Total Logs"
        
        // Guard against empty logs to avoid division by zero
        guard total > 0 else {
            veryHappy.setProgress(0, animated: true)
            happy.setProgress(0, animated: true)
            neutral.setProgress(0, animated: true)
            bad.setProgress(0, animated: true)
            veryBad.setProgress(0, animated: true)
            
            veryHappyLabel.text = "0%"
            happyLabel.text     = "0%"
            neutralLabel.text   = "0%"
            badLabel.text       = "0%"
            veryBadLabel.text   = "0%"
            return
        }
        
        // Count each mood level
        var counts: [MoodLevel: Int] = [
            .veryHappy: 0,
            .happy: 0,
            .neutral: 0,
            .sad: 0,
            .verySad: 0
        ]
        
        for log in moodLogs {
            if let level = MoodLevel(rawValue: log.mood - 1) {
                counts[level]! += 1
            }
        }
        
        // Calculate fractions (0.0 to 1.0) and set progress
        let veryHappyCount = counts[.veryHappy, default: 0]
        let happyCount     = counts[.happy,     default: 0]
        let neutralCount   = counts[.neutral,   default: 0]
        let badCount       = counts[.sad,       default: 0]
        let veryBadCount   = counts[.verySad,   default: 0]
        
        let veryHappyFraction = Float(veryHappyCount) / Float(total)
        let happyFraction     = Float(happyCount)     / Float(total)
        let neutralFraction   = Float(neutralCount)   / Float(total)
        let badFraction       = Float(badCount)       / Float(total)
        let veryBadFraction   = Float(veryBadCount)   / Float(total)
        
        // Set progress bars
        veryHappy.setProgress(veryHappyFraction,animated: true)
        happy.setProgress(happyFraction,animated: true)
        neutral.setProgress(neutralFraction,animated: true)
        bad.setProgress(badFraction,animated: true)
        veryBad.setProgress(veryBadFraction,animated: true)
        
        // Set labels — showing percentage (rounded) + raw count
        veryHappyLabel.text = "\(veryHappyCount) Logs"
        happyLabel.text     = "\(happyCount) Logs"
        neutralLabel.text   = "\(neutralCount) Logs"
        badLabel.text       = "\(badCount) Logs"
        veryBadLabel.text   = "\(veryBadCount) Logs"
    }
}
