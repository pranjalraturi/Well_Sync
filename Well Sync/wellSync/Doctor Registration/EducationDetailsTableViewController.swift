//
//  EducationDetailsTableViewController.swift
//  wellSync
//
//  Created by GEU on 11/02/26.
//

import UIKit
import UniformTypeIdentifiers

class EducationDetailsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    @IBOutlet weak var educationImageView: UIImageView!
    @IBOutlet weak var educationCertificateLabel: UILabel!
    @IBOutlet weak var educationAttachment: UIButton!
    @IBOutlet weak var registrationImageView: UIImageView!
    @IBOutlet weak var registrationDocumentLabel: UILabel!
    @IBOutlet weak var registrationAttachment: UIButton!
    @IBOutlet weak var identityImageView: UIImageView!
    @IBOutlet weak var identityDocumentLabel: UILabel!
    @IBOutlet weak var identityAttachment: UIButton!
    @IBOutlet weak var qualificationTextField: UITextField!
    @IBOutlet weak var registrationTextField: UITextField!
    @IBOutlet weak var identityTextField: UITextField!
    var selectedFileName: String?
    enum AttachmentType {
        case education
        case registration
        case identity
    }

    var currentAttachmentType: AttachmentType?
    override func viewDidLoad() {
        super.viewDidLoad()

        educationCertificateLabel.text = "Add Certificate"
        educationCertificateLabel.textColor = .secondaryLabel
        registrationDocumentLabel.text = "Add Registration proof"
        registrationDocumentLabel.textColor = .secondaryLabel
        identityDocumentLabel.text = "Add ID Document"
        identityDocumentLabel.textColor = .secondaryLabel
        setupMenu()
        

    }
//    var doctor: Doctor!
    var username: String!
    var email: String!
    var password: String!
    var name: String!
    var dob: String!
    var address: String!
    var experience: Int!
    var docImage: UIImage?
    
    func setupMenu() {
           
        educationAttachment.menu = createMenu(for: .education)
        registrationAttachment.menu = createMenu(for: .registration)
        identityAttachment.menu = createMenu(for: .identity)
        educationAttachment.showsMenuAsPrimaryAction = true
        registrationAttachment.showsMenuAsPrimaryAction = true
        identityAttachment.showsMenuAsPrimaryAction = true

       }
    
    func createMenu(for type: AttachmentType) -> UIMenu {
        
        let camera = UIAction(title: "Camera",
                              image: UIImage(systemName: "camera")) { _ in
            self.currentAttachmentType = type
            self.openImagePicker(sourceType: .camera)
        }
        let photoLibrary = UIAction(title: "Photo Library",
                                    image: UIImage(systemName: "photo")) { _ in
            self.currentAttachmentType = type
            self.openImagePicker(sourceType: .photoLibrary)
        }
        
        let attachFile = UIAction(title: "Attach File",
                                  image: UIImage(systemName: "doc")) { _ in
            self.currentAttachmentType = type
            self.openDocumentPicker()
        }
        
        return UIMenu(title: "", children: [camera, photoLibrary, attachFile])
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

        var selectedImage: UIImage?
            if let editedImage = info[.editedImage] as? UIImage {
                selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
               selectedImage = originalImage
            }
        guard let image = selectedImage else {return}
        switch currentAttachmentType {
            case .education:
                educationImageView.image = image
                educationCertificateLabel.text = "Document Added"
                educationCertificateLabel.textColor = .label
                
            case .registration:
                registrationImageView.image = image
                registrationDocumentLabel.text = "Document Added"
                registrationDocumentLabel.textColor = .label
                
            case .identity:
                identityImageView.image = image
                identityDocumentLabel.text = "Document Added"
                identityDocumentLabel.textColor = .label
                
            default:
                break
            }
            dismiss(animated: true)
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true)
        }
    
    func openDocumentPicker() {
           
           let types: [UTType] = [.pdf, .image]
           
           let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
           picker.delegate = self
           picker.allowsMultipleSelection = false
           present(picker, animated: true)
       }
       
       func documentPicker(_ controller: UIDocumentPickerViewController,
                           didPickDocumentsAt urls: [URL]) {
           
           guard let url = urls.first else { return }
           
           let fileName = url.lastPathComponent
           switch currentAttachmentType {
               case .education:
                   educationCertificateLabel.text = fileName
                   educationCertificateLabel.textColor = .label
                   
               case .registration:
                   registrationDocumentLabel.text = fileName
                   registrationDocumentLabel.textColor = .label
                   
               case .identity:
                   identityDocumentLabel.text = fileName
                   identityDocumentLabel.textColor = .label
                   
               default:
                   break
               }
           controller.dismiss(animated: true)
       }
