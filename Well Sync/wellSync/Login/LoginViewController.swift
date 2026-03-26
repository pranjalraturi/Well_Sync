////
////  LoginViewController.swift
////  wellSync
////
////  Created by Rishika Mittal on 04/02/26.
////
//
//import UIKit
//
//class LoginViewController: UIViewController {
//
//    let gradient = CAGradientLayer()
//    
//    @IBOutlet weak var userName: UITextField!
//    @IBOutlet weak var passWord: UITextField!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        gradient.frame = view.bounds
//        gradient.colors = [
//            UIColor.systemCyan.withAlphaComponent(0.6).cgColor,
//            UIColor.white.cgColor
//        ]
//
//        gradient.locations = [0.0, 0.5]
//        
//        gradient.startPoint = CGPoint(x: 1, y: 0.0)
//        gradient.endPoint = CGPoint(x: 1, y: 1)
//
//        view.layer.insertSublayer(gradient, at: 0)
//    }
//    @IBOutlet weak var glassView: UIView!
//    let db = AccessSupabase.shared
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
////        glassView.clipsToBounds = true
//
//        glassView.layer.cornerRadius = 50
//        glassView.layer.borderWidth = 1
//        glassView.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
//
//        
//        glassView.layer.shadowColor = UIColor.black.cgColor
//        glassView.layer.shadowOpacity = 0.15
//        glassView.layer.shadowRadius = 20
//        glassView.layer.shadowOffset = CGSize(width: 0, height: 10)
//
//        gradient.frame = view.bounds
//        
//    }
//    
//    
//    @IBAction func loginButton(_ sender: UIButton) {
////        if userName.text == "admin" && passWord.text == "admin"
//        if userName.text == "admin" {
//            
//            let storyboard = UIStoryboard(name: "DoctorFrontPage", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "doctor")
//            
//            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
//                sceneDelegate.window?.rootViewController = vc
//                sceneDelegate.window?.makeKeyAndVisible()
//            }
//        }
//        else if userName.text == "admin1" {
//            
//            let storyboard = UIStoryboard(name: "Patient_Dashboard", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "Patient") as! TabBar
//            
//            let patient = Patient(
//                patientID: UUID(uuidString: "0849bb2f-cd51-4a64-8fed-f9b0ec25025a")!,
//                docID: UUID(uuidString: "6bf94a4d-cc66-4d87-a90d-be2500434e3d")!,
//                name: "Priya Verma",
//                dob: Date()
//            )
//
//            vc.patient = patient
//
//            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
//                sceneDelegate.window?.rootViewController = vc
//                sceneDelegate.window?.makeKeyAndVisible()
//            }
//        }
//    }
//}

//
//  LoginViewController.swift
//  wellSync
//

import UIKit

class LoginViewController: UIViewController {

    let gradient = CAGradientLayer()

    @IBOutlet weak var userName:  UITextField!
    @IBOutlet weak var passWord:  UITextField!
    @IBOutlet weak var glassView: UIView!
    // ⚠️ REMOVED: @IBOutlet weak var loginButton — it had the same name as the
    //             @IBAction below which causes a crash. Remove the outlet
    //             connection in Storyboard too (if you had one wired).

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // ─────────────────────────────────────────────────────────────
    // MARK: - Lifecycle
    // ─────────────────────────────────────────────────────────────

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupActivityIndicator()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds

        glassView.layer.cornerRadius  = 50
        glassView.layer.borderWidth   = 1
        glassView.layer.borderColor   = UIColor.white.withAlphaComponent(0.8).cgColor
        glassView.layer.shadowColor   = UIColor.black.cgColor
        glassView.layer.shadowOpacity = 0.15
        glassView.layer.shadowRadius  = 20
        glassView.layer.shadowOffset  = CGSize(width: 0, height: 10)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Setup
    // ─────────────────────────────────────────────────────────────

    private func setupGradient() {
        gradient.frame  = view.bounds
        gradient.colors = [UIColor.systemCyan.withAlphaComponent(0.6).cgColor,
                           UIColor.white.cgColor]
        gradient.locations  = [0.0, 0.5]
        gradient.startPoint = CGPoint(x: 1, y: 0.0)
        gradient.endPoint   = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemCyan
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Login Action
    // ─────────────────────────────────────────────────────────────

    @IBAction func loginButton(_ sender: UIButton) {

        guard let email    = userName.text, !email.isEmpty,
              let password = passWord.text, !password.isEmpty else {
            showAlert(message: "Please enter email and password.")
            return
        }

        setLoading(true)

        Task {
            do {
                // Step 1 ── Authenticate with Supabase Auth
                let authID = try await SupabaseManager.shared.signIn(
                    email: email, password: password)

                // Step 2 ── Determine role
                let role = try await SupabaseManager.shared.resolveRole(authID: authID)

                switch role {

                case .doctor:
                    // Step 3a ── Load doctor profile
                    let doctor = try await AccessSupabase.shared.fetchDoctorByAuthID(authID)
                    SessionManager.shared.currentDoctor = doctor
                    SessionManager.shared.saveSession(role: .doctor, doctorID: doctor.docID)

                    await MainActor.run {
                        self.setLoading(false)
                        // ✅ Single navigation call — passes doctor to HomeCollectionViewController
                        self.sceneDelegate?.showDoctorDashboard(doctor: doctor)
                    }

                case .patient:
                    // Step 3b ── Load patient profile
                    let patient = try await AccessSupabase.shared.fetchPatientByAuthID(authID)
                    SessionManager.shared.currentPatient = patient
                    SessionManager.shared.saveSession(role: .patient,
                                                      patientID: patient.patientID)

                    await MainActor.run {
                        self.setLoading(false)
                        // ✅ Single navigation call — passes patient to TabBar
                        self.sceneDelegate?.showPatientDashboard(patient: patient)
                    }

                case .none:
                    await MainActor.run {
                        self.setLoading(false)
                        self.showAlert(message: "Account not found.")
                    }
                }

            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    self.showAlert(message: "Login failed: \(error.localizedDescription)")
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: - Helpers
    // ─────────────────────────────────────────────────────────────

    private var sceneDelegate: SceneDelegate? {
        UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
    }

    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
