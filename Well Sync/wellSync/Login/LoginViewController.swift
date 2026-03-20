//
//  LoginViewController.swift
//  wellSync
//
//  Created by Rishika Mittal on 04/02/26.
//

import UIKit

class LoginViewController: UIViewController {

    let gradient = CAGradientLayer()
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor.systemCyan.withAlphaComponent(0.6).cgColor,
            UIColor.white.cgColor
        ]

        gradient.locations = [0.0, 0.5]
        
        gradient.startPoint = CGPoint(x: 1, y: 0.0)
        gradient.endPoint = CGPoint(x: 1, y: 1)

        view.layer.insertSublayer(gradient, at: 0)
        Task{
            do{
//                try await AccessSupabase.shared.saveDoctor()
                print("-----------------\n",try await AccessSupabase.shared.fetchMoodLogs(patientID: UUID(uuidString: "d207cf78-d29e-4bf1-91d2-66a5c26fd895")!))
            }
            catch{
                print("Error", error)
            }
        }
    }
    @IBOutlet weak var glassView: UIView!
    let db = AccessSupabase.shared
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        glassView.clipsToBounds = true

        glassView.layer.cornerRadius = 50
        glassView.layer.borderWidth = 1
        glassView.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor

        
        glassView.layer.shadowColor = UIColor.black.cgColor
        glassView.layer.shadowOpacity = 0.15
        glassView.layer.shadowRadius = 20
        glassView.layer.shadowOffset = CGSize(width: 0, height: 10)

        gradient.frame = view.bounds
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
//        if userName.text == "admin" && passWord.text == "admin"
        if userName.text == "admin" {
            
            let storyboard = UIStoryboard(name: "DoctorFrontPage", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "doctor")
            
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = vc
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
        else if userName.text == "admin1" {
            
            let storyboard = UIStoryboard(name: "Patient_Dashboard", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Patient")
            
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = vc
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }
}
