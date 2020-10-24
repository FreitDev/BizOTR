//
//  ExpenseTableViewCell.swift
//  BizOTR
//
//  Created by Keanu Freitas on 10/11/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var vendorNameLbl: UILabel!
    @IBOutlet weak var expenseAmountLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
