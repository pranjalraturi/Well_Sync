//
//  AddPatientTableViewController.swift
//  wellSync
//
//  Created by GEU on 31/01/26.
//

import UIKit
import Foundation

class AddPatientTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var patient: Patient?
//    var doctor: Doctor -> this would be passsed from screen to screen
    
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var dateOfBirth: UITextField!
    @IBOutlet var address: UITextField!
    @IBOutlet var contact: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var patientCase: UITextField!
    @IBOutlet var weight: UITextField!
    @IBOutlet var moreInfo: UITextField!
    
    
    @IBOutlet var patientImageView: UIImageView!
    @IBOutlet var addPhotoButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPhotoMenu()
        
    }

    func setupPhotoMenu() {
           
           let camera = UIAction(title: "Camera",
                                 image: UIImage(systemName: "camera")) { _ in
               self.openImagePicker(sourceType: .camera)
           }
           
           let photoLibrary = UIAction(title: "Photo Library",
                                       image: UIImage(systemName: "photo")) { _ in
               self.openImagePicker(sourceType: .photoLibrary)
           }
           
           let menu = UIMenu(title: "", children: [camera, photoLibrary])
           
           addPhotoButton.menu = menu
           addPhotoButton.showsMenuAsPrimaryAction = true
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard
            let name = fullName.text,
            let emailText = email.text,
            let contactText = contact.text,
            let addressText = address.text
        else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dobDate = formatter.date(from: dateOfBirth.text ?? "") ?? Date()
        
        let generatedPass = generateSecurePassword()
        patient = Patient(
            patientID: UUID(),
//            docID: doctor.docID, //this would be passsed from screen to screen
            docID: UUID(),
            name: name,
            email: emailText,
            password: generatedPass,
            contact: contactText,
            dob: dobDate,
            nextSessionDate: Date(),
            imageURL: nil,
            address: addressText
        )
//        AllPatients.append(patient!)

    }
    func generateSecurePassword() -> String {

        let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let lowercase = "abcdefghijklmnopqrstuvwxyz"
        let numbers = "0123456789"
        let symbols = "!@#$%^&*-_?"

        let allChars = uppercase + lowercase + numbers + symbols

        var password = ""

        password.append(uppercase.randomElement()!)
        password.append(lowercase.randomElement()!)
        password.append(numbers.randomElement()!)
        password.append(symbols.randomElement()!)

        while password.count < 8 {
            password.append(allChars.randomElement()!)
        }

        return String(password.shuffled())
    }
}
