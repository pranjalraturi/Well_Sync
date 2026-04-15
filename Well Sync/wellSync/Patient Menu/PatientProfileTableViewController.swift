//
//  PatientProfileTableViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 11/02/26.
//

import UIKit

class PatientProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var patient: Patient? {
        didSet {
            guard patient != nil else {
                return
            }
            Task {
                do {
                    doctor = try await AccessSupabase.shared.fetchDoctor(by: patient?.docID ?? UUID())
                    
                    DispatchQueue.main.async {
                        self.configur()
                        self.tableView.reloadData()
                    }
                } catch {
                    print(error)
                }
            }        }
    }
    var doctor: Doctor?
    @IBOutlet weak var patientImageView: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var city: UILabel!
    @IBOutlet var age: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet var doctorName: UILabel!
    @IBOutlet var doctorCity: UILabel!
    @IBOutlet var totalSession: UILabel!
    @IBOutlet var contactDoctor: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        configur()
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
    func configur() {
        guard let patient = patient else { return }
        
        name.text = patient.name
        city.text = patient.address
        email.text = patient.email
        let components = Calendar.current.dateComponents([.year], from: patient.dob, to: Date())
        age.text = "\(components.year ?? 0) yrs"
        
        loadPatientImage(from: patient.imageURL)
        doctorName.text = doctor?.name
        doctorCity.text = doctor?.address
        contactDoctor.text = doctor?.email
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    func loadPatientImage(from imageString: String?) {
        patientImageView.image = UIImage(systemName: "person.circle.fill")

        guard let imageString = imageString, !imageString.isEmpty else {
            print("No image URL found for patient.")
            return
        }

        let currentTag = UUID().uuidString
        patientImageView.accessibilityIdentifier = currentTag

        do {
            let url = try AccessSupabase.shared.getPublicImageURL(path: imageString)

            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    print("Image fetch error: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("Supabase Storage returned status: \(httpResponse.statusCode)")
                    return
                }

                guard let data = data, let image = UIImage(data: data) else {
                    print("Failed to decode image data.")
                    return
                }

                DispatchQueue.main.async {
                    if self?.patientImageView.accessibilityIdentifier == currentTag {
                        self?.patientImageView.image = image
                    }
                }
            }.resume()

        } catch {
            print("Could not resolve a valid URL from: \(imageString)")
        }
    }
}
