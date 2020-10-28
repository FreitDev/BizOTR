//
//  YearlyExpenseViewController.swift
//  BizOTR
//
//  Created by Keanu Freitas on 9/18/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import UIKit
import FirebaseFirestore

class YearlyExpenseViewController: UIViewController, ObservableObject, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var ExpenseTotalLbl: UILabel!
    @IBOutlet weak var ExpenseSheetYearNavLbl: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoreySegmentControl: UISegmentedControl!
    
    var expenses = [Expense]()
    var suppliesExpenses = [Expense]()
    var foodExpenses = [Expense]()
    var gasExpenses = [Expense]()
    var uid = String()
    var totalExpenses = 0
    var updatedTotal = 0
    var rowCount = 0
    var index = 0
    
    let db = Firestore.firestore()
    let defaults = UserDefaults.standard
    
    var numberformatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupElements()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetEverything()
        getDataFromFirestore()
    }
    
    func resetEverything() {
        totalExpenses = 0
        updatedTotal = 0
        expenses = [Expense]()
        suppliesExpenses = [Expense]()
        foodExpenses = [Expense]()
        gasExpenses = [Expense]()
    }
    
    func getDataFromFirestore() {
        // Fetch the expenses for this user....
        
        let expenseRef = db.collection("expenses")
        
        // Create a query against the collection.
        let query = expenseRef.whereField("uid", isEqualTo: uid)
        
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    self.expenses.append(Expense(vendorName: document.get("name") as! String, expenseDate: document.get("date") as! String, category: document.get("category") as! String, expenseAmount: document.get("amount") as! Int, uid: document.get("uid") as! String, docId: document.documentID))
                    
                    // Setting the total expenses
                    self.totalExpenses += (document.get("amount") as! Int)
                }
                
                // Create a method for this...
                let updatedTotal = self.totalExpenses
                print("Total: \(String(updatedTotal))")
                self.ExpenseTotalLbl.text = self.getValue(amount: updatedTotal)
                
                // Trying to sort the expenses.
                self.expenses = self.expenses.sorted(by: {
                    $0.expenseDate.compare($1.expenseDate) == .orderedDescending
                })
                
                self.queryExpenses(expenses: self.expenses)
                
                DispatchQueue.main.async {
                    // We have to reload the tableview when we gather the expense data.
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func setupElements() {
        
        // Set the uid as long as it is passed from login or sign in
        if let userId = defaults.string(forKey: "uid") {
            uid = userId
        }
    }
    
    @IBAction func categoryControlChanged(_ sender: Any) {
        
        switch categoreySegmentControl.selectedSegmentIndex
        {
        case 1:
            tableView.reloadData()
            runTotals(category: Constants.Category.supplies)
            break
        case 2:
            tableView.reloadData()
            runTotals(category: Constants.Category.food)
            break
        case 3:
            tableView.reloadData()
            runTotals(category: Constants.Category.gas)
            break
        default:
            tableView.reloadData()
            runTotals(category: "default")
            break
        }
    }
    
    func queryExpenses(expenses: [Expense]) {
        
        for expense in expenses {
            if expense.category == Constants.Category.supplies {
                suppliesExpenses.append(expense)
            } else if expense.category == Constants.Category.food {
                foodExpenses.append(expense)
            } else if expense.category == Constants.Category.gas {
                gasExpenses.append(expense)
            }
        }
    }
    
    func runTotals(category: String) {
        
        if category == Constants.Category.supplies {
            //tableView.reloadData()
            updatedTotal = 0
            for supply in suppliesExpenses {
                updatedTotal += supply.expenseAmount
            }
            ExpenseTotalLbl.text! = getValue(amount: updatedTotal)
        } else if category == Constants.Category.food {
            //tableView.reloadData()
            updatedTotal = 0
            for food in foodExpenses {
                updatedTotal += food.expenseAmount
            }
            ExpenseTotalLbl.text! = getValue(amount: updatedTotal)
        } else if category == Constants.Category.gas {
            //tableView.reloadData()
            updatedTotal = 0
            for gas in gasExpenses {
                updatedTotal += gas.expenseAmount
            }
            ExpenseTotalLbl.text! = getValue(amount: updatedTotal)
        } else {
            //tableView.reloadData()
            updatedTotal = 0
            for expense in expenses {
                updatedTotal += expense.expenseAmount
            }
            ExpenseTotalLbl.text! = getValue(amount: updatedTotal)
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        switch categoreySegmentControl.selectedSegmentIndex {
        case 1:
            //rowCount = 0
            rowCount = suppliesExpenses.count
            break
        case 2:
            //rowCount = 0
            rowCount = foodExpenses.count
            break
        case 3:
            //rowCount = 0
            rowCount = gasExpenses.count
            break
        default:
            //rowCount = 0
            rowCount = expenses.count
            break
        }
        return rowCount
    }
    
    func getValue(amount: Int) -> String {
        let number = Double(amount/100) + Double(amount%100)/100
        return numberformatter.string(from: NSNumber(value: number))!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ExpenseTableViewCell
        
        switch categoreySegmentControl.selectedSegmentIndex {
        case 1:
            cell.vendorNameLbl.text! = suppliesExpenses[indexPath.row].vendorName
            cell.dateLbl.text! = suppliesExpenses[indexPath.row].expenseDate
            cell.categoryLbl.textColor = findCategoryColor(passedCategory: suppliesExpenses[indexPath.row].category)
            cell.categoryLbl.text! = suppliesExpenses[indexPath.row].category
            cell.expenseAmountLbl.text! = getValue(amount: suppliesExpenses[indexPath.row].expenseAmount)
            break
        case 2:
            cell.vendorNameLbl.text! = foodExpenses[indexPath.row].vendorName
            cell.dateLbl.text! = foodExpenses[indexPath.row].expenseDate
            cell.categoryLbl.textColor = findCategoryColor(passedCategory: foodExpenses[indexPath.row].category)
            cell.categoryLbl.text! = foodExpenses[indexPath.row].category
            cell.expenseAmountLbl.text! = getValue(amount: foodExpenses[indexPath.row].expenseAmount)
            break
        case 3:
            cell.vendorNameLbl.text! = gasExpenses[indexPath.row].vendorName
            cell.dateLbl.text! = gasExpenses[indexPath.row].expenseDate
            cell.categoryLbl.textColor = findCategoryColor(passedCategory: gasExpenses[indexPath.row].category)
            cell.categoryLbl.text! = gasExpenses[indexPath.row].category
            cell.expenseAmountLbl.text! = getValue(amount: gasExpenses[indexPath.row].expenseAmount)
            break
        default:
            cell.vendorNameLbl.text! = expenses[indexPath.row].vendorName
            cell.dateLbl.text! = expenses[indexPath.row].expenseDate
            cell.categoryLbl.textColor = findCategoryColor(passedCategory: expenses[indexPath.row].category)
            cell.categoryLbl.text! = expenses[indexPath.row].category
            cell.expenseAmountLbl.text! = getValue(amount: expenses[indexPath.row].expenseAmount)
            break
        }
        return cell
    }
    
    func findCategoryColor(passedCategory: String) -> UIColor {
        
        var catColor: UIColor!
        
        if passedCategory == Constants.Category.supplies {
            catColor = UIColor(hexString: "#FD9A28")
        } else if passedCategory == Constants.Category.food {
            catColor = UIColor(hexString: "#26A7FF")
        } else if  passedCategory == Constants.Category.gas {
            catColor = UIColor(hexString: "#FF5126")
        }
        return catColor
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch categoreySegmentControl.selectedSegmentIndex {
        case 1:
            // Supplies
            if editingStyle == .delete {
                let alert = UIAlertController(title: "Delete Expense", message: "Are you sure you want to delete this expense?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    self.deleteFromFirestore(uid: self.suppliesExpenses[indexPath.row].docId, indexpath: indexPath)
                    self.suppliesExpenses.remove(at: indexPath.row)
                    self.index = self.find(value: self.suppliesExpenses[indexPath.row].docId, in: self.expenses)!
                    self.expenses.remove(at: self.index)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    self.runTotals(category: Constants.Category.supplies)
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            break
        case 2:
            // Food
            if editingStyle == .delete {
                let alert = UIAlertController(title: "Delete Expense", message: "Are you sure you want to delete this expense?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    
                    self.deleteFromFirestore(uid: self.foodExpenses[indexPath.row].docId, indexpath: indexPath)
                    self.foodExpenses.remove(at: indexPath.row)
                    self.index = self.find(value: self.foodExpenses[indexPath.row].docId, in: self.expenses)!
                    self.expenses.remove(at: self.index)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    self.runTotals(category: Constants.Category.food)
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            break
        case 3:
            // Gas
            if editingStyle == .delete {
                let alert = UIAlertController(title: "Delete Expense", message: "Are you sure you want to delete this expense?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    
                    self.deleteFromFirestore(uid: self.gasExpenses[indexPath.row].docId, indexpath: indexPath)
                    self.gasExpenses.remove(at: indexPath.row)
                    self.index = self.find(value: self.gasExpenses[indexPath.row].docId, in: self.expenses)!
                    self.expenses.remove(at: self.index)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    self.runTotals(category: Constants.Category.gas)
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            break
        default:
            // All
            if editingStyle == .delete {
                let alert = UIAlertController(title: "Delete Expense", message: "Are you sure you want to delete this expense?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    
                    self.deleteFromFirestore(uid: self.expenses[indexPath.row].docId, indexpath: indexPath)
                    
                    if self.expenses[indexPath.row].category == Constants.Category.supplies {
                        self.index = self.find(value: self.expenses[indexPath.row].docId, in: self.suppliesExpenses)!
                        self.suppliesExpenses.remove(at: self.index)
                        self.expenses.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    } else if self.expenses[indexPath.row].category == Constants.Category.food {
                        self.index = self.find(value: self.expenses[indexPath.row].docId, in: self.foodExpenses)!
                        self.foodExpenses.remove(at: self.index)
                        self.expenses.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    } else if self.expenses[indexPath.row].category == Constants.Category.gas {
                        self.index = self.find(value: self.expenses[indexPath.row].docId, in: self.gasExpenses)!
                        self.gasExpenses.remove(at: self.index)
                        self.expenses.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                    self.runTotals(category: "default")
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            break
        }
    }
    
    func find(value searchValue: String, in array: [Expense]) -> Int? {
        for (index, value) in array.enumerated() {
            if value.docId == searchValue {
                return index
            }
        }
        return nil
    }
    
    func deleteFromFirestore(uid: String, indexpath: IndexPath) {
        
        self.db.collection("expenses").document(uid).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension Array where Element: Equatable {
    func removing(_ obj: Element) -> [Element] {
        return filter { $0 != obj }
    }
}
