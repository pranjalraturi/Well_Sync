//
//  RegisterViewController.swift
//  wellSync
//
//  Created by GEU on 12/02/26.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

//    var doctor = Doctor()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
@IBAction func SignupButton(_ sender: Any) {
        guard let username = usernameTextField.text, !username.isEmpty,
          let email = emailTextField.text, !email.isEmpty,
          let password = passwordTextField.text, !password.isEmpty,
          let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
        showAlert(message: "Please fill in all fields.")
        return
    }
    
    guard password == confirmPassword else{
        showAlert(message: "Passwords do not match.")
        return
    }
//    doctor.username = username
//    doctor.email = email
//    doctor.password = password
    
//    performSegue(withIdentifier: "register_to_basic", sender: self)
}
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "register_to_basic" {
            if let destinationVC = segue.destination as? BasicDetailsTableViewController {
                destinationVC.username = usernameTextField.text
                destinationVC.email = emailTextField.text
                destinationVC.password = passwordTextField.text
            }
        }
    }
}
