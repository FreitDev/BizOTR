//
//  AddNewViewController.swift
//  BizOTR
//
//  Created by Keanu Freitas on 10/8/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import UIKit

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
    var category: String!
    var amount = 0
    var date: Date!
    
    var numberformatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
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
        
        //Setting the add button in the navigation bar.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
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
            if ((expenseAmountTextField.text?.isEmpty) != nil) && expenseAmountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                
                name = vendorNameTextField.text
                // Getting the date from date picker
                date = expenseDatePicker.date
                if date != nil {
                    let stringDate = formatter.string(from: date!)
                    print("name: \(name ?? ""), amount: \(amount), date: \(stringDate)", "category: \(category ?? "")")
                    expense = Expense(vendorName: name, expenseDate: stringDate, category: category, expenseAmount: amount)
                }
                
            } else {
                showError("Error, please add a expense amount!", choice: 1)
            }
        } else {
            showError("Error, please add a vendor name!", choice: 0)
        }
    }
    
    func saveData(expense: Expense) {
        print("Saving data...")
    }
    
    @objc func addTapped() {
        print("Add button tapped!")
        collectDataFromForm()
        saveData(expense: expense)
    }
    
    func updateTextField() -> String? {
        
        let number = Double(amount/100) + Double(amount%100)/100
        return numberformatter.string(from: NSNumber(value: number))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
        } else {
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
