//
//  PatientProfileTableViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 11/02/26.
//

import UIKit

class PatientProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var patientImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
    }
    
    @IBAction func addPhotoTapped(_ sender: UIButton) {
        let camera = UIAction(title: "Camera",
                              image: UIImage(systemName: "camera")) { _ in
            self.openImagePicker(sourceType: .camera)
        }
        
        let photoLibrary = UIAction(title: "Photo Library",
                                    image: UIImage(systemName: "photo")) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        }
        
        let menu = UIMenu(title: "", children: [camera, photoLibrary])
        
        sender.menu = menu
        sender.showsMenuAsPrimaryAction = true
    }
    
    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
           let picker = UIImagePickerController()
           picker.delegate = self
           picker.sourceType = sourceType
           picker.allowsEditing = true
           present(picker, animated: true)
       }
    
    @objc func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let editedImage = info[.editedImage] as? UIImage {
                patientImageView.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                patientImageView.image = originalImage
            }

            dismiss(animated: true)
        }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
