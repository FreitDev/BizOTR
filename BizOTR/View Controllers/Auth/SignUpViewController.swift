//
//  SignUpViewController.swift
//  BizOTR
//
//  Created by Keanu Freitas on 10/8/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
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
        Utilities.styleTextField(firstnameTextField)
        Utilities.styleTextField(lastnameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        
        // Setting the styleds for the button
        Utilities.styleFilledButton(signupButton)
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
        if firstnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
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
    
    @IBAction func signupTapped(_ sender: Any) {
        // Things happen here when the signup button is tapped
        
        // Validate textfields
        let error = validateTextFields()
        
        if error != nil {
            showError(error!)
        } else {
            // Create variables
            let firstname = firstnameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastname = lastnameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create a user
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    print("error: \(error?.localizedDescription ?? "error")")
                    self.showError("Error creating user!")
                }
                else {
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["first_name" : firstname, "last_name": lastname, "uid": result!.user.uid]) { (error) in
                        if error != nil {
                            print("Error")
                            self.showError("Error saving user data, please try again later")
                        }
                        print("User created successfully!")
                        self.transitionToYearlyExpenseVC()
                    }
                }
            }
        }
        // Segue to the next page
    }
    
    func transitionToYearlyExpenseVC() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
           
           // This is to get the SceneDelegate object from your view controller
           // then call the change root view controller function to change to main tab bar
           (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    
    @IBAction func alreadyHaveAccountBtnTapped(_ sender: Any) {
        
        print("Dismiss button pressed")
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
