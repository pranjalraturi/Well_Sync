//
//  BasicDetailsTableViewController.swift
//  wellSync
//
//  Created by GEU on 11/02/26.
//

import UIKit

class BasicDetailsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var DoctorImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var experienceTextField: UITextField!
    
//    var doctor: Doctor!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPhotoMenu()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    var username: String!
    var email: String!
    var password: String!

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
                DoctorImageView.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                DoctorImageView.image = originalImage
            }

            dismiss(animated: true)
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true)
        }
    
@IBAction func nextButtonTapped(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty,
              let dob = dobTextField.text, !dob.isEmpty,
              let address = addressTextField.text, !address.isEmpty,
              let experience = experienceTextField.text, !experience.isEmpty else{
            showAlert(message: "Please fill all fields")
            return
        }
//        doctor.name = name
//        doctor.dob = dob
//        doctor.address = address
//        doctor.experience = Int(experience)
//        doctor.doctorImage = DoctorImageView.image!
//    performSegue(withIdentifier: "basic_to_education", sender: self)
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "basic_to_education"{
            if let destinationVC = segue.destination as? EducationDetailsTableViewController{
//                destinationVC.doctor = doctor
                destinationVC.username = username
                destinationVC.email = email
                destinationVC.password = password
                destinationVC.name = nameTextField.text
                destinationVC.dob = dobTextField.text
                destinationVC.docImage = DoctorImageView.image
                destinationVC.address = addressTextField.text
                destinationVC.experience = Int(experienceTextField.text!)
                
            }
        }
    }
}
