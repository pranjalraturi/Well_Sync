import UIKit

class MoodLogCollectionViewController:
    UICollectionViewController,
    UICollectionViewDelegateFlowLayout {

    var selectedMoodColor: UIColor?
    var onDismiss: (() -> Void)?
    var selectedMood: Int? = 2
    
    enum MoodLevel: Int {
        case verySad
        case sad
        case neutral
        case happy
        case veryHappy
    }

    let moodFeelings: [MoodLevel: [String]] = [
        .verySad: ["Overwhelmed", "Drained", "Anxious", "Lonely","one", "two", "three"],
        .sad: ["Low", "Tired", "Irritated", "Unmotivated"],
        .neutral: ["Calm", "Balanced", "Okay", "Indifferent"],
        .happy: ["Content", "Grateful", "Relaxed", "Hopeful"],
        .veryHappy: ["Excited", "Joyful", "Energized", "Confident"]
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let color = selectedMoodColor {
            view.backgroundColor = color.withAlphaComponent(0.15)
        }
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8

        }
        

    }

    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true) {
            self.onDismiss?()
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
                return 1 // Mood selector cell
            }
            
        guard let mood = MoodLevel(rawValue: selectedMood ?? 2),
            let feelings = moodFeelings[mood] else {
                return 0
        }
        
        return feelings.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {

        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MoodEntry",
                for: indexPath
            ) as! MoodEntryCollectionViewCell
            
            cell.configureTap(target: self, action: #selector(moodTapped(_:)))
            cell.configure(selectedIndex: selectedMood ?? 2)
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.2
            cell.layer.shadowOffset = CGSize(width: 0, height: 4)
            cell.layer.shadowRadius = 8
            cell.layer.masksToBounds = false

            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "FeelingCell",
                for: indexPath
            ) as! FeelingCollectionViewCell
            
            if let mood = MoodLevel(rawValue: selectedMood ?? 2),
               let feelings = moodFeelings[mood] {
                cell.configure(title: feelings[indexPath.item])
            }
            
            return cell
    }

    @objc func moodTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedView = sender.view else { return }

        // scale animation
        UIView.animate(withDuration: 0.15,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: []) {
            selectedView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }
        let moodIndex = selectedView.tag
        selectedMood = moodIndex
        collectionView.reloadSections(IndexSet(integer: 0))

        collectionView.reloadSections(IndexSet(integer: 1))
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        if indexPath.section == 0 {
            return CGSize(width: collectionView.frame.width, height: 180)
        }

        return CGSize(width: collectionView.frame.width, height: 240)

    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

}
