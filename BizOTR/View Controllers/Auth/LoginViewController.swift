//
//  LoginViewController.swift
//  BizOTR
//
//  Created by Keanu Freitas on 10/8/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupElements()
    }
    
    func setupElements() {
        
        // Hiding the error label
        errorLbl.alpha = 0
        
        // Setting the styles for the textfields
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        
        // Setting the styleds for the button
        Utilities.styleFilledButton(loginButton)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func validateTextFields() -> String? {
        
        // No fields are empty
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields!"
        }
        
        // Check password security
        let userPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(userPassword) == false {
            return "Your password must be 8 characters long and contain a special character and number."
        }
        
        return nil
    }
    
    func showError(_ message: String) {
        errorLbl.text = message
        errorLbl.alpha = 1
    }
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Stuff happens here when the login button is tapped
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                self.errorLbl.text = error!.localizedDescription
                self.errorLbl.alpha = 1
            } else {
                self.transitionToYearlyExpenseVC()
                
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "isLogin")
            }
        }
    }
    
    func transitionToYearlyExpenseVC() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
           
           // This is to get the SceneDelegate object from your view controller
           // then call the change root view controller function to change to main tab bar
           (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    
    @IBAction func noAccountBtnTapped(_ sender: Any) {
        print("Do not hsve an account yet button tapped.")
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
