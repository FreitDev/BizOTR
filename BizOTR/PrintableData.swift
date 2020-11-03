//
//  PrintableData.swift
//  BizOTR
//
//  Created by Keanu Freitas on 11/2/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import Foundation

class PrintableData {
    
    var printName: String
    var printDate: String
    var printAmount: String
    
    init(printName: String, printDate: String, printAmount: String) {
        self.printName = printName
        self.printDate = printDate
        self.printAmount = printAmount
    }
    
}
