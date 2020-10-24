//
//  Expense.swift
//  BizOTR
//
//  Created by Keanu Freitas on 10/11/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Expense {
    
    var vendorName: String
    var expenseDate: String
    var category: String
    var expenseAmount: Int
    var uid: String
    
    init(vendorName: String, expenseDate: String, category: String, expenseAmount: Int, uid: String) {
        self.vendorName = vendorName
        self.expenseDate = expenseDate
        self.category = category
        self.expenseAmount = expenseAmount
        self.uid = uid
    }
    
}

enum ExpenseCategory: Int, Codable {
  case supplies
  case food
  case gas
}
//
//struct Expense: Identifiable, Codable {
//    @DocumentID var id: String?
//    @ServerTimestamp var createdTime: Timestamp?
//    var vendorName: String
//    
//    var userId: String?
//    var expenseAmount: Int
//    var category: ExpenseCategory
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case vendorName
//        case createdTime
//        case userId
//        case expenseAmount
//        case category
//    }
//}


