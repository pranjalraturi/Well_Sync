//
//  TodayTableViewCell.swift
//  patientSide
//
//  Created by Rishika Mittal on 27/01/26.
//

import UIKit

class TodayTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var subtitleBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addPhotoButton: UIButton! 
    
    var onPhotoSourceSelected: ((UIImagePickerController.SourceType) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupPhotoMenu()
        setupCard()
    }

    private func setupCard() {
        selectionStyle              = .none
        cardView.layer.borderColor  = UIColor.systemGray4.cgColor
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth  = 0
        cardView.layer.shadowColor   = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset  = CGSize(width: 0, height: 0)
        cardView.layer.shadowRadius  = 8
        cardView.layer.masksToBounds = false
    }
    
    func setupPhotoMenu() {

        let camera = UIAction(title: "Camera",
                            image: UIImage(systemName: "camera")) { [weak self] _ in
            self?.onPhotoSourceSelected?(.camera)
        }

        let photoLibrary = UIAction(title: "Photo Library",
                            image: UIImage(systemName: "photo")) { [weak self] _ in
            self?.onPhotoSourceSelected?(.photoLibrary)
        }

        let menu = UIMenu(title: "", children: [camera, photoLibrary])
        addPhotoButton.menu = menu
        addPhotoButton.showsMenuAsPrimaryAction = true
    }
    

    func configure(with item: TodayActivityItem) {
        titleLabel.text     = item.activity.name
        dateLabel.text      = item.frequencyText
        subtitleLabel.text  = item.assignment.doctorNote ?? "No additional notes."
        subtitleLabel.isHidden = false
        let symbolConfig    = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        iconImageView.image = UIImage(systemName: item.activity.iconName, withConfiguration: symbolConfig)

        let done                 = item.isCompletedToday
//        checkmarkView.isHidden   = !done
        cardView.backgroundColor = done
        ? UIColor.systemGray4
        : UIColor.secondarySystemBackground
        contentView.alpha = done ? 0.7 : 1.0
    }

    func configureAsLog(activityName: String, iconName: String, logCount: Int) {
        titleLabel.text          = activityName
        dateLabel.text           = "Total: \(logCount)"
        subtitleLabel.isHidden   = true
        iconImageView.image      = UIImage(systemName: iconName)
//        checkmarkView.isHidden   = true
        subtitleBottomConstraint.constant = 8
        addPhotoButton.isHidden  = true
    }
//    @IBAction func uploadTapped(_ sender: Any) {
//        let alert = UIAlertController(title: "Add Photo", message: "choose an Option", preferredStyle: .actionSheet)
//        
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            alert.addAction(UIAlertAction(title: "Camera", style: .default) {_ in self.openImagePicker(sourceType: .camera)})
//        }
//        
//        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) {_ in
//            self.openImagePicker(sourceType: .photoLibrary)})
//        present(alert, animated: true)
//    }
    
}


