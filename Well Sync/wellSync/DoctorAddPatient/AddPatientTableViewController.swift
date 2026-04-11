////
////  AddPatientTableViewController.swift
////  wellSync
////
////  Created by GEU on 31/01/26.
////

import UIKit
import Foundation
 
class AddPatientTableViewController: UITableViewController,
                                     UIImagePickerControllerDelegate,
                                     UINavigationControllerDelegate {
 
    // ─── Passed from HomeCollectionViewController ───
    // This is set in HomeCollectionViewController's prepare(for:segue:)
    // See the note at the bottom of this file for the one-line change needed there.
    var doctor: Doctor?
    
    var patient:   Patient?
    var onDismiss: (() -> Void)?
 
    // ─── Outlets ───
    @IBOutlet weak var fullName:       UITextField!
    @IBOutlet var address:             UITextField!
    @IBOutlet var contact:             UITextField!
    @IBOutlet var email:               UITextField!
    @IBOutlet var patientCase:         UITextField!
    @IBOutlet var weight:              UITextField!
    @IBOutlet var moreInfo:            UITextField!
    @IBOutlet var patientImageView:    UIImageView!
    @IBOutlet var addPhotoButton:      UIButton!
    @IBOutlet var dateOfBirth:         UIDatePicker!
    @IBOutlet var gender:              UIButton!
 
    // ─────────────────────────────────────────────────────────────
    // MARK: - Lifecycle
    // ─────────────────────────────────────────────────────────────
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPhotoMenu()
        
        dateOfBirth.maximumDate = Date()
        
        setupGenderMenu()
        
//        dateOfBirth.preferredDatePickerStyle = .compact
//        dateOfBirth.datePickerMode = .date
    }
 
    // ─────────────────────────────────────────────────────────────
    // MARK: - Photo picker  (unchanged from original)
    // ─────────────────────────────────────────────────────────────
 
    func setupPhotoMenu() {
        let camera = UIAction(title: "Camera",
                              image: UIImage(systemName: "camera")) { _ in
            self.openImagePicker(sourceType: .camera)
        }
        let photoLibrary = UIAction(title: "Photo Library",
                                    image: UIImage(systemName: "photo")) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        }
        addPhotoButton.menu = UIMenu(title: "", children: [camera, photoLibrary])
        addPhotoButton.showsMenuAsPrimaryAction = true
    }

    func setupGenderMenu() {
        
        gender.setTitle("Select", for: .normal)
        let options = ["Male", "Female", "Other", "Not Specified"]
        let menuChildren = options.map { title in
            UIAction(title: title){ _ in
                self.gender.setTitle(title, for: .normal)
            }
        }
        
        gender.menu = UIMenu(children: menuChildren)
        gender.showsMenuAsPrimaryAction = true
        gender.changesSelectionAsPrimaryAction = false
    }
 
    @IBAction func addPhotoTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add Photo",
                                      message: "Choose an option",
                                      preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.openImagePicker(sourceType: .camera)
            })
        }
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        })
        present(alert, animated: true)
    }
 
    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate    = self
        picker.sourceType  = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }
 
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let edited   = info[.editedImage]   as? UIImage { patientImageView.image = edited }
        else if let orig = info[.originalImage] as? UIImage { patientImageView.image = orig }
        dismiss(animated: true)
    }
 
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
 
    // ─────────────────────────────────────────────────────────────
    // MARK: - Password generator  (unchanged from original)
    // ─────────────────────────────────────────────────────────────
 
    func generateSecurePassword() -> String {
        let upper   = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let lower   = "abcdefghijklmnopqrstuvwxyz"
        let numbers = "0123456789"
        let symbols = "!@#$%^&*-_?"
        let all     = upper + lower + numbers + symbols
 
        var password = ""
        password.append(upper.randomElement()!)
        password.append(lower.randomElement()!)
        password.append(numbers.randomElement()!)
        password.append(symbols.randomElement()!)
        while password.count < 8 { password.append(all.randomElement()!) }
        return String(password.shuffled())
    }
 
    // ─────────────────────────────────────────────────────────────
    // MARK: - Save  ← KEY CHANGES HERE
    // ─────────────────────────────────────────────────────────────
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
 
        // ── 1. Validate required fields ──
        guard let name        = fullName.text,  !name.isEmpty,
              let emailText   = email.text,     !emailText.isEmpty,
              let contactText = contact.text,   !contactText.isEmpty,
              let addressText = address.text,   !addressText.isEmpty else {
            showAlert(title: "Missing fields",
                      message: "Please fill in Name, Email, Contact, and Address.")
            return
        }
 
        // ── 2. Resolve which doctor is adding this patient ──
        //       Priority: passed-in `doctor` property → SessionManager fallback
        let resolvedDoctor = doctor ?? SessionManager.shared.currentDoctor
        guard let docID = resolvedDoctor?.docID else {
            showAlert(title: "Error",
                      message: "Could not identify the logged-in doctor. Please log out and log in again.")
            return
        }
 
        // ── 3. Parse date of birth ──
