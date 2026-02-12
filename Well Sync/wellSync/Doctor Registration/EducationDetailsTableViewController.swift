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
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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

}
