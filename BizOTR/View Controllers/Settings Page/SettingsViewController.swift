//
//  SettingsViewController.swift
//  BizOTR
//
//  Created by Keanu Freitas on 10/8/20.
//  Copyright © 2020 AppKumu. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var signoutBtn: UIButton!
    @IBOutlet weak var yearPickerView: UIPickerView!
    
    var yearOptions: Array = ["2020", "2019", "2018"]
    var year = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        yearPickerView.dataSource = self
        yearPickerView.delegate = self
    }
    
    @IBAction func signoutBtnTapped(_ sender: Any) {
        self.logoutUser()
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
//        if row == 0 {
//            year = "2018"
//        } else if row == 1 {
//            year = "2019"
//        } else if row == 2 {
//            year = "2020"
//        }
    }
}
