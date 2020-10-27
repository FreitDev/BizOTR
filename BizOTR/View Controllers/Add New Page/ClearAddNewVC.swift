//
//  ClearAddNewVC.swift
//  BizOTR
//
//  Created by Keanu Freitas on 10/26/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import Foundation

extension AddNewViewController {
    
    func resetTextFields() {
    
        expense = Expense(vendorName: "", expenseDate: "", category: "", expenseAmount: 0, uid: "")
        name = ""
        category = "Supplies"
        amount = 0
        stringDate = String()
        
        vendorNameTextField.text = ""
        expenseAmountTextField.text = ""
        nameErrorLabl.alpha = 0
        expenseErrorLabl.alpha = 0
    }
    
}
