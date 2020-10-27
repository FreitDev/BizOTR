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
    
        name = ""
        category = "Supplies"
        categoryPickerView.selectRow(0, inComponent: 0, animated: true)
        amount = 0
        stringDate = String()
        
        vendorNameTextField.text = ""
        expenseAmountTextField.text = ""
        nameErrorLabl.alpha = 0
        expenseErrorLabl.alpha = 0
    }
    
}