//@IBAction func saveButtonTapped(_ sender: Any) {
//    let qualification = qualificationTextField.text
//    let registrationNumber = registrationTextField.text
//    let identityNumber = identityTextField.text
//    let educationImage = educationImageView.image
//    let educationImagePath = ""
//    let identityImage = identityImageView.image
//    let identityImageDataPath = ""
//    let registrationImage = registrationImageView.image
//    let registrationImagePath = ""
//    
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust to your actual input format if different
//    let parsedDOB = dob != nil ? dateFormatter.date(from: dob!) ?? Date() : Date()
//    
//    let doctor = Doctor(
//        docID: UUID(), username: username,
//        email: email,
//        password: password,
//        name: name,
//        dob: parsedDOB,
//        address: address,
//        experience: experience,
//        doctorImage: "",
//        qualification: "",
//        registrationNumber: registrationNumber,
//        identityNumber: identityNumber,
//        educationImageData: educationImagePath,
//        registrationImageData: registrationImagePath,
//        identityImageData: identityImageDataPath
//    )
////    let doctor = currentDoctor!
//    print("Doctor object created")
//    print(doctor)
//    UserDoctors.append(doctor)
//    print("the array of user doctors")
//    print(UserDoctors)
//    performSegue(withIdentifier: "successFull", sender: nil)
//    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "successFull" {
//            self.navigationController?.isNavigationBarHidden = true
//        }
//    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let qualification = qualificationTextField.text, !qualification.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let parsedDOB = dob != nil ? dateFormatter.date(from: dob!) ?? Date() : Date()
        
        let parsedDOB: Date

        if let dobString = dob, !dobString.isEmpty,
           let date = dateFormatter.date(from: dobString) {
            parsedDOB = date
        } else {
            parsedDOB = Date()
        }
        // Show loading
        let alert = UIAlertController(title: nil, message: "Registering...", preferredStyle: .alert)
        present(alert, animated: true)
        
        Task {
            do {
                // Step 1: Create Supabase Auth account → get auth UUID
                let authID = try await SupabaseManager.shared.signUp(
                    email: email,
                    password: password
                )
                var imagePath: String? = nil
                if let image = docImage {
                    imagePath = try await AccessSupabase.shared.uploadProfileImage(image)
                }
                // Step 2: Save doctor profile to doctors table, linking auth_id
                let doctor = Doctor(
                    docID: UUID(),
                    authID: authID,           // ← Link to Supabase Auth
                    username: username,
                    email: email,
                    // No password field anymore
                    name: name,
                    dob: parsedDOB,
                    address: address,
                    experience: experience,
                    doctorImage: imagePath,
                    qualification: qualification,
                    registrationNumber: registrationTextField.text,
                    identityNumber: identityTextField.text,
                    educationImageData: "",
                    registrationImageData: "",
                    identityImageData: ""
                )
                
                try await AccessSupabase.shared.saveDoctor(doctor: doctor)
                
                await MainActor.run {
                    alert.dismiss(animated: true) {
                        SessionManager.shared.currentDoctor = doctor

                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = scene.windows.first {

                            let storyboard = UIStoryboard(name: "DoctorFrontPage", bundle: nil)
                            let homeVC = storyboard.instantiateViewController(withIdentifier: "doctor")

                            window.rootViewController = homeVC
                            window.makeKeyAndVisible()
                        }
                    }
                }
                
            } catch {
                await MainActor.run {
                    alert.dismiss(animated: true) {
                        self.showAlert(message: "Registration failed: \(error.localizedDescription)")
                    }
                    
                }
            }
        }
    }
    private func showAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
}