//        let formatter        = DateFormatter()
//        formatter.dateFormat = "dd/MM/yyyy"
        let dobDate = dateOfBirth.date
        let selectedGender : String?
        if gender.currentTitle == "Select" || gender.currentTitle == nil {
            selectedGender = nil
        }else{
            selectedGender = gender.currentTitle
        }
 
        // ── 4. Generate a secure temporary password for the patient ──
        let generatedPassword = generateSecurePassword()
 
        // ── 5. Show loading ──
        let loadingAlert = makeLoadingAlert(message: "Creating patient account…")
        present(loadingAlert, animated: true)
 
        Task {
            do {
                // ── 6. Upload profile image if one was selected ──
                var imagePath: String? = nil
                if let image = patientImageView.image {
                    imagePath = try await AccessSupabase.shared.uploadProfileImage(image)
                }
 
                // ── 7. Create Supabase Auth account for the patient ──
                //       This gives us the auth UUID to store in the patients table.
                //       If email confirmation is ON in Supabase, signUp() throws
                //       "AuthEmailConfirmation" — we catch that below and still save
                //       the patient row (the account exists, just not confirmed yet).
                var authID: UUID? = nil
                do {
                    authID = try await SupabaseManager.shared.signUp(
                        email: emailText,
                        password: generatedPassword
                    )
                } catch let error as NSError where error.domain == "AuthEmailConfirmation" {
                    // Email confirmation is enabled — account was created, auth_id returned
                    // We still get the user from the error's userInfo if needed,
                    // but signUp() throws before returning the UUID in this case.
                    // Solution: disable email confirmation in Supabase Dashboard → Auth → Settings
                    // OR handle it by fetching the user separately. For now we proceed without authID.
                    print("WellSync — email confirmation pending for patient: \(emailText)")
                }
 
                // ── 8. Build and save the Patient row ──
                let newPatient = Patient(
                    patientID: UUID(),
                    docID:     docID,              // ✅ real doctor ID from SessionManager
                    authID:    authID,             // ✅ links patient row to Supabase Auth
                    name:      name,
                    email:     emailText,
                    // NO password field — Supabase Auth owns it now
                    contact:              contactText,
                    dob:                  dobDate,
                    address:              addressText,
                    condition:            patientCase.text,
                    sessionStatus:        false,
                    nextSessionDate:      Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
                    imageURL:             imagePath,
                    previousSessionDate:  Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
                    gender :              selectedGender
                )
 
                try await AccessSupabase.shared.savePatient(newPatient)
                try await AccessSupabase.shared.saveCaseHistory(newPatient.patientID)
 
                self.patient = newPatient
 
                // ── 9. Show the doctor the generated credentials to share with patient ──
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        self.showCredentials(email: emailText, password: generatedPassword)
                    }
                }
 
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        self.showAlert(title: "Error saving patient",
                                       message: error.localizedDescription)
                        print(error)
                    }
                }
            }
        }
    }
 
    // ─────────────────────────────────────────────────────────────
    // MARK: - Show credentials to doctor
    // ─────────────────────────────────────────────────────────────
 
    // After saving, show the doctor the login credentials so they can
    // share them with the patient (e.g., write them down or screenshot).
    private func showCredentials(email: String, password: String) {
        let alert = UIAlertController(
            title: "Patient Account Created ✅",
            message: """
            Share these login credentials with the patient:
            
            📧 Email:    \(email)
            🔑 Password: \(password)
            
            The patient can log in with these details and change their password later.
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            self.onDismiss?()
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
 
    // ─────────────────────────────────────────────────────────────
    // MARK: - Helpers
    // ─────────────────────────────────────────────────────────────
 
    private func makeLoadingAlert(message: String) -> UIAlertController {
        let alert     = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor),
            indicator.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -20)
        ])
        return alert
    }
 
    private func showAlert(title: String = "Error", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
