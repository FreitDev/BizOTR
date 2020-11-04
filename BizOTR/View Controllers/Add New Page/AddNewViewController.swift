//
//  AddNewViewController.swift
//  BizOTR
//
//  Created by Keanu Freitas on 10/8/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import ProgressHUD

class AddNewViewController: UIViewController {

    @IBOutlet weak var vendorNameTextField: UITextField!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var expenseAmountTextField: UITextField!
    @IBOutlet weak var expenseDatePicker: UIDatePicker!
    @IBOutlet weak var nameErrorLabl: UILabel!
    @IBOutlet weak var expenseErrorLabl: UILabel!
    
    var categoryOptions = ["Supplies", "Food", "Gas"]
    var expense: Expense!
    var name: String!
    var category = "Supplies"
    var amount = 0
    var date: Date!
    var stringDate = String()
    var uid: String!
    
    var numberformatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    let db = Firestore.firestore()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        
        setupElements()
    }
    
    
    func setupElements() {
        
        // Setting the styles for the textfields
        Utilities.plainsSyleTextField(vendorNameTextField)
        Utilities.plainsSyleTextField(expenseAmountTextField)
        expenseAmountTextField.placeholder = updateTextField()
        expenseAmountTextField.delegate = self
        
        // Setup the error labels
        nameErrorLabl.alpha = 0
        expenseErrorLabl.alpha = 0
        
        // Set the uid as long as it is passed from login or sign in
        if let userId = defaults.string(forKey: "uid") {
            uid = userId
        }
        
        //Setting the add button in the navigation bar.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        
        // Setting up to add keyboard observer functionality.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func showError(_ message: String, choice: Int) {
        
        if choice == 0 {
            nameErrorLabl.text = message
            nameErrorLabl.alpha = 1
        } else {
            expenseErrorLabl.text = message
            expenseErrorLabl.alpha = 1
        }
        
    }
    
    func collectDataFromForm() {
        
        if ((vendorNameTextField.text?.isEmpty) != nil) && vendorNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showError("Error, please add a vendor name!", choice: 0)
        } else {
            nameErrorLabl.alpha = 0
            if ((expenseAmountTextField.text?.isEmpty) != nil) && expenseAmountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                showError("Error, please add a expense amount!", choice: 1)
            } else {
                
                expenseErrorLabl.alpha = 0
                
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                
                name = vendorNameTextField.text
                // Getting the date from date picker
                date = expenseDatePicker.date
                if date != nil {
                    
                    stringDate = formatter.string(from: date!)
                    print("name: \(name ?? ""), amount: \(amount), date: \(stringDate)", "category: \(category)")
                    
                    //expense = Expense(vendorName: name, expenseDate: stringDate, category: category, expenseAmount: amount)
                    
                    let expenseDict = [
                            "name" : name! as String,
                            "amount" : amount as Int,
                            "date" : stringDate as String,
                            "category" : category as String,
                        "uid" : uid as String
                        ] as [String : Any]
                    
                    // Show progress indicator.
                    ProgressHUD.show("Loading", icon: AnimatedIcon.added, interaction: false)
                    saveData(expense: expenseDict)
                    
                    // Run the save data function
                    //saveData(expense: expense)
                }
            }
        }
    }
    
    func saveData(expense: [String: Any]) {
        
        print("Add expense process started...")
        var ref: DocumentReference? = nil
        ref = db.collection("expenses").addDocument(data: expense) { (error) in
            if let err = error {
                   print("Error adding document: \(err)")
               } else {
                   print("Document added with ID: \(ref!.documentID)")
                // Proggress Indicator
                ProgressHUD.showSucceed()
               }
        }
    }
    
    @objc func addTapped() {
        print("Add button tapped!")
        collectDataFromForm()
        resetTextFields()
    }
    
    func updateTextField() -> String? {
        
        let number = Double(amount/100) + Double(amount%100)/100
        return numberformatter.string(from: NSNumber(value: number))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // Keyboard functions for scroll when textfield selected.
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddNewViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            category = "Supplies"
        } else if row == 1 {
           category = "Food"
        } else if row == 2 {
            category = "Gas"
        }
    }
}

extension AddNewViewController: UITextFieldDelegate {
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let digit = Int(string) {
            amount = amount * 10 + digit
            expenseAmountTextField.text = updateTextField()
        }
        
        if string == "" {
            amount = amount/10
            expenseAmountTextField.text = updateTextField()
        }
        return false
    }
}
