//
//  SignInVC.swift
//  ChatApp
//
//  Created by Marcus Tam on 3/10/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {

    private let CONTACTS_SEGUE = "ContactsSegue"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    override func viewDidAppear(_ animated: Bool) {
        if AuthProvider.Instance.isLoggedIn() {
            self.performSegue(withIdentifier: self.CONTACTS_SEGUE, sender: nil)

        }
    }
    
    
    @IBAction func LogIn(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.Instance.login(withEmail: emailTextField.text!, withPassword: passwordTextField.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertTheUser(title: "Problem with Authentication", message: message!)
                    
                } else {
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.performSegue(withIdentifier: self.CONTACTS_SEGUE, sender: nil)

                }
            })
            
            

        } else {
            alertTheUser(title: "Email and Password are required", message: "Please enter email and password")
        }
        
    }

    @IBAction func signUp(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.Instance.signUp(email: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertTheUser(title: "Problem with Creating a New User", message: message!)
                    
                } else {
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.performSegue(withIdentifier: self.CONTACTS_SEGUE, sender: nil)
                }
            })
            
        } else {
            alertTheUser(title: "Email and Password are required", message: "Please enter email and password")
        }
    }
    
    private func alertTheUser(title: String, message: String) {
        let alert  = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
} //Class
