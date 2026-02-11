//
//  AddPatientTableViewController.swift
//  wellSync
//
//  Created by GEU on 31/01/26.
//

import UIKit

class AddPatientTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var patientImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addPhotoTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add Photo", message: "choose an Option", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) {_ in self.openImagePicker(sourceType: .camera)})
        }
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) {_ in
            self.openImagePicker(sourceType: .photoLibrary)})
        present(alert, animated: true)
    }
    
    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
           let picker = UIImagePickerController()
           picker.delegate = self
           picker.sourceType = sourceType
           picker.allowsEditing = true
           present(picker, animated: true)
       }
    
    func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let editedImage = info[.editedImage] as? UIImage {
                patientImageView.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                patientImageView.image = originalImage
            }

            dismiss(animated: true)
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true)
        }
}
