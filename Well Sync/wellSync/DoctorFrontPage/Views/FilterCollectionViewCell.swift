//
//  FilterCollectionViewCell.swift
//  wellSync
//
//  Created by GEU on 11/04/26.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var all: UILabel!
    @IBOutlet var Upcoming: UILabel!
    @IBOutlet var Missed: UILabel!
    @IBOutlet var Done: UILabel!
    
    private var labels: [UILabel] = []
    var onFilterSelected: ((FilterType) -> Void )?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        labels = [all, Upcoming, Missed, Done]
        
        setupLabels()
        enableTap()
        
        selectLabel(all)
    }
    private func setupLabels() {
        for label in labels {
            label.layer.cornerRadius = 12
            label.clipsToBounds = true
            label.textAlignment = .center
            label.layer.masksToBounds = true
            label.textColor = .darkGray
            label.backgroundColor = .clear
        }
    }
    
    private func enableTap() {
        for label in labels {
            label.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(filterTapped(_:)))
            label.addGestureRecognizer(tap)
        }
    }
    
    @objc private func filterTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedLabel = sender.view as? UILabel else { return }

        selectLabel(tappedLabel)
        
        if tappedLabel == all {
                   onFilterSelected?(.all)
               } else if tappedLabel == Upcoming {
                   onFilterSelected?(.upcoming)
               } else if tappedLabel == Missed {
                   onFilterSelected?(.missed)
               } else if tappedLabel == Done {
                   onFilterSelected?(.done)
               }
    }
    
    private func selectLabel(_ selected: UILabel) {
        for label in labels {
            if label == selected {
                label.backgroundColor = .black
                label.textColor = .white
            } else {
                label.backgroundColor = .clear
                label.textColor = .darkGray
            }
        }
    }
    
    func configure(allCount: Int, upcomingCount: Int, missedCount: Int, doneCount: Int) {
        all.text = "All (\(allCount))"
        Upcoming.text = "Upcoming (\(upcomingCount))"
        Missed.text = "Missed (\(missedCount))"
        Done.text = "Done (\(doneCount))"
    }
    
    
}
