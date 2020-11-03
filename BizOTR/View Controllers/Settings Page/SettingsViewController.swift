//
//  SettingsViewController.swift
//  BizOTR
//
//  Created by Keanu Freitas on 10/8/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var signoutBtn: UIButton!
    @IBOutlet weak var yearPickerView: UIPickerView!
    
    var yearOptions = [String]()
    var year = ""
    let db = Firestore.firestore()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        yearPickerView.dataSource = self
        yearPickerView.delegate = self
        getDataFromFirestore()
    }
    
    @IBAction func signoutBtnTapped(_ sender: Any) {
        self.logoutUser()
    }
    
    func getDataFromFirestore() {
        // Fetch the expenses for this user....
        var tempOptions = [String]()
        let ref = db.collection("years")
        ref.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    tempOptions.append(contentsOf: document.get("year") as! [String])
                    DispatchQueue.main.async {
                        self.yearOptions = tempOptions.reversed()
                        self.yearPickerView.reloadAllComponents()
                    }
                }
            }
        }
    }
    
    // log out
    func logoutUser() {
        // call from any screen
        
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
        
        //UserDefaults.resetStandardUserDefaults()
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isLogin")
        
        // After user has successfully logged out
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "HomeAuthVC")

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
    
    
    @IBAction func settingSaveBtnTapped(_ sender: Any) {
        print("Setting save button was tapped!")
        defaults.set(year, forKey: "systemYear")
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

extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return yearOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        year = yearOptions[row]
        defaults.set(year, forKey: "systemYear")
        
//        if row == 0 {
//            year = "2018"
//        } else if row == 1 {
//            year = "2019"
//        } else if row == 2 {
//            year = "2020"
//        }
    }
}
