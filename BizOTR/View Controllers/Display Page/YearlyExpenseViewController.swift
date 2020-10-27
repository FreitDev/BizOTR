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
        totalExpenses = 0
        expenses = [Expense]()
        getDataFromFirestore()
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
                    self.expenses.append(Expense(vendorName: document.get("name") as! String, expenseDate: document.get("date") as! String, category: document.get("category") as! String, expenseAmount: document.get("amount") as! Int, uid: document.get("uid") as! String))
                    
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
                break
            case 2:
                tableView.reloadData()
                break
            case 3:
                tableView.reloadData()
                break
            default:
                tableView.reloadData()
                break
            }
    }
    
    func queryExpenses(expenses: [Expense]) {
        
        for expense in expenses {
            if expense.category == "Supplies" {
                suppliesExpenses.append(expense)
            } else if expense.category == "Food" {
                foodExpenses.append(expense)
            } else if expense.category == "Gas" {
                gasExpenses.append(expense)
            }
        }
    }
    
    
//    func fetchData() {
//      db.collection("books").addSnapshotListener { (querySnapshot, error) in
//        guard let documents = querySnapshot?.documents else {
//        print("No documents")
//        return
//      }
//
//      self.books = documents.map { queryDocumentSnapshot -> Book in
//        let data = queryDocumentSnapshot.data()
//        let title = data["title"] as? String ?? ""
//        let author = data["author"] as? String ?? ""
//        let numberOfPages = data["pages"] as? Int ?? 0
//
//        return Book(id: .init(), title: title, author: author, numberOfPages: numberOfPages)
//      }
//    }
        
        // MARK: - Table view data source

        func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            
            var count = 0
            
            switch categoreySegmentControl.selectedSegmentIndex
                {
                case 1:
                    count = suppliesExpenses.count
                    break
                case 2:
                    count = foodExpenses.count
                    break
                case 3:
                    count = gasExpenses.count
                    break
                default:
                    count = expenses.count
                    break
                }
            return count
            
            
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ExpenseTableViewCell
            
            switch categoreySegmentControl.selectedSegmentIndex
                {
                case 1:
                    cell.vendorNameLbl.text! = suppliesExpenses[indexPath.row].vendorName
                    cell.dateLbl.text! = suppliesExpenses[indexPath.row].expenseDate
                    if suppliesExpenses[indexPath.row].category == "Supplies" {
                        cell.categoryLbl.textColor = UIColor(hexString: "#FD9A28")
                    } else if suppliesExpenses[indexPath.row].category == "Food" {
                        cell.categoryLbl.textColor = UIColor(hexString: "#26A7FF")
                    } else if  suppliesExpenses[indexPath.row].category == "Gas" {
                        cell.categoryLbl.textColor = UIColor(hexString: "#FF5126")
                    }
                    cell.categoryLbl.text! = suppliesExpenses[indexPath.row].category
                    cell.expenseAmountLbl.text! = getValue(amount: suppliesExpenses[indexPath.row].expenseAmount)
                    break
                case 2:
                    cell.vendorNameLbl.text! = foodExpenses[indexPath.row].vendorName
                    cell.dateLbl.text! = foodExpenses[indexPath.row].expenseDate
                    if foodExpenses[indexPath.row].category == "Supplies" {
                        cell.categoryLbl.textColor = UIColor(hexString: "#FD9A28")
                    } else if foodExpenses[indexPath.row].category == "Food" {
                        cell.categoryLbl.textColor = UIColor(hexString: "#26A7FF")
                    } else if  foodExpenses[indexPath.row].category == "Gas" {
                        cell.categoryLbl.textColor = UIColor(hexString: "#FF5126")
                    }
                    cell.categoryLbl.text! = foodExpenses[indexPath.row].category
                    cell.expenseAmountLbl.text! = getValue(amount: foodExpenses[indexPath.row].expenseAmount)
                   break
                case 3:
                    cell.vendorNameLbl.text! = gasExpenses[indexPath.row].vendorName
                    cell.dateLbl.text! = gasExpenses[indexPath.row].expenseDate
                    if gasExpenses[indexPath.row].category == "Supplies" {
                        cell.categoryLbl.textColor = UIColor(hexString: "#FD9A28")
                    } else if gasExpenses[indexPath.row].category == "Food" {
                        cell.categoryLbl.textColor = UIColor(hexString: "#26A7FF")
                    } else if  gasExpenses[indexPath.row].category == "Gas" {
                        cell.categoryLbl.textColor = UIColor(hexString: "#FF5126")
                    }
                    cell.categoryLbl.text! = gasExpenses[indexPath.row].category
                    cell.expenseAmountLbl.text! = getValue(amount: gasExpenses[indexPath.row].expenseAmount)
                    break
                default:
                    cell.vendorNameLbl.text! = expenses[indexPath.row].vendorName
                    cell.dateLbl.text! = expenses[indexPath.row].expenseDate
                    if expenses[indexPath.row].category == "Supplies" {
                        cell.categoryLbl.textColor = UIColor(hexString: "#FD9A28")
                    } else if expenses[indexPath.row].category == "Food" {
                        cell.categoryLbl.textColor = UIColor(hexString: "#26A7FF")
                    } else if  expenses[indexPath.row].category == "Gas" {
                        cell.categoryLbl.textColor = UIColor(hexString: "#FF5126")
                    }
                    cell.categoryLbl.text! = expenses[indexPath.row].category
                    cell.expenseAmountLbl.text! = getValue(amount: expenses[indexPath.row].expenseAmount)
                   break
                }
            return cell
        }
    
    func getValue(amount: Int) -> String {
        let number = Double(amount/100) + Double(amount%100)/100
        return numberformatter.string(from: NSNumber(value: number))!
    }

        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the specified item to be editable.
            return true
        }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                expenses.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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
